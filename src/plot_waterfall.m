% =========================================================================
% Erzeugt ein 3D-Wasserfalldiagramm der Spektren über die Zeit.
% Markiert die HRV-Frequenzbänder (VLF, LF, HF) gemäß der S2k-Leitlinie.
% =========================================================================
function plot_waterfall(spectra, freqs, time_windows, config)
    % Konstanten
    SEC_TO_HOURS = 3600;
    FIG_POS      = [100, 100, 1000, 600];
    MAX_FREQ_HZ  = 0.5; % Grenze für die HRV-Analyse

    time_hours = time_windows / SEC_TO_HOURS;
    
    % Frequenzbereich begrenzen
    rel_idx = freqs <= MAX_FREQ_HZ;
    f_plot  = freqs(rel_idx);
    s_plot  = spectra(:, rel_idx); % Annahme: [Time x Freq]

    figure('Name', '3D Wasserfall HRV', 'Position', FIG_POS);
    
    % Waterfall Plot (X=Frequenzen, Y=Zeit, Z=Spektren)
    s_plot_log = 10 * log10(s_plot + eps); 

    waterfall(f_plot, time_hours, s_plot_log);
    zlabel('Leistung (dB / Hz)');
    hold on;
    
    % Markierung der HRV-Bänder
    t_min = min(time_hours);
    t_max = max(time_hours);
    
    % Frequenzgrenzen 
    freq_vlf_lf = 0.04;
    freq_lf_hf  = 0.15;
    freq_hf_end = 0.40;
    
    % Zeichne Linien (plot3 nutzt X, Y, Z Koordinaten)
    % VLF-LF Grenze
    plot3([freq_vlf_lf freq_vlf_lf], [t_min t_max], [0 0], 'k--', 'LineWidth', 1.5);
    % LF-HF Grenze
    plot3([freq_lf_hf freq_lf_hf], [t_min t_max], [0 0], 'k--', 'LineWidth', 1.5);
    % HF Ende
    plot3([freq_hf_end freq_hf_end], [t_min t_max], [0 0], 'k--', 'LineWidth', 1.5);
    
    % Beschriftung der Bänder
    text(0.02, t_min, 0, 'VLF', 'Color', 'k', 'FontWeight', 'bold');
    text(0.09, t_min, 0, 'LF', 'Color', 'k', 'FontWeight', 'bold');
    text(0.27, t_min, 0, 'HF', 'Color', 'k', 'FontWeight', 'bold');
    
    hold off;
    
    % Styling
    view(-25, 45); % Kamera-Perspektive optimieren
    colormap jet;
    grid on;
    
    title('Zeitliche Entwicklung des HRV-Spektrums (mit Bandmarkierungen)');
    xlabel('Frequenz (Hz)');
    ylabel('Zeit (Stunden)');
    zlabel('Leistung (s^2/Hz)');
    
    saveas(gcf, fullfile(config.paths.results, 'waterfall_plot.png'));
end