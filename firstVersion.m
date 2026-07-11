%% MAIN SCRIPT: HRV Long-Term Analysis
% Projekt: Visualisierung langfristiger HRV-Aenderungen
clc; clear; close all;

%% 1. Parameter & Konstanten definieren
% Zentralisierung aller festen Werte (Vermeidung von "Magic Numbers")
PARAMS.fs_target = 4;                 % Zielabtastrate Interpolation in Hz
PARAMS.rr_min_ms = 300;               % Min. RR-Intervall für Plausibilität
PARAMS.rr_max_ms = 1500;              % Max. RR-Intervall für Plausibilität
PARAMS.win_duration_s = 5 * 60;       % FFT-Fensterbreite (5 Minuten)
PARAMS.overlap_pct = 50;              % FFT-Fensterüberlappung in Prozent
PARAMS.band_vlf = [0.0033, 0.04];     % VLF Frequenzband (Hz)
PARAMS.band_lf  = [0.04, 0.15];       % LF Frequenzband (Hz)
PARAMS.band_hf  = [0.15, 0.40];       % HF Frequenzband (Hz)
PARAMS.filter_band = [0.5, 45];       % EKG Bandpass-Filtergrenzen (Hz)
PARAMS.filter_order = 3;              % Butterworth-Filterordnung

scriptDir = fileparts(mfilename('fullpath'));
edfFilename = fullfile(scriptDir, '06-51-02.EDF');

%% 2. Ausfuehrung der Pipeline
[ecgSignal, fs] = load_ecg_data(edfFilename);

ecgClean = preprocess_ecg(ecgSignal, fs, PARAMS);

rPeaks = detect_r_peaks(ecgClean, fs);
[rrIntervals, rrTimes] = calculate_rr_intervals(rPeaks, fs, PARAMS);

[rrInterpolated, tInterpolated] = interpolate_rr_signal(rrIntervals, rrTimes, PARAMS);

[spectra, frequencies, timeVector] = calculate_fft_spectrum(rrInterpolated, tInterpolated, PARAMS);
hrvBands = calculate_hrv_bands(spectra, frequencies, PARAMS);

%% 3. Performance & Visualisierung
info = whistle_performance_check(ecgSignal, spectra);
fprintf('\n--- Performance-Analyse ---\n');
fprintf('Speicherbedarf EKG-Signal: %.2f MB\n', info.MemoryMB);
fprintf('Anzahl berechneter FFT-Spektren: %d\n\n', info.SpectraCount);

plot_longterm_rr(rrTimes, rrIntervals, ecgClean, fs);
plot_waterfall_and_heatmap(spectra, frequencies, timeVector);
plot_hrv_trends(timeVector, hrvBands);
compare_time_segments(timeVector, hrvBands);


%% ==========================================
%% MODULARE FUNKTIONEN
%% ==========================================

function [ecgSignal, fs] = load_ecg_data(filename)
    if nfile_exists(filename)
        edfData = edfread(filename);
        varNames = edfData.Properties.VariableNames;
        
        ecgIdx = find(contains(varNames, 'ECG', 'IgnoreCase', true), 1);
        if isempty(ecgIdx)
            ecgIdx = 1; 
        end
        
        rawCell = edfData.(varNames{ecgIdx});
        ecgSignal = double(vertcat(rawCell{:}))';
        
        % Robuste Berechnung der Abtastrate direkt aus EDF-Metadaten
        infoEdf = edfinfo(filename);
        recordDurationSec = seconds(infoEdf.DataRecordDuration);
        samplesPerRecord = infoEdf.NumSamples(ecgIdx);
        fs = double(samplesPerRecord) / recordDurationSec;
        
        if fs < 50 || fs > 2000 || isnan(fs)
            warning('Unplausible Abtastrate: %.4f Hz', fs);
        end
    else
        % Fallback: Synthetische Datengenerierung (Simuliert circadianen Rhythmus)
        fs = 250; 
        t = 0:1/fs:(8 * 3600);
        circadianFactor = 70 + 15 * cos(2 * pi * t / (8 * 3600)); 
        
        ecgSignal = zeros(size(t));
        currentSample = 1;
        while currentSample < length(t)
            currentHR = circadianFactor(currentSample) / 60;
            nextInterval = (1 / currentHR) + 0.05 * randn(); 
            nextSample = currentSample + round(nextInterval * fs);
            if nextSample >= length(t), break; end
            ecgSignal(nextSample) = 1.5; 
            currentSample = nextSample;
        end
        
        ecgSignal = ecgSignal + 0.2 * randn(size(t)) + 0.1 * sin(2 * pi * 50 * t) + 0.5 * sin(2 * pi * 0.01 * t);
    end
end

function tf = nfile_exists(filename)
    tf = ~isempty(filename) && exist(filename, 'file') == 2;
end

