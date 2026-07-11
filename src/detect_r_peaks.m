% =========================================================================
% Datei: detect_r_peaks.m
% Was sie macht: Identifiziert die R-Zacken im EKG-Signal.
% Wie sie es macht: Nutzt einen robusten Schwellenwert basierend auf der 
% Standardabweichung des Signals, um unempfindlich gegenüber einzelnen,
% massiven Bewegungsartefakten zu sein.
% =========================================================================
function [r_peaks_val, r_peaks_loc] = detect_r_peaks(ecg_signal, fs)
    % Minimaler Abstand zwischen Herzschlägen (z.B. 0.3s entspricht max. 200 BPM)
    % Wir nutzen round(), damit die Zahl für findpeaks ein Integer ist
    min_dist = round(0.3 * fs); 
    
    % ROBUSTER SCHWELLENWERT:
    % Da das Signal im Preprocessing hochpassgefiltert wurde, schwankt es um 0.
    % Das 2.5-fache der Standardabweichung ist ein exzellenter Filter für 
    % saubere R-Zacken, der riesige Artefakte ignoriert.
    threshold = 2.5 * std(ecg_signal, 'omitnan');
    
    [r_peaks_val, r_peaks_loc] = findpeaks(ecg_signal, ...
        'MinPeakHeight', threshold, ...
        'MinPeakDistance', min_dist);
        
    % Sicherheits-Rückfall (Fallback), falls das Signal ungewöhnlich flach ist
    if length(r_peaks_loc) < 10
        fprintf('\n   [!] Warnung: Fast keine R-Zacken gefunden. Reduziere Schwellenwert...\n');
        threshold = 1.0 * std(ecg_signal, 'omitnan');
        [r_peaks_val, r_peaks_loc] = findpeaks(ecg_signal, ...
            'MinPeakHeight', threshold, ...
            'MinPeakDistance', min_dist);
    end
    
    % Kleines Konsolen-Feedback, damit du siehst, dass es geklappt hat
    fprintf('   -> %d R-Zacken erfolgreich erkannt.\n', length(r_peaks_loc));
end