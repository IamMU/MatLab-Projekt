% =========================================================================
% Berechnet die Abstände zwischen aufeinanderfolgenden R-Zacken.
% Bildet die Differenz (diff) der R-Zacken-Indizes und rechnet diese
% über die Abtastrate in Sekunden (Tachogramm) um.
% =========================================================================
function [rr_intervals, rr_times] = calculate_rr_intervals(r_peaks_loc, fs)
    rr_intervals = diff(r_peaks_loc) / fs; % in Sekunden
    rr_times = r_peaks_loc(2:end) / fs;    % Zeitstempel in Sekunden
end