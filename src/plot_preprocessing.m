% =========================================================================
% Visualisiert den Effekt der Vorverarbeitung an einem Beispielabschnitt.
% Schneidet einen definierten Zeitraum (z.B. 5 Sekunden) aus dem Signal
% über logische Indizierung heraus und vergleicht das Rohsignal mit dem 
% gefilterten Signal in zwei untereinanderliegenden Subplots.
% =========================================================================
function plot_preprocessing(t, ecg_signal, ecg_clean, config)
    % Konstanten
    SEGMENT_START_SEC = 3600; % Start bei Stunde 1
    SEGMENT_DUR_SEC   = 5;   
    FIG_POS           = [100, 100, 800, 600];

    % Zeitindex für den gewünschten Abschnitt ermitteln
    idx = (t >= SEGMENT_START_SEC) & (t <= (SEGMENT_START_SEC + SEGMENT_DUR_SEC));

    figure('Name', 'Vorverarbeitung: Roh vs. Gefiltert', 'Position', FIG_POS);
    
    % Rohsignal plotten
    subplot(2,1,1);
    plot(t(idx), ecg_signal(idx), 'Color', [0.5 0.5 0.5]);
    title('Rohsignal (mit Rauschen und Baseline-Wanderung)');
    xlabel('Zeit (s)'); ylabel('Amplitude'); 
    grid on;

    % Gefiltertes Signal plotten
    subplot(2,1,2);
    plot(t(idx), ecg_clean(idx), 'b');
    title('Gefiltertes Signal (nach Highpass, Notch und Lowpass)');
    xlabel('Zeit (s)'); ylabel('Amplitude'); 
    grid on;

    saveas(gcf, fullfile(config.paths.results, 'preprocessing_plot.png'));
end