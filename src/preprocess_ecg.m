% =========================================================================
% Bereinigt das EKG-Signal von Störungen (Gleichanteil, Netzbrummen,
% Rauschen).
% Wendet nacheinander einen Highpass-Filter (gegen Baseline-Wanderung),
% einen Notch-Filter (gegen 50Hz-Netzbrummen) und einen Lowpass-Filter
% (gegen hochfrequentes Rauschen) an.
% =========================================================================
function ecg_clean = preprocess_ecg(ecg_signal, fs, config)
    % Konstanten
    NOTCH_Q_FACTOR = 35; % Gütefaktor für die Bandbreite des Notch-Filters

    % Entfernung von Gleichanteil / Baseline-Wanderung (Highpass)
    ecg_clean = highpass(ecg_signal, config.preproc.hp_cutoff, fs);
    
    % Unterdrückung von Netzbrummen (Notch)
    wo = config.preproc.notch_freq/(fs/2);  
    bw = wo/NOTCH_Q_FACTOR;
    [b, a] = iirnotch(wo, bw);
    ecg_clean = filtfilt(b, a, ecg_clean);
    
    % Hochfrequentes Rauschen filtern (Lowpass)
    ecg_clean = lowpass(ecg_clean, config.preproc.lp_cutoff, fs);
end