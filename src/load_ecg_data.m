% =========================================================================
% Importiert EKG-Datensätze im EDF-Format.
% Nutzt die MATLAB-interne Funktion edfread, extrahiert das erste verfügbare
% Signal und generiert einen Zeitvektor.
% =========================================================================
function [ecg_signal, fs, t] = load_ecg_data(filepath)
    % Konstanten
    DEFAULT_CH_IDX = 1; % Fallback, falls kein EKG-Name gefunden wird

    info = edfinfo(filepath);
    tt = edfread(filepath);
    
    % Dynamische Suche nach dem EKG-Kanal 
    varNames = tt.Properties.VariableNames;
    ecg_idx = find(contains(lower(varNames), 'ecg') | contains(lower(varNames), 'ekg'), 1);
    
    if isempty(ecg_idx)
        ecg_idx = DEFAULT_CH_IDX; % Fallback auf den ersten Kanal
    end
    
    % Extrahieren der Daten
    raw_data = tt{:, ecg_idx}; 
    if iscell(raw_data)
        ecg_signal = cell2mat(raw_data); 
    else
        ecg_signal = raw_data;
    end
    
    % Sicherstellen, dass das Signal ein sauberer Spaltenvektor ist
    ecg_signal = ecg_signal(:);
    
    % Metadaten berechnen
    fs = info.NumSamples(ecg_idx) / seconds(info.DataRecordDuration);
    
    % Zeitvektor als Spaltenvektor passend zum Signal generieren
    t = (0:length(ecg_signal)-1)' / fs;
end
