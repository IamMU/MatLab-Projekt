% =========================================================================
% Bereinigt das EKG-Signal von Störungen (Gleichanteil, Netzbrummen,
% Rauschen).
% Wendet nacheinander einen Highpass-Filter (gegen Baseline-Wanderung),
% einen Butterworth-Bandstop (gegen 50Hz-Netzbrummen) und einen Lowpass-Filter
% (gegen hochfrequentes Rauschen) an.
% =========================================================================
function ecg_clean = preprocess_ecg(ecg_signal, fs, config)
    % Konstanten
    NOTCH_Q_FACTOR = 35; % Gütefaktor für die Bandbreite

    % Entfernung von Gleichanteil / Baseline-Wanderung (Highpass)
    ecg_clean = highpass(ecg_signal, config.preproc.hp_cutoff, fs);
    
    % Unterdrückung von 50Hz Netzbrummen (robuster Butterworth Bandstop)
    notch_freq = config.preproc.notch_freq;
    bw_hz = notch_freq / NOTCH_Q_FACTOR; % Bandbreite berechnen (ca. 1.4 Hz)
    
    % Kritische Frequenzen dynamisch mit fs normieren (0 bis 1)
    Wn = [(notch_freq - bw_hz/2), (notch_freq + bw_hz/2)] / (fs/2);
    
    % Butterworth-Bandsperre 2. Ordnung entwerfen und anwenden
    [b, a] = butter(2, Wn, 'stop');
    
    % WICHTIG: Filter auf ecg_clean anwenden, um den Highpass nicht zu überschreiben!
    ecg_clean = filtfilt(b, a, ecg_clean);
    
    % 3. Hochfrequentes Rauschen filtern (Lowpass)
    ecg_clean = lowpass(ecg_clean, config.preproc.lp_cutoff, fs);
end