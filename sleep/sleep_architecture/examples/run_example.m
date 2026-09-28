% New demonstration wrapper; original analysis script is unchanged.
module_dir = fileparts(fileparts(mfilename('fullpath')));
wake_woMA_periods_cut = readmatrix(fullfile(module_dir,'sample_data','wake_woMA_periods_cut.csv'));
sws_periods_cut = readmatrix(fullfile(module_dir,'sample_data','sws_periods_cut.csv'));
REM_periods_cut = readmatrix(fullfile(module_dir,'sample_data','REM_periods_cut.csv'));
MA_periods_cut = readmatrix(fullfile(module_dir,'sample_data','MA_periods_cut.csv'));
run(fullfile(module_dir,'sleep_quantification.m'));
figure; bar([percent_wake percent_NREM percent_REM percent_MA]);
set(gca,'XTickLabel',{'Wake','NREM','REM','MA'}); ylabel('Percent of scored time');
title('Synthetic sleep architecture');
disp(table(["Wake";"NREM";"REM";"MA"], ...
    [percent_wake;percent_NREM;percent_REM;percent_MA], ...
    'VariableNames',{'state','percent_scored'}));
