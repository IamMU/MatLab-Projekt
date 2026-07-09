%% MAIN SCRIPT: HRV Long-Term Analysis
% Projekt: Visualisierung langfristiger HRV-Änderungen
clc; clear; close all;

fprintf('Starte HRV-Langzeitanalyse...\n');

%% 1. Datenimport & Parameter definieren
% Pfad relativ zum Skript-Ordner aufbauen, damit es unabhängig vom
% "Current Folder" in MATLAB funktioniert.
scriptDir = fileparts(mfilename('fullpath'));
edfFilename = fullfile(scriptDir, '06-51-02.EDF');   % <-- Datei muss im selben Ordner wie dieses .m liegen
[ecgSignal, fs] = load_ecg_data(edfFilename);

%% 2. Vorverarbeitung
fprintf('Führe Vorverarbeitung durch...\n');
ecgClean = preprocess_ecg(ecgSignal, fs);

%% 3. R-Peak-Erkennung & RR-Intervalle
fprintf('Erkenne R-Peaks und berechne RR-Intervalle...\n');
rPeaks = detect_r_peaks(ecgClean, fs);
[rrIntervals, rrTimes] = calculate_rr_intervals(rPeaks, fs);

%% 4. Interpolation (Gleichmäßige Abtastung)
fprintf('Interpoliere RR-Intervalle (Kubische Splines)...\n');
fs_target = 4; % Zielabtastrate 4 Hz gemäß Leitlinie
[rrInterpolated, tInterpolated] = interpolate_rr_signal(rrIntervals, rrTimes, fs_target);

%% 5. Gleitende FFT & Frequenzbandanalyse
fprintf('Berechne gleitende FFT und HRV-Bänder...\n');
% Parameter: Fensterbreite 5 Min (300s), Überlappung 50%
windowDuration = 5 * 60; 
overlapPercent = 50;

[spectra, frequencies, timeVector] = calculate_fft_spectrum(rrInterpolated, tInterpolated, fs_target, windowDuration, overlapPercent);
hrvBands = calculate_hrv_bands(spectra, frequencies);

%% 6. Visualisierungen und Performance-Messung
fprintf('Erzeuge Visualisierungen...\n');

% Speicher- und Laufzeitanalyse (Anforderung 2.12)
info = whistle_performance_check(ecgSignal, spectra);
fprintf('\n--- Performance-Analyse ---\n');
fprintf('Speicherbedarf EKG-Signal: %.2f MB\n', info.MemoryMB);
fprintf('Anzahl berechneter FFT-Spektren: %d\n\n', length(timeVector));

% Plots aufrufen
plot_longterm_rr(rrTimes, rrIntervals, ecgClean, fs);
plot_waterfall(spectra, frequencies, timeVector);
plot_hrv_trends(timeVector, hrvBands);
compare_time_segments(timeVector, hrvBands);


%% ==========================================
%% MODULARE FUNKTIONEN (Technische Mindestanforderungen)
%% ==========================================

