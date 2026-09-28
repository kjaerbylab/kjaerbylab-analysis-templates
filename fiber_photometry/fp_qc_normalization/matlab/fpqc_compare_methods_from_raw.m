function results = fpqc_compare_methods_from_raw(raw, cfg)
%FPQC_COMPARE_METHODS_FROM_RAW Compare FP methods from raw 405/465 vectors.
%
% Required raw fields:
%   raw.t
%   raw.fs
%   raw.signal_405
%   raw.signal_465
%
% Required cfg fields:
%   cfg.recording_id
%   cfg.output_dir

if ~isfield(cfg, 'recording_id') || isempty(cfg.recording_id)
    cfg.recording_id = 'fp_recording';
end
if ~isfield(cfg, 'output_dir') || isempty(cfg.output_dir)
    cfg.output_dir = fullfile(pwd, 'outputs', cfg.recording_id);
end
if ~exist(cfg.output_dir, 'dir'); mkdir(cfg.output_dir); end

cfg = fpqc_defaults(cfg);

[methods, metrics, fitInfo] = fpqc_apply_methods(raw, cfg);

figDir = fullfile(cfg.output_dir, 'figures');
if ~exist(figDir, 'dir'); mkdir(figDir); end
fpqc_make_qc_figures(raw, methods, metrics, fitInfo, cfg, figDir);

results = struct();
results.raw = raw;
results.cfg = cfg;
results.methods = methods;
results.metrics = metrics;
results.fitInfo = fitInfo;

save(fullfile(cfg.output_dir, [cfg.recording_id '_fpqc_results.mat']), 'results', '-v7.3');

T = fpqc_metrics_to_table(metrics, cfg.recording_id);
writetable(T, fullfile(cfg.output_dir, [cfg.recording_id '_fpqc_metrics.csv']));
fpqc_write_method_summary(cfg, T, fullfile(cfg.output_dir, [cfg.recording_id '_method_summary.txt']));

fprintf('Saved results in:\n%s\n', cfg.output_dir);
end

function cfg = fpqc_defaults(cfg)
if ~isfield(cfg, 'fit_interval_sec'); cfg.fit_interval_sec = []; end
if ~isfield(cfg, 'baseline_interval_sec') || isempty(cfg.baseline_interval_sec)
    cfg.baseline_interval_sec = [0 600];
end
if ~isfield(cfg, 'smoothWinSec') || isempty(cfg.smoothWinSec)
    cfg.smoothWinSec = 1;
end
if ~isfield(cfg, 'slowTrendWinSec') || isempty(cfg.slowTrendWinSec)
    cfg.slowTrendWinSec = 600;
end
if ~isfield(cfg, 'selected_method') || isempty(cfg.selected_method)
    cfg.selected_method = 'linear_dff';
end
if ~isfield(cfg, 'plotMaxPoints') || isempty(cfg.plotMaxPoints)
    cfg.plotMaxPoints = 60000;
end
end

function T = fpqc_metrics_to_table(metrics, recording_id)
names = fieldnames(metrics);
rows = cell(numel(names), 9);
for i = 1:numel(names)
    m = metrics.(names{i});
    rows(i,:) = {recording_id, names{i}, m.fit_r2, m.fit_rmse, m.resid_corr_405, ...
        m.drift_per_hour, m.signal_sd, m.p95_minus_p5, m.nan_fraction};
end
T = cell2table(rows, 'VariableNames', {'recording_id','method','fit_r2','fit_rmse', ...
    'resid_corr_405','drift_per_hour','signal_sd','p95_minus_p5','nan_fraction'});
end
