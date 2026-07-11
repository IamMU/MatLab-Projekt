% =========================================================================
% Berechnet die Leistung in den VLF-, LF- und HF-Bändern.
% Sucht die passenden Frequenz-Indizes und integriert das Leistungsspektrum
% in diesen Bereichen. Berechnet LF/HF-Ratio.
% =========================================================================
function hrv_results = calculate_hrv_bands(spectra, freqs, config)
    % Indizes für die Frequenzbänder finden
    vlf_idx = freqs >= config.bands.vlf(1) & freqs < config.bands.vlf(2);
    lf_idx  = freqs >= config.bands.lf(1)  & freqs < config.bands.lf(2);
    hf_idx  = freqs >= config.bands.hf(1)  & freqs < config.bands.hf(2);
    
    % Vektorisierte numerische Integration über die Frequenzachse (Dimension 2).
    hrv_results.vlf_power = trapz(freqs(vlf_idx), spectra(:, vlf_idx), 2);
    hrv_results.lf_power  = trapz(freqs(lf_idx),  spectra(:, lf_idx),  2);
    hrv_results.hf_power  = trapz(freqs(hf_idx),  spectra(:, hf_idx),  2);
    
    % Gesamte Leistung (ohne VLF nach typischen Standards, hier LF+HF)
    total_power = hrv_results.lf_power + hrv_results.hf_power;
    
    % Relative Leistung (%)
    hrv_results.lf_norm = (hrv_results.lf_power ./ total_power) * 100;
    hrv_results.hf_norm = (hrv_results.hf_power ./ total_power) * 100;
    
    % LF/HF Verhältnis
    hrv_results.lf_hf_ratio = hrv_results.lf_power ./ hrv_results.hf_power;
end
