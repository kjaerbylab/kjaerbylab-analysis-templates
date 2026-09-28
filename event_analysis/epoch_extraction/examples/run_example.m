% New demonstration wrapper; original function is unchanged.
module_dir = fileparts(fileparts(mfilename('fullpath')));
old_path = path; restore_path = onCleanup(@() path(old_path));
addpath(module_dir);
D = readmatrix(fullfile(module_dir,'sample_data','signal.csv'));
events_s = readmatrix(fullfile(module_dir,'sample_data','events.csv'));
[epochs,t,included] = epoc_extract(events_s,D(:,2),20, ...
    'time_before',10,'time_after',10,'ds_factor',1,'show_figure',false);
figure; plot(t,mean(epochs,2)); xlabel('Time from event (s)');
ylabel('Signal (a.u.)'); title('Synthetic event average');
disp(size(epochs)); disp(included);
clear restore_path
