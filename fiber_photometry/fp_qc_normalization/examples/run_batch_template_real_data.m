%% run_batch_template_real_data.m
% Template for running FP QC on real TDT recordings.
%
% Copy this file, rename it for the project, and edit the cfgs entries.
% Do not commit local raw-data paths if they contain sensitive/private locations.

clear; clc;

%% Add toolbox path
thisFile = mfilename('fullpath');
[thisDir,~,~] = fileparts(thisFile);
toolboxDir = fullfile(thisDir, '..', 'matlab');
addpath(toolboxDir);

%% Output root
outRoot = fullfile(thisDir, '..', 'outputs_real_data');
if ~exist(outRoot, 'dir'); mkdir(outRoot); end

%% Define recordings
cfgs = struct([]);

cfgs(1).recording_id = 'mouse001_baseline';
cfgs(1).tdt_dir = 'N:\path\to\TDT\folder';
cfgs(1).chan_465 = 'x465A';
cfgs(1).chan_405 = 'x405A';
cfgs(1).analysis_interval_sec = [1000 20000];
cfgs(1).fit_interval_sec = [1000 20000];
cfgs(1).baseline_interval_sec = [1000 2000];
cfgs(1).slowTrendWinSec = 600;
cfgs(1).selected_method = 'linear_dff';
cfgs(1).output_dir = fullfile(outRoot, cfgs(1).recording_id);

% Add more recordings by duplicating:
% cfgs(2) = cfgs(1);
% cfgs(2).recording_id = 'mouse002_baseline';
% cfgs(2).tdt_dir = 'N:\path\to\other\TDT\folder';
% cfgs(2).chan_465 = 'x465C';
% cfgs(2).chan_405 = 'x405C';
% cfgs(2).output_dir = fullfile(outRoot, cfgs(2).recording_id);

%% Run
batchTable = fpqc_run_batch(cfgs);
disp(batchTable)
