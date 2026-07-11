clear; clc; close all;

% --- Konfiguration & Konstanten ---
src_dir = fileparts(mfilename('fullpath'));
config.paths.data = fullfile(src_dir, '..', 'data', '06-51-02.EDF');
config.paths.results = fullfile(src_dir, '..', 'assets');

% Preprocessing-Parameter
config.preproc.fs_target = 250; 
config.preproc.hp_cutoff = 0.5; 
config.preproc.lp_cutoff = 40;  
config.preproc.notch_freq = 50; 

% HRV-Parameter
config.hrv.interp_fs = 4; 
config.hrv.window_min = 5; 
config.hrv.window_sec = config.hrv.window_min * 60; 
config.hrv.overlap_pct = 0.50; 

% Frequenzbänder gemäß HRV-Leitlinie
config.bands.vlf = [0.0033, 0.04];
config.bands.lf  = [0.04, 0.15];
config.bands.hf  = [0.15, 0.40];

% Ordner für Ergebnisse erstellen, falls nicht vorhanden
if ~exist(config.paths.results, 'dir'), mkdir(config.paths.results); end

% Initialisierung der Performance-Statistiken
stats = struct();
mem_info = struct();

%% --- Pipeline Ausführung mit Performance-Analyse ---

% 1. Laden & Preprocessing
t_start = tic;
[ecg_signal, fs, t] = load_ecg_data(config.paths.data);
ecg_clean = preprocess_ecg(ecg_signal, fs, config);
stats.preprocess = toc(t_start);

% Speicherbedarf messen
info = whos('ecg_signal');
mem_info.ecg_bytes = info.bytes;

% 2. R-Peak Erkennung
t_start = tic;
[r_peaks_val, r_peaks_loc] = detect_r_peaks(ecg_clean, fs);
stats.peaks = toc(t_start);

% 3. RR-Intervalle & HRV-Berechnung
t_start = tic;
[rr_intervals, rr_times] = calculate_rr_intervals(r_peaks_loc, fs);
[rr_interp, t_interp] = interpolate_rr_signal(rr_intervals, rr_times, config);
[spectra, freqs, time_windows] = calculate_fft_spectrum(rr_interp, config);
hrv_results = calculate_hrv_bands(spectra, freqs, config);
stats.fft = toc(t_start);

% --- Visualisierung & Performance-Messung ---
t_start = tic;
fprintf('Erstelle Visualisierungen im chronologischen Ablauf...\n');

% Vorverarbeitung & Signalgüte (Aufgabe 2.2 & 2.3)
plot_preprocessing(t, ecg_signal, ecg_clean, config);
plot_r_peaks(t, ecg_clean, r_peaks_loc, r_peaks_val, config);

% RR-Intervalle (Zeitbereich) (Aufgabe 2.4)
plot_longterm_rr(rr_times, rr_intervals, config);
plot_rr_zoom(rr_times, rr_intervals, config);

% Frequenzbereich & Spektren (Aufgabe 2.9 & 2.10)
plot_waterfall(spectra, freqs, time_windows, config);
plot_hrv_trends(time_windows, hrv_results, config);

% Statistische Auswertung (Aufgabe 2.11)
compare_time_segments(time_windows, hrv_results, config);

stats.vis = toc(t_start);

% Performance-Bericht erstellen (Aufgabe 2.12)
analyse_performance(stats, mem_info, config);

fprintf('\nPipeline abgeschlossen. Alle Ergebnisse wurden im Ordner "%s" gespeichert!\n', config.paths.results);