function batchTable = fpqc_run_batch(cfgs)
%FPQC_RUN_BATCH Run FP QC on many TDT recordings.
%
% cfgs is a struct array. Each cfg needs:
%   recording_id, tdt_dir, chan_465, chan_405, output_dir

allRows = {};
for i = 1:numel(cfgs)
    cfg = cfgs(i);
    fprintf('\n[%d/%d] %s\n', i, numel(cfgs), cfg.recording_id);

    try
        raw = fpqc_load_tdt_streams(cfg);
        results = fpqc_compare_methods_from_raw(raw, cfg);
        names = fieldnames(results.metrics);

        for j = 1:numel(names)
            m = results.metrics.(names{j});
            allRows(end+1,:) = {cfg.recording_id, names{j}, m.fit_r2, m.fit_rmse, ...
                m.resid_corr_405, m.drift_per_hour, m.signal_sd, m.p95_minus_p5, "OK", ""}; %#ok<AGROW>
        end
    catch ME
        warning('Failed %s: %s', cfg.recording_id, ME.message);
        allRows(end+1,:) = {cfg.recording_id, "", NaN, NaN, NaN, NaN, NaN, NaN, "FAILED", string(ME.message)}; %#ok<AGROW>
    end
end

batchTable = cell2table(allRows, 'VariableNames', {'recording_id','method','fit_r2','fit_rmse', ...
    'resid_corr_405','drift_per_hour','signal_sd','p95_minus_p5','status','message'});

try
    outRoot = fileparts(cfgs(1).output_dir);
    writetable(batchTable, fullfile(outRoot, 'fpqc_batch_summary.csv'));
catch
    writetable(batchTable, fullfile(pwd, 'fpqc_batch_summary.csv'));
end
end
