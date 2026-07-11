% =========================================================================
% Berechnet die Spektren über gleitende Zeitfenster.
% Teilt das Signal in 5-Minuten-Fenster mit 50% Überlappung
% auf und wendet auf jedes Fenster eine eigene FFT (mit Hanning-Fenster) an.
% =========================================================================
function [spectra, freqs, time_windows] = calculate_fft_spectrum(rr_interp, config)
    % Konstanten
    fs = config.hrv.interp_fs;
    window_length = round(config.hrv.window_sec * fs); 
    noverlap = round(window_length * config.hrv.overlap_pct);
    nfft = 2^nextpow2(window_length);
    
    % Hanning-Fenster zur Unterdrückung von Leck-Effekten
    win = hann(window_length);
    
    % Spektrogramm 
    % S = Kurzzeit-Fouriertransformation, F = Frequenzen, T = Zeiten, P = Leistungsspektrum
    [~, freqs, time_windows, P] = spectrogram(rr_interp, win, noverlap, nfft, fs, 'power');
    
    % Die Toolbox liefert P als [Frequenz x Zeit]. 
    % Um bisherigen  Dimensionen [Zeit x Frequenz] beizubehalten, wird P transponiert.
    spectra = P';
    
    time_windows = time_windows(:); 
end