function [ecgSignal, fs] = load_ecg_data(filename)
    % Lädt EDF-Daten oder erzeugt synthetische Daten für einen lauffähigen Test
    if nfile_exists(filename)
        fprintf('EDF-Datei gefunden: %s\n', filename);
        % Für echte EDF-Dateien (erfordert MATLAB R2020b oder neuer)
        edfData = edfread(filename);

        % --- Kanal automatisch finden statt festen Namen zu erraten ---
        varNames = edfData.Properties.VariableNames;
        fprintf('Verfügbare Kanäle in der EDF-Datei:\n');
        disp(varNames);

        % Versuche zuerst einen Kanal mit "ECG" im Namen zu finden,
        % ansonsten nimm den ersten Kanal.
        ecgIdx = find(contains(varNames, 'ECG', 'IgnoreCase', true), 1);
        if isempty(ecgIdx)
            ecgIdx = 1;
            fprintf('Kein Kanal mit "ECG" im Namen gefunden – verwende ersten Kanal: %s\n', varNames{1});
        else
            fprintf('Verwende Kanal: %s\n', varNames{ecgIdx});
        end

        % Zellen aus dem timetable in einen durchgehenden Vektor umwandeln
        rawCell = edfData.(varNames{ecgIdx});
        ecgSignal = vertcat(rawCell{:});
        ecgSignal = double(ecgSignal(:))';

        % --- Abtastrate zuverlässig bestimmen ---
        % edfData.Properties.VariableInfo(...).SampleRate liefert bei manchen
        % EDF+-Dateien unbrauchbare Werte (z.B. 0.01 Hz statt der echten Rate).
        % Deshalb wird fs direkt und robust aus edfinfo für GENAU diesen Kanal
        % berechnet: Samples pro Datensatz (record) für den Kanal, geteilt durch
        % die Dauer eines Datensatzes. EDF-Kanäle können unterschiedliche
        % Abtastraten haben (ECG hochfrequent, Marker/HRV niederfrequent) - daher
        % ecgIdx-spezifisch, NICHT global.
        infoEdf = edfinfo(filename);
        recordDurationSec = seconds(infoEdf.DataRecordDuration);
        samplesPerRecord = infoEdf.NumSamples(ecgIdx); % Samples des ECG-Kanals PRO Datensatz
        fs = double(samplesPerRecord) / recordDurationSec;

        % Plausibilitätsprüfung: EKG sollte typischerweise zwischen 50 und 2000 Hz liegen
        if fs < 50 || fs > 2000 || isnan(fs)
            warning('Erkannte Abtastrate (%.4f Hz) wirkt unplausibel für ein EKG-Signal. Bitte manuell prüfen (infoEdf.NumSamples, infoEdf.DataRecordDuration).', fs);
        end

        fprintf('Abtastrate erkannt: %.2f Hz, Anzahl Samples: %d\n', fs, length(ecgSignal));
    else
        % SYNTHETISCHE DATENGENERIERUNG (Simuliert 8 Stunden Langzeit-EKG)
        fprintf('Keine EDF-Datei gefunden unter: %s\n', filename);
        fprintf('Generiere synthetische Langzeitdaten (8 Stunden)...\n');
        fs = 250; % 250 Hz Abtastrate
        durationHours = 8;
        totalSeconds = durationHours * 3600;
        t = 0:1/fs:totalSeconds;
        
        % Simuliere circadianen Rhythmus (Herzfrequenz sinkt in der "Nacht"/Ruhephase)
        circadianFactor = 70 + 15 * cos(2 * pi * t / totalSeconds); 
        
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
        
        ecgSignal = ecgSignal + 0.2 * randn(size(t));
        ecgSignal = ecgSignal + 0.1 * sin(2 * pi * 50 * t);
        ecgSignal = ecgSignal + 0.5 * sin(2 * pi * 0.01 * t);
    end
end

function tf = nfile_exists(filename)
    tf = ~isempty(filename) && exist(filename, 'file') == 2;
end

function ecgClean = preprocess_ecg(ecgSignal, fs)
    ecgDetrend = detrend(ecgSignal);
    [b, a] = butter(3, [0.5, 45] / (fs / 2), 'bandpass');
    ecgClean = filtfilt(b, a, ecgDetrend);
end

function rPeaks = detect_r_peaks(ecgClean, fs)
    diffSig = diff(ecgClean);
    squaredSig = diffSig.^2;
    
    windowLength = round(0.15 * fs);
    integratedSig = movmean(squaredSig, windowLength);
    
    minPeakDistance = round(0.3 * fs);
    threshold = mean(integratedSig) * 2.5;
    
    [~, locs] = findpeaks(integratedSig, 'MinPeakHeight', threshold, 'MinPeakDistance', minPeakDistance);
    
    rPeaks = zeros(size(locs));
    searchWin = round(0.05 * fs);
    for i = 1:length(locs)
        startIdx = max(1, locs(i) - searchWin);
        endIdx = min(length(ecgClean), locs(i) + searchWin);
        [~, maxIdx] = max(ecgClean(startIdx:endIdx));
        rPeaks(i) = startIdx + maxIdx - 1;
    end
