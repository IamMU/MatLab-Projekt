% =========================================================================
% Datei: calculate_hrv_bands.m
% Was sie macht: Berechnet die Leistung in den VLF-, LF- und HF-Bändern.
% Wie sie es macht: Sucht die passenden Frequenz-Indizes und integriert das 
% Leistungsspektrum in diesen Bereichen (trapz). Berechnet LF/HF-Ratio.
% =========================================================================
function hrv_results = calculate_hrv_bands(spectra, freqs, config)
    num_windows = size(spectra, 1);
    
    % Indizes für die Frequenzbänder finden
    vlf_idx = freqs >= config.bands.vlf(1) & freqs < config.bands.vlf(2);
    lf_idx  = freqs >= config.bands.lf(1)  & freqs < config.bands.lf(2);
    hf_idx  = freqs >= config.bands.hf(1)  & freqs < config.bands.hf(2);
    
    hrv_results.vlf_power = zeros(num_windows, 1);
    hrv_results.lf_power  = zeros(num_windows, 1);
    hrv_results.hf_power  = zeros(num_windows, 1);
    
    for i = 1:num_windows
        hrv_results.vlf_power(i) = trapz(freqs(vlf_idx), spectra(i, vlf_idx));
        hrv_results.lf_power(i)  = trapz(freqs(lf_idx), spectra(i, lf_idx));
        hrv_results.hf_power(i)  = trapz(freqs(hf_idx), spectra(i, hf_idx));
    end
    
    % Gesamte Leistung (ohne VLF nach typischen Standards, hier LF+HF)
    total_power = hrv_results.lf_power + hrv_results.hf_power;
    
    % Relative Leistung (%)
    hrv_results.lf_norm = (hrv_results.lf_power ./ total_power) * 100;
    hrv_results.hf_norm = (hrv_results.hf_power ./ total_power) * 100;
    
    % LF/HF Verhältnis
    hrv_results.lf_hf_ratio = hrv_results.lf_power ./ hrv_results.hf_power;
end