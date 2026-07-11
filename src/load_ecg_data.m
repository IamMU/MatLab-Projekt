% =========================================================================
% Datei: load_ecg_data.m
% Was sie macht: Importiert EKG-Datensätze im EDF-Format.
% Wie sie es macht: Nutzt die MATLAB-interne Funktion edfread, extrahiert 
% das erste verfügbare Signal und generiert einen Zeitvektor.
% =========================================================================
function [ecg_signal, fs, t] = load_ecg_data(filepath)
    info = edfinfo(filepath);
    tt = edfread(filepath);
    
    % Annahme: EKG liegt in der ersten Variable
    varNames = tt.Properties.VariableNames;
    ecg_signal = cell2mat(tt{:, 1}); 
    
    fs = info.NumSamples(1) / seconds(info.DataRecordDuration);
    t = (0:length(ecg_signal)-1) / fs;
end