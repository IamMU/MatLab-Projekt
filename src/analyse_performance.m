% =========================================================================
% Analysiert und visualisiert die Performance der HRV-Pipeline.
% Berechnet Laufzeiten für kritische Blöcke und schätzt den Speicherbedarf.
% =========================================================================
function analyse_performance(stats, mem_info, config)
    report_file = fullfile(config.paths.results, 'performance_report.txt');
    fid = fopen(report_file, 'w');
    
    header = '--- HRV-Projekt: Performance-Analyse ---\n';
    fprintf(header);
    fprintf(fid, header);
    
    % Laufzeiten
    fmt = '%-20s: %.4f Sekunden\n';
    fprintf(fmt, 'Vorverarbeitung', stats.preprocess);
    fprintf(fmt, 'R-Peak Erkennung', stats.peaks);
    fprintf(fmt, 'FFT-Berechnung', stats.fft);
    fprintf(fmt, 'Visualisierung', stats.vis);
    
    fprintf(fid, fmt, 'Vorverarbeitung', stats.preprocess);
    fprintf(fid, fmt, 'R-Peak Erkennung', stats.peaks);
    fprintf(fid, fmt, 'FFT-Berechnung', stats.fft);
    fprintf(fid, fmt, 'Visualisierung', stats.vis);
    
    % Speicherbedarf (Bytes in MB umrechnen)
    mem_mb = mem_info.ecg_bytes / (1024^2);
    fprintf('\nSpeicherbedarf (Rohsignal): %.2f MB\n', mem_mb);
    fprintf(fid, '\nSpeicherbedarf (Rohsignal): %.2f MB\n', mem_mb);
    
    fclose(fid);
    fprintf('\nPerformance-Bericht gespeichert unter: %s\n', report_file);
end