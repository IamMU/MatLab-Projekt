% =========================================================================
% Datei: plot_longterm_rr.m
% Was sie macht: Visualisiert das RR-Tachogramm über die gesamte Messdauer.
% Wie sie es macht: Erstellt einen Scatter-Plot der RR-Intervalle gegen die 
% Zeit (in Stunden). Markiert zudem die physiologischen Plausibilitätsgrenzen.
% =========================================================================
function plot_longterm_rr(rr_times, rr_intervals, config)
    % Zeit in Stunden umrechnen für bessere Übersichtlichkeit bei Langzeit-EKGs
    time_hours = rr_times / 3600;
    
    figure('Name', 'Langfristiger RR-Verlauf (Tachogramm)', 'Position', [100 100 1000 400]);
    
    % Plot der RR-Intervalle (Wir nutzen Punkte '.', da eine durchgezogene 
    % Linie bei >100.000 Punkten oft ein unleserliches schwarzes Feld ergibt)
    plot(time_hours, rr_intervals, '.', 'MarkerSize', 1.5, 'Color', [0 0.4470 0.7410]);
    
    title('Langfristiger Verlauf der RR-Intervalle (Tachogramm)');
    xlabel('Zeit (Stunden)');
    ylabel('RR-Intervall (Sekunden)');
    
    % Plausibilitätsgrenzen markieren gemäß Aufgabenstellung 
    % (RR-Intervalle außerhalb 300ms - 1500ms gelten als potenziell fehlerhaft)
    yline(0.3, 'r--', 'Untere Grenze (300 ms)', 'LabelHorizontalAlignment', 'left', 'LineWidth', 1.5);
    yline(1.5, 'r--', 'Obere Grenze (1500 ms)', 'LabelHorizontalAlignment', 'left', 'LineWidth', 1.5);
    
    % Achsen anpassen, um extreme Artefakte (falls vorhanden) abzuschneiden 
    % und den Fokus auf die physiologisch relevanten Daten zu legen
    ylim([0.0 2.0]);
    grid on;
    
    % Bild im Results-Ordner speichern
    saveas(gcf, fullfile(config.paths.results, 'longterm_rr_plot.png'));
end