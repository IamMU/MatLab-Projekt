% =========================================================================
% Erzeugt Zoomdarstellungen einzelner Zeitabschnitte des Tachogramms.
% Schneidet zwei 5-minütige Intervalle aus den RR-Zeiten und -Intervallen
% heraus (z.B. aus Stunde 2 und Stunde 10) und plottet diese untereinander,
% um die lokale Variabilität im Detail vergleichen zu können.
% =========================================================================
function plot_rr_zoom(rr_times, rr_intervals, config)
    % --- Konstanten ---
    ZOOM1_START_HOUR = 2;  % Beispiel: Frühe Phase (Nacht/Ruhe)
    ZOOM2_START_HOUR = 10; % Beispiel: Spätere Phase (Tag/Aktivität)
    ZOOM_DUR_MIN     = 5;  % 5 Minuten Dauer
    ZOOM_DUR_SEC     = ZOOM_DUR_MIN * 60;
    FIG_POS          = [200, 200, 1000, 600];

    % Umrechnung der RR-Zeiten in Stunden für die Indizierung
    time_hours = rr_times / 3600;

    % Logische Indizes für die beiden Zeitabschnitte
    idx1 = (rr_times >= (ZOOM1_START_HOUR * 3600)) & (rr_times <= (ZOOM1_START_HOUR * 3600 + ZOOM_DUR_SEC));
    idx2 = (rr_times >= (ZOOM2_START_HOUR * 3600)) & (rr_times <= (ZOOM2_START_HOUR * 3600 + ZOOM_DUR_SEC));

    figure('Name', 'RR-Tachogramm: Zoomdarstellungen', 'Position', FIG_POS);

    % Zoom 1 plotten (Anzeige in Minuten für bessere Lesbarkeit)
    subplot(2,1,1);
    plot(time_hours(idx1) * 60, rr_intervals(idx1), 'b.-'); 
    title(sprintf('Zoom 1: Zeitabschnitt ab Stunde %d (%d Minuten Dauer)', ZOOM1_START_HOUR, ZOOM_DUR_MIN));
    xlabel('Zeit (Minuten)'); ylabel('RR-Intervall (s)'); 
    grid on;

    % Zoom 2 plotten
    subplot(2,1,2);
    plot(time_hours(idx2) * 60, rr_intervals(idx2), 'r.-');
    title(sprintf('Zoom 2: Zeitabschnitt ab Stunde %d (%d Minuten Dauer)', ZOOM2_START_HOUR, ZOOM_DUR_MIN));
    xlabel('Zeit (Minuten)'); ylabel('RR-Intervall (s)'); 
    grid on;

    saveas(gcf, fullfile(config.paths.results, 'rr_zoom_plot.png'));
end