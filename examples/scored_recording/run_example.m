%% Plot a real scored EEG/EMG/photometry excerpt.
% Open this file and press Run. Base MATLAB; no TDT loader required.
example_dir = fileparts(mfilename('fullpath'));
D = load(fullfile(example_dir, 'sample_data', 'example_scored_recording.mat'));

% Change these limits to inspect a shorter part of the 180-second excerpt.
plot_window_s = [0 double(D.duration_s)];
assert(numel(plot_window_s) == 2 && plot_window_s(1) >= 0 && ...
    plot_window_s(2) <= D.duration_s && plot_window_s(1) < plot_window_s(2), ...
    'Select an increasing time window within the excerpt.');

t_eeg = (0:numel(D.eeg)-1)' / double(D.eeg_frequency) + D.eeg_time_offset_s;
t_emg = (0:numel(D.emg)-1)' / double(D.emg_frequency) + D.emg_time_offset_s;
t_ne = (0:numel(D.ne)-1)' / double(D.ne_frequency) + D.ne_time_offset_s;
scores = double(D.sleep_scores(:));
epoch_s = double(D.sleep_epoch_s);
assert(numel(D.eeg) == numel(t_eeg) && numel(D.emg) == numel(t_emg));
assert(abs(numel(scores)*epoch_s - double(D.duration_s)) < 1e-8);
assert(all(ismember(scores, [0 1 2])), 'Unexpected sleep-state code.');

f = figure('Color','w','Name','Real scored recording','Position',[100 100 1200 800]);
ax(1) = subplot(4,1,1);
plot(t_eeg, D.eeg, 'Color',[0.14 0.30 0.44]);
ylabel({'EEG','(stored units)'}); grid on;
title('Real scored recording: 180-second excerpt');
ax(2) = subplot(4,1,2);
plot(t_emg, D.emg, 'Color',[0.36 0.38 0.42]);
ylabel({'EMG','(stored units)'}); grid on;
ax(3) = subplot(4,1,3);
plot(t_ne, D.ne, 'Color',[0.09 0.53 0.48]);
ylabel({'Stored ne channel','(stored units)'}); grid on;
ax(4) = subplot(4,1,4);
score_edges_s = (0:numel(scores))' * epoch_s;
stairs(score_edges_s, [scores; scores(end)], 'Color',[0.45 0.33 0.61], 'LineWidth',1.5);
set(gca,'YTick',[0 1 2],'YTickLabel',{'Wake','NREM','REM'});
ylim([-0.35 2.35]); ylabel('Scoring'); xlabel('Time from excerpt start (s)');
linkaxes(ax,'x'); xlim(ax(1),plot_window_s);

% Summary covers the entire excerpt, even when the plotted window is shorter.
state = {'Wake'; 'NREM'; 'REM'};
code = (0:2)';
duration_s = arrayfun(@(c) sum(scores == c)*epoch_s, code);
percent_scored = duration_s/sum(duration_s)*100;
summary = table(state, code, duration_s, percent_scored);
disp(summary);
assert(isequal(duration_s, [30; 90; 60]), 'The included data do not match the reference.');

output_dir = fullfile(example_dir,'generated_output');
if ~exist(output_dir,'dir'), mkdir(output_dir); end
writetable(summary,fullfile(output_dir,'state_summary.csv'));
print(f,fullfile(output_dir,'overview.png'),'-dpng','-r150');
fprintf('Saved overview and summary to: %s\n',output_dir);