end

function [rrIntervals, rrTimes] = calculate_rr_intervals(rPeaks, fs)
    rrSamples = diff(rPeaks);
    rrIntervals = (rrSamples / fs) * 1000;
    rrTimes = rPeaks(2:end) / fs;
    
    validIdx = (rrIntervals >= 300) & (rrIntervals <= 1500);
    rrIntervals = rrIntervals(validIdx);
    rrTimes = rrTimes(validIdx);
end

function [rrInterpolated, tInterpolated] = interpolate_rr_signal(rrIntervals, rrTimes, fs_target)
    tInterpolated = rrTimes(1):(1/fs_target):rrTimes(end);
    rrInterpolated = spline(rrTimes, rrIntervals, tInterpolated);
end

function [spectra, frequencies, timeVector] = calculate_fft_spectrum(rrInterpolated, tInterpolated, fs_target, windowDuration, overlapPercent)
    % Gleitende FFT-basierte HRV-Analyse (Short-Time Fourier Transform)
    windowSamples = windowDuration * fs_target;
    stepSamples = round(windowSamples * (1 - overlapPercent/100));
    
    nfft = 2^nextpow2(windowSamples);
    frequencies = (0:nfft/2) * (fs_target / nfft);
    
    numWindows = floor((length(rrInterpolated) - windowSamples) / stepSamples) + 1;
    spectra = zeros(length(frequencies), numWindows);
    timeVector = zeros(1, numWindows);
    
    hammingWin = hamming(windowSamples)';
    
    for i = 1:numWindows
        startIdx = (i-1) * stepSamples + 1;
        endIdx = startIdx + windowSamples - 1;
        
        segment = rrInterpolated(startIdx:endIdx);
        segmentDetrend = detrend(segment); 
        segmentWindowed = segmentDetrend .* hammingWin;
        
        fftRes = fft(segmentWindowed, nfft);
        psd = (abs(fftRes(1:nfft/2+1)).^2) / (fs_target * windowSamples);
        
        spectra(:, i) = psd;
        timeVector(i) = tInterpolated(startIdx + round(windowSamples/2)); % Zentrierter Zeitstempel
    end
end

function hrvBands = calculate_hrv_bands(spectra, frequencies)
    vlfIdx = (frequencies >= 0.0033) & (frequencies < 0.04);
    lfIdx = (frequencies >= 0.04) & (frequencies < 0.15);
    hfIdx = (frequencies >= 0.15) & (frequencies < 0.40);
    
    numWindows = size(spectra, 2);
    hrvBands.VLF = zeros(1, numWindows);
    hrvBands.LF = zeros(1, numWindows);
    hrvBands.HF = zeros(1, numWindows);
    hrvBands.LFHF = zeros(1, numWindows);
    hrvBands.TotalPower = zeros(1, numWindows);
    
    df = frequencies(2) - frequencies(1);
    
    for i = 1:numWindows
        psd = spectra(:, i);
        
        hrvBands.VLF(i) = sum(psd(vlfIdx)) * df;
        hrvBands.LF(i) = sum(psd(lfIdx)) * df;
        hrvBands.HF(i) = sum(psd(hfIdx)) * df;
        
        hrvBands.TotalPower(i) = hrvBands.VLF(i) + hrvBands.LF(i) + hrvBands.HF(i);
        hrvBands.LFHF(i) = hrvBands.LF(i) / hrvBands.HF(i);
    end
end

%% ==========================================
%% PLOT-FUNKTIONEN & VISUALISIERUNG
%% ==========================================

