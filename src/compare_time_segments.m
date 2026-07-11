% =========================================================================
% Vergleicht statistisch verschiedene Zeitabschnitte.
% Teilt die Daten z.B. in erste und zweite Hälfte (oder Tag/Nacht) 
% auf und erstellt Boxplots zum Vergleich der Parameter.
% =========================================================================
function compare_time_segments(time_windows, hrv_results, config) 
    num_windows = length(time_windows);
    mid_point = floor(num_windows / 2);
    
    % Alle Daten als ein durchgehender Vektor
    all_lfhf = hrv_results.lf_hf_ratio;
    
    % Gruppierungsvariable erstellen: 1 für erste Hälfte, 2 für zweite Hälfte
    groups = ones(num_windows, 1);
    groups(mid_point + 1 : end) = 2;
    
    figure('Name', 'Segment Comparison', 'Position', [200 200 600 400]);
    
    % Boxplot mit Gruppierungsvariable 
    boxplot(all_lfhf, groups, 'Labels', {'Abschnitt 1', 'Abschnitt 2'});
    
    title('Vergleich: LF/HF Ratio');
    ylabel('LF/HF Ratio');
    grid on;
    
    saveas(gcf, fullfile(config.paths.results, 'segment_comparison.png'));
end
