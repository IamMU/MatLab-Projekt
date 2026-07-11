clear; clc; close all;

%---Konfiguration & Konstanten ---

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

% Ordner für Ergebnisse, falls nicht vorhanden
if ~exist(config.paths.results, 'dir'), mkdir(config.paths.results); end

%% --- Pipeline Ausführung ---
fprintf('Lade EKG Daten...\n');
[ecg_signal, fs, t] = load_ecg_data(config.paths.data);

fprintf('Vorverarbeitung des Signals...\n');
ecg_clean = preprocess_ecg(ecg_signal, fs, config);

fprintf('Erkenne R-Zacken...\n');
[r_peaks_val, r_peaks_loc] = detect_r_peaks(ecg_clean, fs);

fprintf('Berechne RR-Intervalle...\n');
[rr_intervals, rr_times] = calculate_rr_intervals(r_peaks_loc, fs);

fprintf('Interpoliere RR-Signal...\n');
[rr_interp, t_interp] = interpolate_rr_signal(rr_intervals, rr_times, config);

fprintf('Berechne gleitendes FFT-Spektrum...\n');
[spectra, freqs, time_windows] = calculate_fft_spectrum(rr_interp, config);

fprintf('Berechne HRV-Frequenzbänder...\n');
hrv_results = calculate_hrv_bands(spectra, freqs, config);

%% --- Visualisierung ---
fprintf('Erstelle Plots...\n');
plot_longterm_rr(rr_times, rr_intervals, config);
plot_waterfall(spectra, freqs, time_windows, config);
plot_hrv_trends(time_windows, hrv_results, config);
compare_time_segments(time_windows, hrv_results, config);

fprintf('Analyse erfolgreich abgeschlossen!\n');
