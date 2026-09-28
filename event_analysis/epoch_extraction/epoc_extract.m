function [event_epocs, epoc_time, Time_points_incl] = epoc_extract(Time_points, trace_signal, trace_fs, varargin)

%EPOC_EXTRACT
% Input arguments:
%   Time_points: vector of time stamps (s) used for epoc analysis (default +/-60 s. To change epoc size, use 'time_before' and 'time_after' input arguments)
%   trace_signal: vector containing signal trace (e.e. delta465_filt) used for epoc analysis
%   trace_fs: sampling frequncy for trace_signal (Hz)
%
% Output arguments:
%   event_epocs: holds extracted EEG power bands (first column is time line)
%   epoc_time: time vector matching length of band_power_collector
%   Time_points_incl: vector of time stamps (s) included in epoc analysis
%   (if some time points are excluded due to proximity to trace end)

p = inputParser;

default_time_before = 60; % time in seconds leading up to event
default_time_after = 60; % time in seconds following event
default_ds_factor = 70; % downsample factor (try to aim for final (FP) vector lenght < 2000)
default_show_figure = true;

addRequired(p,'Time_points',@isnumeric);
addRequired(p,'trace_signal',@isnumeric);
addRequired(p,'trace_fs',@isnumeric);

addParameter(p, 'time_before', default_time_before, @isnumeric);
addParameter(p, 'time_after', default_time_after, @isnumeric);
addParameter(p, 'ds_factor', default_ds_factor, @isnumeric);
addParameter(p, 'show_figure', default_show_figure, @islogical);

parse(p, Time_points, trace_signal, trace_fs, varargin{:});

time_before = p.Results.time_before;
time_after = p.Results.time_after;
ds_factor =  p.Results.ds_factor;
show_figure = p.Results.show_figure;


Time_points_incl1 = Time_points((Time_points+time_after)*trace_fs < length(trace_signal));
Time_points_incl = Time_points_incl1((Time_points_incl1-time_before)*trace_fs > 0);

% event_epocs = zeros(ceil((time_before+time_after)*trace_fs), length(Time_points_incl));
n_samples = round((time_before + time_after) * trace_fs) + 1;   % fixed epoch length in samples, used for every trial
event_epocs = zeros(n_samples, length(Time_points_incl));       % preallocate to match n_samples exactly, not ceil(...)

for epoc_time_i=1:length(Time_points_incl)
    eopc_time = Time_points_incl(epoc_time_i);
    % create epoc trace
    % signal_epoc = trace_signal(round((eopc_time - time_before)*trace_fs):round((eopc_time + time_after)*trace_fs));  % replaced 2026-09-15
    n_samples = round((time_before + time_after) * trace_fs) + 1;
    start_idx = round((eopc_time - time_before) * trace_fs);    % single rounded start index (only one rounding op now)
    signal_epoc = trace_signal(start_idx : start_idx + n_samples - 1);  % always pulls exactly n_samples points
    event_epocs(:, epoc_time_i) = signal_epoc;                  % fills whole column, no leftover zero rows
end

% epoc_time = (1:1:length(signal_epoc))/trace_fs-time_before; % replaced 2026-09-15
epoc_time = (0:n_samples-1) / trace_fs - time_before;       % time axis built from n_samples, not last loop's signal_epoc
epoc_time_FP_ds = downsample(epoc_time,ds_factor);
epoc_mean_ds = downsample(mean(event_epocs,2), ds_factor);

if show_figure
    % figure
    % plot(epoc_time_FP_ds, epoc_mean_ds(:,1));
    % title('event - epoc mean')
    % xlabel('time (s)');

    % Compute SD across trials
    epoc_sd = std(event_epocs, 0, 2);
    epoc_sd_ds = downsample(epoc_sd, ds_factor);
        
    figure
    hold on
    % Plot SEM shaded region
    fill([epoc_time_FP_ds, fliplr(epoc_time_FP_ds)], ...
     [epoc_mean_ds(:,1)' + epoc_sd_ds', fliplr(epoc_mean_ds(:,1)' - epoc_sd_ds')], ...
     [0.7 0.7 1], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    % Plot mean trace on top
    plot(epoc_time_FP_ds, epoc_mean_ds(:,1), 'Color', [0.2 0.2 0.8], 'LineWidth', 1);
    title('event - epoc mean')
    xlabel('time (s)');
    legend('SD', 'Mean', 'Location', 'best');
    hold off
end
end
