function fpqc_write_method_summary(cfg, T, outFile)
%FPQC_WRITE_METHOD_SUMMARY Write a human-readable method decision helper.

fid = fopen(outFile, 'w');
if fid < 0
    warning('Could not write summary file.');
    return
end

fprintf(fid, 'FP QC method summary\n');
fprintf(fid, 'Recording: %s\n\n', cfg.recording_id);

fprintf(fid, 'Recommended interpretation:\n');
fprintf(fid, '1. Start with linear_dff as the simplest standard correction.\n');
fprintf(fid, '2. Use robust_linear_dff if artifacts/outliers distort the linear fit.\n');
fprintf(fid, '3. Treat poly2_dff and slow detrending as sensitivity analyses unless independently justified.\n');
fprintf(fid, '4. Use zscore_after_linear_dff for event detection/timing, not as the only amplitude result.\n');
fprintf(fid, '5. Use baseline subtraction or anchored centering when amplitude differences should be preserved.\n\n');

fprintf(fid, 'Selected method in cfg: %s\n\n', cfg.selected_method);

fprintf(fid, 'Metrics table:\n');
fprintf(fid, '%s\n', evalc('disp(T)'));

fprintf(fid, '\nDecision should be based on figures + biology + sensitivity checks.\n');
fclose(fid);
end
