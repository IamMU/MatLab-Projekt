% =========================================================================
% Überführt die unregelmäßigen RR-Intervalle in ein äquidistantes
% Signal für die spätere FFT.
% Nutzt interp1 (Spline-Interpolation), um die RR-Werte auf ein festes
% Zeitraster (z.B. 4 Hz) abzubilden.
% =========================================================================
function [rr_interp, t_interp] = interpolate_rr_signal(rr_intervals, rr_times, config)
    fs_interp = config.hrv.interp_fs;
    
    % Neues, gleichmäßiges Zeitraster erstellen
    t_interp = rr_times(1) : (1/fs_interp) : rr_times(end);
    
    % Spline-Interpolation
    rr_interp = interp1(rr_times, rr_intervals, t_interp, 'spline');
    
    % Mittelwert abziehen (Gleichanteil für FFT entfernen)
    rr_interp = rr_interp - mean(rr_interp);
end