% =========================================================================
% Datei: calculate_fft_spectrum.m
% Was sie macht: Berechnet die Spektren über gleitende Zeitfenster.
% Wie sie es macht: Teilt das Signal in 5-Minuten-Fenster mit 50% Überlappung
% auf und wendet auf jedes Fenster eine eigene FFT (mit Hanning-Fenster) an.
% =========================================================================
function [spectra, freqs, time_windows] = calculate_fft_spectrum(rr_interp, config)
    fs = config.hrv.interp_fs;
    window_length = config.hrv.window_sec * fs; 
    step_size = window_length * (1 - config.hrv.overlap_pct);
    
    num_windows = floor((length(rr_interp) - window_length) / step_size) + 1;
    
    % Frequenzvektor vorbereiten (nur positive Frequenzen)
    nfft = 2^nextpow2(window_length); 
    freqs = (0:(nfft/2-1)) * (fs / nfft);
    
    spectra = zeros(num_windows, nfft/2);
    time_windows = zeros(num_windows, 1);
    
    % Hanning-Fenster zur Unterdrückung von Leck-Effekten
    win = hann(window_length)';
    
    for i = 1:num_windows
        start_idx = round((i-1) * step_size + 1);
        end_idx = round(start_idx + window_length - 1);
        
        segment = rr_interp(start_idx:end_idx) .* win;
        
        % FFT berechnen
        Y = fft(segment, nfft);
        P2 = abs(Y / window_length);
        P1 = P2(1:nfft/2);
        P1(2:end-1) = 2 * P1(2:end-1);
        
        spectra(i, :) = P1.^2; % Leistungsspektrum
        time_windows(i) = start_idx / fs; % Startzeit des Fensters in s
    end
end