function ecgClean = preprocess_ecg(ecgSignal, fs, PARAMS)
    % Entfernt Gleichanteil und hochfrequentes Rauschen / Netzbrummen
    ecgDetrend = detrend(ecgSignal);
    [b, a] = butter(PARAMS.filter_order, PARAMS.filter_band / (fs / 2), 'bandpass');
    ecgClean = filtfilt(b, a, ecgDetrend);
end

function rPeaks = detect_r_peaks(ecgClean, fs)
    % Angelehnt an den Pan-Tompkins-Algorithmus:
    % 1. Differenziation hebt Flankensteilheit des QRS-Komplexes hervor
    diffSig = diff(ecgClean);
    
    % 2. Quadrierung verstärkt hochfrequente R-Zacken und dämpft P/T-Wellen
    squaredSig = diffSig.^2;
    
    % 3. Gleitende Mittelwertbildung erzeugt eine Hüllkurve (Moving Window Integration)
    windowLength = round(0.15 * fs);
    integratedSig = movmean(squaredSig, windowLength);
    
    % Adaptive Schwellenwertbildung basierend auf Signalstärke
    minPeakDistance = round(0.3 * fs);
    threshold = mean(integratedSig) * 2.5;
    
    [~, locs] = findpeaks(integratedSig, 'MinPeakHeight', threshold, 'MinPeakDistance', minPeakDistance);
    
    % Refokussierung: Suche das exakte lokale Maximum im Original-EKG nahe der Hüllkurven-Peaks
    rPeaks = zeros(size(locs));
    searchWin = round(0.05 * fs);
    for i = 1:length(locs)
        startIdx = max(1, locs(i) - searchWin);
        endIdx = min(length(ecgClean), locs(i) + searchWin);
        [~, maxIdx] = max(ecgClean(startIdx:endIdx));
        rPeaks(i) = startIdx + maxIdx - 1;
    end
end

function [rrIntervals, rrTimes] = calculate_rr_intervals(rPeaks, fs, PARAMS)
    rrSamples = diff(rPeaks);
    rrIntervals = (rrSamples / fs) * 1000;
    rrTimes = rPeaks(2:end) / fs;
    
    % Plausibilitätsprüfung (Ausschluss von Artefakten / Extrasystolen)
    validIdx = (rrIntervals >= PARAMS.rr_min_ms) & (rrIntervals <= PARAMS.rr_max_ms);
    rrIntervals = rrIntervals(validIdx);
    rrTimes = rrTimes(validIdx);
end

function [rrInterpolated, tInterpolated] = interpolate_rr_signal(rrIntervals, rrTimes, PARAMS)
    tInterpolated = rrTimes(1):(1/PARAMS.fs_target):rrTimes(end);
    rrInterpolated = spline(rrTimes, rrIntervals, tInterpolated);
end

function [spectra, frequencies, timeVector] = calculate_fft_spectrum(rrInterpolated, tInterpolated, PARAMS)
    % Berechnung eines gleitenden Leistungsdichtespektrums (PSD) 
    % vergleichbar mit Welchs Methode, aber zeiterhaltend für den Wasserfall-Plot.
    windowSamples = PARAMS.win_duration_s * PARAMS.fs_target;
    stepSamples = round(windowSamples * (1 - PARAMS.overlap_pct/100));
    
    % Zero-Padding zur Erhöhung der Frequenzauflösung im Spektrum
    nfft = 2^nextpow2(windowSamples);
    frequencies = (0:nfft/2) * (PARAMS.fs_target / nfft);
    
    numWindows = floor((length(rrInterpolated) - windowSamples) / stepSamples) + 1;
    spectra = zeros(length(frequencies), numWindows);
    timeVector = zeros(1, numWindows);
    
    % Hamming-Fenster zur Reduzierung des spektralen Leckeffekts (Spectral Leakage)
    hammingWin = hamming(windowSamples)';
    
    for i = 1:numWindows
        startIdx = (i-1) * stepSamples + 1;
        endIdx = startIdx + windowSamples - 1;
        
        segment = rrInterpolated(startIdx:endIdx);
        segmentWindowed = detrend(segment) .* hammingWin;
        
        fftRes = fft(segmentWindowed, nfft);
        % Berechnung der einseitigen spektralen Leistungsdichte
        psd = (abs(fftRes(1:nfft/2+1)).^2) / (PARAMS.fs_target * windowSamples);
        
        spectra(:, i) = psd;
        timeVector(i) = tInterpolated(startIdx + round(windowSamples/2));
    end
end

function hrvBands = calculate_hrv_bands(spectra, frequencies, PARAMS)
    vlfIdx = (frequencies >= PARAMS.band_vlf(1)) & (frequencies < PARAMS.band_vlf(2));
    lfIdx  = (frequencies >= PARAMS.band_lf(1))  & (frequencies < PARAMS.band_lf(2));
    hfIdx  = (frequencies >= PARAMS.band_hf(1))  & (frequencies < PARAMS.band_hf(2));
    
    df = frequencies(2) - frequencies(1);
    
    % Numerische Integration der Leistungsdichte über die Frequenzbänder
    hrvBands.VLF = sum(spectra(vlfIdx, :)) * df;
    hrvBands.LF  = sum(spectra(lfIdx, :)) * df;
    hrvBands.HF  = sum(spectra(hfIdx, :)) * df;
    
    hrvBands.TotalPower = hrvBands.VLF + hrvBands.LF + hrvBands.HF;
    hrvBands.LFHF = hrvBands.LF ./ hrvBands.HF;
