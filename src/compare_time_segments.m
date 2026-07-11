% =========================================================================
% Datei: compare_time_segments.m
% Was sie macht: Vergleicht statistisch verschiedene Zeitabschnitte.
% Wie sie es macht: Teilt die Daten z.B. in erste und zweite Hälfte (oder 
% Tag/Nacht) auf und erstellt Boxplots zum Vergleich der Parameter.
% =========================================================================
function compare_time_segments(time_windows, hrv_results, config)
    % Beispiel: Einfache Trennung in 1. Hälfte vs. 2. Hälfte der Messung
    mid_point = length(time_windows) / 2;
    
    group1_lfhf = hrv_results.lf_hf_ratio(1:floor(mid_point));
    group2_lfhf = hrv_results.lf_hf_ratio(ceil(mid_point):end);
    
    figure('Name', 'Segment Comparison', 'Position', [200 200 600 400]);
    
    % Auffüllen mit NaN, falls Vektoren ungleich lang
    max_len = max(length(group1_lfhf), length(group2_lfhf));
    g1 = [group1_lfhf; NaN(max_len - length(group1_lfhf), 1)];
    g2 = [group2_lfhf; NaN(max_len - length(group2_lfhf), 1)];
    
    boxplot([g1, g2], 'Labels', {'Abschnitt 1', 'Abschnitt 2'});
    title('Vergleich: LF/HF Ratio');
    ylabel('LF/HF Ratio');
    grid on;
    
    saveas(gcf, fullfile(config.paths.results, 'segment_comparison.png'));
end