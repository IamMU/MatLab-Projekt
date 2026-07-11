% =======================================================================
% Identifiziert die R-Zacken im EKG-Signal.
% Nutzt einen robusten Schwellenwert basierend auf der Standardabweichung
% des Signals, um unempfindlich gegenüber einzelnen, massiven
% Bewegungsartefakten zu sein.
% =========================================================================
function [r_peaks_val, r_peaks_loc] = detect_r_peaks(ecg_signal, fs)
    % Konstanten
    MIN_RR_DIST_SEC = 0.3;         % Entspricht max. 200 BPM
    STD_MULTIPLIER  = 2.5;         % Primärer Schwellenwert-Faktor
    FALLBACK_PEAKS  = 10;          % Mindestanzahl für Fallback-Auslösung
    FALLBACK_MULT   = 1.0;         % Reduzierter Schwellenwert-Faktor

    % Minimaler Abstand zwischen Herzschlägen
    min_dist = round(MIN_RR_DIST_SEC * fs); 
    
    % Da das Signal im Preprocessing hochpassgefiltert wurde, schwankt es um 0.
    % Das 2.5-fache der Standardabweichung ist ein exzellenter Filter für 
    % saubere R-Zacken, der riesige Artefakte ignoriert.
    threshold = STD_MULTIPLIER * std(ecg_signal, 'omitnan');
    
    [r_peaks_val, r_peaks_loc] = findpeaks(ecg_signal, ...
        'MinPeakHeight', threshold, ...
        'MinPeakDistance', min_dist);
        
    % Sicherheits-Rückfall (Fallback), falls das Signal ungewöhnlich flach ist
    if length(r_peaks_loc) < FALLBACK_PEAKS
        fprintf('\n   [!] Warnung: Fast keine R-Zacken gefunden. Reduziere Schwellenwert...\n');
        threshold = FALLBACK_MULT * std(ecg_signal, 'omitnan');
        [r_peaks_val, r_peaks_loc] = findpeaks(ecg_signal, ...
            'MinPeakHeight', threshold, ...
            'MinPeakDistance', min_dist);
    end
    
    fprintf('   -> %d R-Zacken erfolgreich erkannt.\n', length(r_peaks_loc));
end