function plot_longterm_rr(rrTimes, rrIntervals, ecgClean, fs)
    figure('Name', 'Langfristiger RR-Verlauf (Tachogramm)', 'NumberTitle', 'off', 'Position', [100, 100, 900, 600]);
    
    subplot(2,1,1);
    plot(rrTimes / 3600, rrIntervals, 'b.', 'MarkerSize', 4);
    title('Langzeit-RR-Tachogramm');
    xlabel('Zeit (Stunden)');
    ylabel('RR-Intervall (ms)');
    grid on;
    
    subplot(2,1,2);
    tEcg = (0:length(ecgClean)-1) / fs;
    zoomIdx = tEcg <= 10;
    plot(tEcg(zoomIdx), ecgClean(zoomIdx), 'r', 'LineWidth', 1.2);
    title('Zoom: Erste 10 Sekunden des gefilterten EKG-Signals');
    xlabel('Zeit (Sekunden)');
    ylabel('Amplitude (mV)');
    grid on;
end

function plot_waterfall(spectra, frequencies, timeVector)
    figure('Name', '3D-Wasserfalldarstellung des HRV-Spektrums', 'NumberTitle', 'off', 'Position', [150, 100, 900, 600]);
    
    freqLimitIdx = frequencies <= 0.45;
    timeHours = timeVector / 3600; 
    
    waterfall(frequencies(freqLimitIdx), timeHours, spectra(freqLimitIdx, :)');
    
    title('Gleitendes HRV-Leistungsdichtespektrum (3D-Wasserfall)');
    xlabel('Frequenz (Hz)');
    ylabel('Zeit der Messung (Stunden)');
    zlabel('Spektrale Leistung (ms²/Hz)');
    colormap(jet);
    view(-35, 45);
    grid on;
end

function plot_hrv_trends(timeVector, hrvBands)
    figure('Name', 'HRV-Trendkurven über die Zeit', 'NumberTitle', 'off', 'Position', [200, 100, 900, 600]);
    timeHours = timeVector / 3600;
    
    subplot(2,1,1);
    plot(timeHours, hrvBands.LF, 'r', 'LineWidth', 1.5); hold on;
    plot(timeHours, hrvBands.HF, 'b', 'LineWidth', 1.5);
    title('Trends der Frequenzbänder (Absolute Leistung)');
    xlabel('Zeit (Stunden)');
    ylabel('Leistung (ms²)');
    legend('LF (Sympathikus/Paraspathikus)', 'HF (Vagal/Parasympathikus)');
    grid on;
    
    subplot(2,1,2);
    plot(timeHours, hrvBands.LFHF, 'k', 'LineWidth', 1.5);
    title('Sympathovagale Balance ($LF/HF$-Verhältnis)');
    xlabel('Zeit (Stunden)');
    ylabel('Verhältniswert');
    grid on;
end

function compare_time_segments(timeVector, hrvBands)
    timeHours = timeVector / 3600;
    midPoint = max(timeHours) / 2;
    
    phase1Idx = timeHours <= midPoint;
    phase2Idx = timeHours > midPoint;
    
    meanLF_P1 = mean(hrvBands.LF(phase1Idx));
    meanLF_P2 = mean(hrvBands.LF(phase2Idx));
    meanHF_P1 = mean(hrvBands.HF(phase1Idx));
    meanHF_P2 = mean(hrvBands.HF(phase2Idx));
    meanRatio_P1 = mean(hrvBands.LFHF(phase1Idx));
    meanRatio_P2 = mean(hrvBands.LFHF(phase2Idx));
    
    figure('Name', 'Vergleich der Messabschnitte', 'NumberTitle', 'off', 'Position', [250, 100, 700, 500]);
    dataMatrix = [meanLF_P1, meanLF_P2; meanHF_P1, meanHF_P2; meanRatio_P1, meanRatio_P2];
    
    bar(dataMatrix);
    set(gca, 'XTickLabel', {'LF Leistung', 'HF Leistung', 'LF/HF Verhältnis'});
    title('Vergleich: Phase 1 (Aktivität) vs. Phase 2 (Ruhe/Nacht)');
    ylabel('Mittelwerte');
    legend('Phase 1 (Anfang / Aktiv)', 'Phase 2 (Ende / Ruhe)');
    grid on;
end

function info = whistle_performance_check(ecgSignal, spectra)
    s = whos('ecgSignal');
    info.MemoryMB = s.bytes / (1024^2);
    info.SpectraCount = size(spectra, 2);
end
