% =========================================================================
% Datei: plot_hrv_trends.m
% Was sie macht: Visualisiert die zeitlichen Trends (LF, HF, LF/HF).
% Wie sie es macht: Erstellt gestapelte Subplots (plot), um die autonome 
% Regulation (Sympathikus/Parasympathikus) über den Langzeitverlauf zu zeigen.
% =========================================================================
function plot_hrv_trends(time_windows, hrv_results, config)
    time_hours = time_windows / 3600;
    
    figure('Name', 'HRV Trends', 'Position', [150 150 800 800]);
    
    subplot(3,1,1);
    plot(time_hours, hrv_results.lf_power, 'r', 'LineWidth', 1.5);
    title('LF Power (Sympathikus/Parasympathikus)');
    ylabel('Leistung'); grid on;
    
    subplot(3,1,2);
    plot(time_hours, hrv_results.hf_power, 'b', 'LineWidth', 1.5);
    title('HF Power (Parasympathikus)');
    ylabel('Leistung'); grid on;
    
    subplot(3,1,3);
    plot(time_hours, hrv_results.lf_hf_ratio, 'k', 'LineWidth', 1.5);
    title('LF/HF Ratio (Autonome Balance)');
    xlabel('Zeit (Stunden)'); ylabel('Ratio'); grid on;
    
    saveas(gcf, fullfile(config.paths.results, 'hrv_trends.png'));
end