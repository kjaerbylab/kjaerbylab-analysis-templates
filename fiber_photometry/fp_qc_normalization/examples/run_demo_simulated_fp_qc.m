%% run_demo_simulated_fp_qc.m
% Demo that anyone in the lab can run without TDT data.
%
% It generates a synthetic 405/465 signal with bleaching, motion artifacts,
% REM-like ACh events and a slow artifact bump, then compares normalization methods.

clear; clc; close all;

%% Add toolbox path
thisFile = mfilename('fullpath');
[thisDir,~,~] = fileparts(thisFile);
toolboxDir = fullfile(thisDir, '..', 'matlab');
addpath(toolboxDir);

%% Generate synthetic data
raw = fpqc_generate_simulated_signal( ...
    'durationSec', 3600, ...
    'fs', 20, ...
    'seed', 7);

%% Configure QC
cfg = struct();
cfg.recording_id = 'simulated_ACh_demo';
cfg.output_dir = fullfile(thisDir, '..', 'outputs', cfg.recording_id);

% Fit on the whole trace here. For real data, use a predefined clean interval.
cfg.fit_interval_sec = [0 3600];

% Baseline window used for baseline subtraction and z-score.
cfg.baseline_interval_sec = [60 600];

% Slow trend window for sensitivity analysis.
cfg.slowTrendWinSec = 600;

% Method for zoom/state plots.
cfg.selected_method = 'linear_dff';

% Optional common anchor. Here we use 0 for demonstration.
cfg.anchor_value = 0;

%% Run comparison
results = fpqc_compare_methods_from_raw(raw, cfg);

%% Open figures
figDir = fullfile(cfg.output_dir, 'figures');
fprintf('\nDemo complete. Look at figures here:\n%s\n', figDir);

try
    open(figDir)
catch
end
