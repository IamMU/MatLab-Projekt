% =========================================================================
% Visualisiert das RR-Tachogramm über die gesamte Messdauer.
% Erstellt einen Scatter-Plot der RR-Intervalle gegen die Zeit (in Stunden).
% Markiert zudem die physiologischen Plausibilitätsgrenzen.
% =========================================================================
function plot_longterm_rr(rr_times, rr_intervals, config)
    time_hours = rr_times / 3600;
    
    figure('Name', 'Langfristiger RR-Verlauf (Tachogramm)', 'Position', [100 100 1000 400]);
    
    % Plot der RR-Intervalle
    plot(time_hours, rr_intervals, '.', 'MarkerSize', 1.5, 'Color', [0 0.4470 0.7410]);
    
    title('Langfristiger Verlauf der RR-Intervalle (Tachogramm)');
    xlabel('Zeit (Stunden)');
    ylabel('RR-Intervall (Sekunden)');
    
    % Plausibilitätsgrenzen markieren gemäß Aufgabenstellung 
    yline(0.3, 'r--', 'Untere Grenze (300 ms)', 'LabelHorizontalAlignment', 'left', 'LineWidth', 1.5);
    yline(1.5, 'r--', 'Obere Grenze (1500 ms)', 'LabelHorizontalAlignment', 'left', 'LineWidth', 1.5);
    
    ylim([0.0 2.0]);
    grid on;
    
    saveas(gcf, fullfile(config.paths.results, 'longterm_rr_plot.png'));
end