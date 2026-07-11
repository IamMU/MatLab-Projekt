% =========================================================================
% Visualisiert die erkannte R-Zacken an einem kurzen Signalausschnitt.
% Extrahiert einen 10-Sekunden-Abschnitt des EKG-Signals und filtert
% parallel die Indizes der in diesem Zeitraum erkannten Peaks, um sie
% mit Markern (rote Sterne) über das Signal zu legen.
% =========================================================================
function plot_r_peaks(t, ecg_clean, r_peaks_loc, r_peaks_val, config)
    % Konstanten
    SEGMENT_START_SEC = 3600; 
    SEGMENT_DUR_SEC   = 10;  
    FIG_POS           = [150, 150, 800, 400];
    MARKER_STYLE      = 'r*';
    MARKER_SIZE       = 8;

    % Zeitindex für das Signal
    idx = (t >= SEGMENT_START_SEC) & (t <= (SEGMENT_START_SEC + SEGMENT_DUR_SEC));

    % Relevante R-Zacken für diesen Zeitabschnitt filtern
    idx_start = find(idx, 1, 'first');
    idx_end   = find(idx, 1, 'last');
    
    peak_mask = (r_peaks_loc >= idx_start) & (r_peaks_loc <= idx_end);
    t_peaks   = t(r_peaks_loc(peak_mask));
    val_peaks = r_peaks_val(peak_mask);

    figure('Name', 'R-Zacken Erkennung', 'Position', FIG_POS);
    plot(t(idx), ecg_clean(idx), 'b'); 
    hold on;
    
    % Peaks als rote Sterne markieren
    plot(t_peaks, val_peaks, MARKER_STYLE, 'MarkerSize', MARKER_SIZE);
    
    title('Automatische R-Zacken-Erkennung (10-Sekunden-Ausschnitt)');
    xlabel('Zeit (s)'); ylabel('Amplitude');
    legend('Gefiltertes EKG', 'Erkannte R-Zacken', 'Location', 'best'); 
    grid on;
    hold off;

    saveas(gcf, fullfile(config.paths.results, 'r_peaks_plot.png'));
end