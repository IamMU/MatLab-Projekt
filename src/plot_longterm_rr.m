% =========================================================================
% Visualisiert das RR-Tachogramm über die gesamte Messdauer.
% Erstellt einen Scatter-Plot der RR-Intervalle gegen die Zeit (in Stunden).
% Markiert zudem die physiologischen Plausibilitätsgrenzen.
% =========================================================================
function plot_longterm_rr(rr_times, rr_intervals, config)
    % Konstanten
    SEC_TO_HOURS = 3600;
    FIG_POS      = [100, 100, 1000, 400];
    MARKER_SIZE  = 1.5;
    PLOT_COLOR   = [0, 0.4470, 0.7410];
    LOWER_LIMIT  = 0.3;  % 300 ms
    UPPER_LIMIT  = 1.5;  % 1500 ms
    Y_LIMITS     = [0.0, 2.0];
    LINE_WIDTH   = 1.5;

    time_hours = rr_times / SEC_TO_HOURS;
    
    figure('Name', 'Langfristiger RR-Verlauf (Tachogramm)', 'Position', FIG_POS);
    
    % Plot der RR-Intervalle
    plot(time_hours, rr_intervals, '.', 'MarkerSize', MARKER_SIZE, 'Color', PLOT_COLOR);
    
    title('Langfristiger Verlauf der RR-Intervalle (Tachogramm)');
    xlabel('Zeit (Stunden)');
    ylabel('RR-Intervall (Sekunden)');
    
    % Plausibilitätsgrenzen markieren gemäß Aufgabenstellung 
    yline(LOWER_LIMIT, 'r--', 'Untere Grenze (300 ms)', 'LabelHorizontalAlignment', 'left', 'LineWidth', LINE_WIDTH);
    yline(UPPER_LIMIT, 'r--', 'Obere Grenze (1500 ms)', 'LabelHorizontalAlignment', 'left', 'LineWidth', LINE_WIDTH);
    
    ylim(Y_LIMITS);
    grid on;
    
    saveas(gcf, fullfile(config.paths.results, 'longterm_rr_plot.png'));
end