end

%% ==========================================
%% PLOT-FUNKTIONEN
%% ==========================================

function plot_longterm_rr(rrTimes, rrIntervals, ecgClean, fs)
    figure('Name', 'Langfristiger RR-Verlauf', 'NumberTitle', 'off', 'Position', [100, 100, 900, 600]);
    
    subplot(2,1,1);
    plot(rrTimes / 3600, rrIntervals, 'b.', 'MarkerSize', 4);
    title('Langzeit-RR-Tachogramm');
    xlabel('Zeit (Stunden)'); ylabel('RR-Intervall (ms)');
    grid on;
    
    subplot(2,1,2);
    tEcg = (0:length(ecgClean)-1) / fs;
    zoomIdx = tEcg <= 10;
    plot(tEcg(zoomIdx), ecgClean(zoomIdx), 'r', 'LineWidth', 1.2);
    title('Zoom: Erste 10 Sekunden EKG');
    xlabel('Zeit (Sekunden)'); ylabel('Amplitude (mV)');
    grid on;
end

function plot_waterfall_and_heatmap(spectra, frequencies, timeVector)
    figure('Name', 'Spektrale HRV-Analyse', 'NumberTitle', 'off', 'Position', [150, 100, 1000, 700]);
    
    freqLimitIdx = frequencies <= 0.45; % Anzeige auf relevante HRV-Bänder limitieren
    timeHours = timeVector / 3600; 
    
    % 3D Wasserfall
    subplot(2,1,1);
    waterfall(frequencies(freqLimitIdx), timeHours, spectra(freqLimitIdx, :)');
    title('3D-Wasserfalldarstellung (Gleitendes Spektrum)');
    xlabel('Frequenz (Hz)'); ylabel('Zeit (h)'); zlabel('Leistung (ms²/Hz)');
    colormap(jet); view(-35, 45); grid on;
    
    % 2D Heatmap / Spektrogramm
    subplot(2,1,2);
    imagesc(timeHours, frequencies(freqLimitIdx), spectra(freqLimitIdx, :));
    axis xy; % Frequenzachse von unten nach oben
    title('Spektrogramm / Heatmap');
    xlabel('Zeit (h)'); ylabel('Frequenz (Hz)');
    c = colorbar; c.Label.String = 'Spektrale Leistung';
    colormap(jet);
end

function plot_hrv_trends(timeVector, hrvBands)
    figure('Name', 'HRV-Trendkurven', 'NumberTitle', 'off', 'Position', [200, 100, 900, 600]);
    timeHours = timeVector / 3600;
    
    subplot(2,1,1);
    plot(timeHours, hrvBands.LF, 'r', 'LineWidth', 1.5); hold on;
    plot(timeHours, hrvBands.HF, 'b', 'LineWidth', 1.5);
    title('Leistungstrends der Frequenzbänder');
    xlabel('Zeit (h)'); ylabel('Leistung (ms²)');
    legend('LF', 'HF'); grid on;
    
    subplot(2,1,2);
    plot(timeHours, hrvBands.LFHF, 'k', 'LineWidth', 1.5);
    title('Sympathovagale Balance (LF/HF)');
    xlabel('Zeit (h)'); ylabel('Verhältnis');
    grid on;
end

function compare_time_segments(timeVector, hrvBands)
    timeHours = timeVector / 3600;
    midPoint = max(timeHours) / 2;
    
    % Teilt Messung strikt in vordere und hintere Hälfte (z.B. Aktiv vs. Schlaf)
    phase1Idx = timeHours <= midPoint;
    phase2Idx = timeHours > midPoint;
    
    dataMatrix = [mean(hrvBands.LF(phase1Idx)), mean(hrvBands.LF(phase2Idx)); 
                  mean(hrvBands.HF(phase1Idx)), mean(hrvBands.HF(phase2Idx)); 
                  mean(hrvBands.LFHF(phase1Idx)), mean(hrvBands.LFHF(phase2Idx))];
    
    figure('Name', 'Vergleich Zeitabschnitte', 'NumberTitle', 'off', 'Position', [250, 100, 700, 500]);
    bar(dataMatrix);
    set(gca, 'XTickLabel', {'LF', 'HF', 'LF/HF'});
    title('Mittelwertvergleich: 1. vs 2. Nachthälfte / Tageshälfte');
    legend('Phase 1', 'Phase 2'); grid on;
end

function info = whistle_performance_check(ecgSignal, spectra)
    s = whos('ecgSignal');
    info.MemoryMB = s.bytes / (1024^2);
    info.SpectraCount = size(spectra, 2);
end