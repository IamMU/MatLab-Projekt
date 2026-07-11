% =========================================================================
% Datei: preprocess_ecg.m
% Was sie macht: Bereinigt das EKG-Signal von Störungen (Gleichanteil, 
% Netzbrummen, Rauschen).
% Wie sie es macht: Wendet nacheinander einen Highpass-Filter (gegen Baseline-
% Wanderung), einen Notch-Filter (gegen 50Hz-Netzbrummen) und einen Lowpass-
% Filter (gegen hochfrequentes Rauschen) an.
% =========================================================================
function ecg_clean = preprocess_ecg(ecg_signal, fs, config)
    % 1. Entfernung von Gleichanteil / Baseline-Wanderung (Highpass)
    ecg_clean = highpass(ecg_signal, config.preproc.hp_cutoff, fs);
    
    % 2. Unterdrückung von Netzbrummen (Notch)
    wo = config.preproc.notch_freq/(fs/2);  
    bw = wo/35;
    [b, a] = iirnotch(wo, bw);
    ecg_clean = filtfilt(b, a, ecg_clean);
    
    % 3. Hochfrequentes Rauschen filtern (Lowpass)
    ecg_clean = lowpass(ecg_clean, config.preproc.lp_cutoff, fs);
end