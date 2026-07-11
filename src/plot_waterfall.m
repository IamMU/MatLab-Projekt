% =========================================================================
% Erzeugt ein 3D-Wasserfalldiagramm der Spektren über die Zeit.
% Nutzt die waterfall() Funktion. Die X-Achse ist die Frequenz (begrenzt auf 
% max. 0.5 Hz zur besseren Sichtbarkeit der HRV-Bänder), Y-Achse ist die
% Zeit in Stunden, Z-Achse die spektrale Leistung.
% =========================================================================
function plot_waterfall(spectra, freqs, time_windows, config)
    % Konstanten
    SEC_TO_HOURS       = 3600;
    FIG_POS            = [100, 100, 800, 600];
    MAX_FREQ_HZ        = 0.5;
    VIEW_ANGLE         = [-35, 45];
    TEXT_HEIGHT_FACTOR = 0.8;

    figure('Name', '3D Waterfall HRV Spectrum', 'Position', FIG_POS);
    
    time_hours = time_windows / SEC_TO_HOURS;
    
    % Relevanter Frequenzbereich (beschränkt für bessere Sichtbarkeit)
    rel_idx = freqs <= MAX_FREQ_HZ;
    
    % Waterfall Plot
    waterfall(freqs(rel_idx), time_hours, spectra(:, rel_idx));
    
    title('3D-Wasserfalldarstellung der HRV-Spektren');
    xlabel('Frequenz (Hz)');
    ylabel('Zeit (Stunden)');
    zlabel('Spektrale Leistung (s^2/Hz)');
    
    view(VIEW_ANGLE); 
    colormap jet;
    
    % Markierung der HRV-Bänder als Text
    text_z_pos = max(spectra(:)) * TEXT_HEIGHT_FACTOR;
    text(mean(config.bands.lf), min(time_hours), text_z_pos, 'LF', 'Color', 'r', 'FontWeight', 'bold');
    text(mean(config.bands.hf), min(time_hours), text_z_pos, 'HF', 'Color', 'b', 'FontWeight', 'bold');
    
    saveas(gcf, fullfile(config.paths.results, 'waterfall_plot.png'));
end