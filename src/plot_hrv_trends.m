% =========================================================================
% Visualisiert die zeitlichen Trends (LF, HF, LF/HF).
% Erstellt gestapelte Subplots (plot), um die autonome Regulation
% (Sympathikus/Parasympathikus) über den Langzeitverlauf zu zeigen.
% =========================================================================
function plot_hrv_trends(time_windows, hrv_results, config)
    % Konstanten für die Visualisierung
    SEC_TO_HOURS = 3600;
    LINE_WIDTH   = 1.5;
    FIG_POS      = [150, 150, 800, 800];

    time_hours = time_windows / SEC_TO_HOURS;
    
    figure('Name', 'HRV Trends', 'Position', FIG_POS);
    
    subplot(3,1,1);
    plot(time_hours, hrv_results.lf_power, 'r', 'LineWidth', LINE_WIDTH);
    title('LF Power (Sympathikus/Parasympathikus)');
    ylabel('Leistung'); grid on;
    
    subplot(3,1,2);
    plot(time_hours, hrv_results.hf_power, 'b', 'LineWidth', LINE_WIDTH);
    title('HF Power (Parasympathikus)');
    ylabel('Leistung'); grid on;
    
    subplot(3,1,3);
    plot(time_hours, hrv_results.lf_hf_ratio, 'k', 'LineWidth', LINE_WIDTH);
    title('LF/HF Ratio (Autonome Balance)');
    xlabel('Zeit (Stunden)'); ylabel('Ratio'); grid on;
    
    saveas(gcf, fullfile(config.paths.results, 'hrv_trends.png'));
end