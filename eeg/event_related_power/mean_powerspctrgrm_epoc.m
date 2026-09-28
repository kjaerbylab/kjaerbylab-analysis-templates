
% Update 02-08-2026: includes dB output format and normalization to
% baseline periods
%
function [mean_spectrogram, epoc_spectrogram_collector, time_spectrogram_zero, F] = mean_powerspctrgrm_epoc(eeg_trace, sampling_frq, time_points, varargin)

%MEAN_POWERSPCTRGRM_EPOC
% Input arguments:
%   eeg_trace: full EEG trace to extract epoc spectrograms from
%   sampling_frq: sampling frequency (Hz) of eeg_trace
%   time_points: vector of time stamps (s) used for epoc analysis (default +/-60 s. To change epoc size, use 'before_epoc' and 'after_epoc' input arguments)
%   Optional Parameters:
%       - 'before_epoc' / 'after_epoc': window around each time point (default 60s each)
%       - 'window' / 'overlap_frac': spectrogram windowing (default 5s window, 0 overlap)
%       - 'smooth_sigma': gaussian smoothing sigma for the plotted heatmap (default 4)
%       - 'power_bands': unused directly here but kept for interface consistency
%       - 'output_units': 'log_magnitude' (default, matches original behavior),
%                        'log_power', or 'dB'. See NOTES below.
%       - 'normalization_periods': Nx2 matrix of [onset, offset] times (s) defining
%                        a baseline period (e.g. NREM bouts) to subtract before
%                        output-unit conversion. Default [] = no baseline
%                        subtraction (matches original behavior: absolute,
%                        unreferenced values).
%       - 'show_figure': display heatmap (default true)
%
% Output arguments:
%   mean_spectrogram: mean spectrum across epochs, in the units set by 'output_units'
%   epoc_spectrogram_collector: holds extracted raw complex STFT per epoch (unchanged by output_units)
%   time_spectrogram_zero: time vector with 0 at 'time_points'
%   F: frequency vector

% ===========================
%   NOTES ON OUTPUT UNITS
% ===========================
% spectrogram() returns the complex STFT, S. abs(S) is MAGNITUDE (e.g. uV),
% not power (uV^2) - power is abs(S).^2.
%
% 'log_magnitude' (default): log(abs(S)), exactly as in the original version
%                  of this function. Absolute, unreferenced log-magnitude in
%                  whatever units eeg_trace is in. NOT power, NOT baseline-
%                  relative. Kept as default so existing calls/plots/clim
%                  values reproduce unchanged.
% 'log_power':      log(abs(S).^2) = 2*log_magnitude. Absolute log-power,
%                  still unreferenced unless normalization_periods is given.
% 'dB':             log_power * (10/log(10)). Absolute dB, unreferenced
%                  unless normalization_periods is given.
%
% If 'normalization_periods' is supplied, a baseline mean (in the chosen
% output unit's underlying log space) is computed from those periods and
% subtracted, making the output relative to that baseline (0 = baseline for
% log_power/dB). If not supplied, output is absolute/unreferenced, same as
% the original function.

% ===========================
%   INPUT PARSER SETUP
% ===========================
p = inputParser;
addRequired(p, 'eeg_trace',    @isnumeric);
addRequired(p, 'sampling_frq', @isnumeric);
addRequired(p, 'time_points',  @isnumeric);
addParameter(p, 'before_epoc',   60,   @isnumeric);
addParameter(p, 'after_epoc',    60,   @isnumeric);
addParameter(p, 'window',        5,    @isnumeric);   % determins temporal resolution.
addParameter(p, 'overlap_frac',  0,    @isnumeric);   % no overlap ([] argument)
addParameter(p, 'smooth_sigma',  4,    @isnumeric);
addParameter(p, 'power_bands',   {[1,4],[4,8],[8,15],[15,30],[30,45],[65,80]}, @iscell);
addParameter(p, 'output_units',  'log_magnitude', @(x) any(validatestring(x, {'log_magnitude','log_power','dB'})));
addParameter(p, 'normalization_periods', [], @isnumeric);
addParameter(p, 'show_figure',   true, @islogical);
parse(p, eeg_trace, sampling_frq, time_points, varargin{:});

before_epoc  = p.Results.before_epoc;
after_epoc   = p.Results.after_epoc;
window       = p.Results.window;
overlap_frac = p.Results.overlap_frac;
smooth_sigma = p.Results.smooth_sigma;
power_bands  = p.Results.power_bands; %#ok<NASGU>
output_units = p.Results.output_units;
normalization_periods = p.Results.normalization_periods;
show_figure  = p.Results.show_figure;

win_samples     = round(sampling_frq * window);
noverlap        = round(win_samples * overlap_frac);  % explicit overlap
total_power_band = [0, power_bands{end}(end)]; %#ok<NASGU>

% ===========================
%   LOOP THROUGH EPOCHS
% ===========================
epoc_spectrogram_collector = [];
for epoc_time_number = 1:length(time_points)
    epoc_time = time_points(epoc_time_number);
    epoc_idx = round(epoc_time*sampling_frq);
    epoc_before_index = round(epoc_idx - sampling_frq*before_epoc);
    epoc_after_index = round(epoc_idx + sampling_frq*after_epoc);
    eeg_epoc_trace = eeg_trace(epoc_before_index:epoc_after_index);
    [epoc_spectrogram, F, T] = spectrogram(eeg_epoc_trace, win_samples, noverlap,[],sampling_frq,'yaxis'); % F = frequenciy vector, T=time vector
    epoc_spectrogram_collector = cat(3, epoc_spectrogram_collector, epoc_spectrogram);
end
time_spectrogram_zero = T-before_epoc; % to get REM onset at 0 instead of 300

% ===========================
%   CONVERT TO REQUESTED OUTPUT UNIT (absolute, unreferenced so far)
% ===========================
switch output_units
    case 'log_magnitude'
        log_spectrogram_collector = log(abs(epoc_spectrogram_collector));
    case {'log_power','dB'}
        log_spectrogram_collector = log(abs(epoc_spectrogram_collector).^2);
end

mean_spectrogram = nanmean(log_spectrogram_collector, 3);

% ===========================
%   OPTIONAL BASELINE SUBTRACTION
% ===========================
if ~isempty(normalization_periods)
    baseline_values = [];
    for period_i = 1:size(normalization_periods, 1)
        on_s  = normalization_periods(period_i, 1);
        off_s = normalization_periods(period_i, 2);
        on_idx  = max(1, round(on_s * sampling_frq));
        off_idx = min(length(eeg_trace), round(off_s * sampling_frq));
        if off_idx <= on_idx || (off_idx - on_idx + 1) < win_samples
            continue % too short or invalid, skip
        end
        period_trace = eeg_trace(on_idx:off_idx);
        [period_spectrogram, ~, ~] = spectrogram(period_trace, win_samples, noverlap, [], sampling_frq, 'yaxis');
        switch output_units
            case 'log_magnitude'
                log_period_spectrogram = log(abs(period_spectrogram));
            case {'log_power','dB'}
                log_period_spectrogram = log(abs(period_spectrogram).^2);
        end
        baseline_values = [baseline_values; log_period_spectrogram(:)]; %#ok<AGROW>
    end
    if isempty(baseline_values)
        warning('No valid normalization_periods data found; output left unreferenced (absolute).');
    else
        mean_spectrogram = mean_spectrogram - mean(baseline_values);
    end
end

% ===========================
%   dB SCALING (applied after any baseline subtraction)
% ===========================
if strcmp(output_units, 'dB')
    mean_spectrogram = mean_spectrogram * (10 / log(10));
end

% ===========================
%   OPTIONAL PLOTTING
% ===========================
if show_figure
    figure()
    filtered_mean_spectrogram = imgaussfilt(mean_spectrogram, smooth_sigma);  % scaled sigma
    imagesc(time_spectrogram_zero, F, filtered_mean_spectrogram); %plot the log spectrum
    set(gca,'YDir', 'normal'); % flip the Y Axis so lower frequencies are at the bottom
%     ylim([60, 80]);
%     clim([-8.5, -7.5])
    ylim([0, 30]); % low gamma and below
    % NOTE: clim ranges below were tuned for the original 'log_magnitude',
    % unreferenced output. If you switch output_units and/or supply
    % normalization_periods, re-tune clim to the new value range.
    % clim([-3, 2])
    clims_high = [min(mean_spectrogram), max(mean_spectrogram)];
% clim([-9, -4.5])
% ylim([60, 100]); % high gamma
% clim([-8.5, -7.5])
    h = colorbar;
    switch output_units
        case 'log_magnitude'
            ylabel(h, 'log(magnitude)');
        case 'log_power'
            ylabel(h, 'log(power)');
        case 'dB'
            if ~isempty(normalization_periods)
                ylabel(h, 'Power (dB)');
            else
                ylabel(h, 'Power (dB, absolute)');
            end
    end
    title('mean spectrogram');
    colormap(gca, 'inferno');
end
end
%}

%% Old version
% output was in log(V) not power and no normalization
%{
% eeg_trace = EEG_rawtrace_cut;
% sampling_frq = sampling_freq;
% time_points = NEtrigger_As_onset;
% before_epoc = 60;
% after_epoc = 60;
% power_bands = {[1, 4], [4, 8], [8, 15], [15, 30] [30,45] [65, 80]};
% show_figure = true;

function [mean_spectrogram, epoc_spectrogram_collector, time_spectrogram_zero, F] = mean_powerspctrgrm_epoc(eeg_trace, sampling_frq, time_points, varargin)

%MEAN_POWERSPCTRGRM_EPOC
% Input arguments:
%   eeg_trace: full EEG trace to extract epoc spectrograms from
%   sampling_frq: sampling frequency (Hz) of eeg_trace
%   time_points: vector of time stamps (s) used for epoc analysis (default +/-60 s. To change epoc size, use 'before_epoc' and 'after_epoc' input arguments)
%
% Output arguments:
%   mean_spectrogram: mean log spectrum
%   epoc_spectrogram_collector: holds extracted EEG powerspectrogram
%   time_spectrogram_zero: time vector with 0 at 'time_points'

p = inputParser;
addRequired(p, 'eeg_trace',    @isnumeric);
addRequired(p, 'sampling_frq', @isnumeric);
addRequired(p, 'time_points',  @isnumeric);
addParameter(p, 'before_epoc',   60,   @isnumeric);
addParameter(p, 'after_epoc',    60,   @isnumeric);
addParameter(p, 'window',        5,    @isnumeric);   % determins temporal resolution.
addParameter(p, 'overlap_frac',  0,    @isnumeric);   % no overlap ([] argument)
addParameter(p, 'smooth_sigma',  4,    @isnumeric);   
addParameter(p, 'power_bands',   {[1,4],[4,8],[8,15],[15,30],[30,45],[65,80]}, @iscell);
addParameter(p, 'show_figure',   true, @islogical);

parse(p, eeg_trace, sampling_frq, time_points, varargin{:});

before_epoc  = p.Results.before_epoc;
after_epoc   = p.Results.after_epoc;
window       = p.Results.window;
overlap_frac = p.Results.overlap_frac;
smooth_sigma = p.Results.smooth_sigma;
power_bands  = p.Results.power_bands;
show_figure  = p.Results.show_figure;

win_samples     = round(sampling_frq * window);
noverlap        = round(win_samples * overlap_frac);  % explicit overlap

total_power_band = [0, power_bands{end}(end)];

epoc_spectrogram_collector = [];
for epoc_time_number = 1:length(time_points)
    epoc_time = time_points(epoc_time_number);
    epoc_idx = round(epoc_time*sampling_frq);
    epoc_before_index = round(epoc_idx - sampling_frq*before_epoc);
    epoc_after_index = round(epoc_idx + sampling_frq*after_epoc);
    eeg_epoc_trace = eeg_trace(epoc_before_index:epoc_after_index);
    [epoc_spectrogram, F, T] = spectrogram(eeg_epoc_trace, win_samples, noverlap,[],sampling_frq,'yaxis'); % F = frequenciy vector, T=time vector
    epoc_spectrogram_collector = cat(3, epoc_spectrogram_collector, epoc_spectrogram);
end

mean_spectrogram = nanmean(log(abs(epoc_spectrogram_collector)), 3);
time_spectrogram_zero = T-before_epoc; % to get REM onset at 0 instead of 300

if show_figure
    figure()
    filtered_mean_spectrogram = imgaussfilt(mean_spectrogram, smooth_sigma);  % scaled sigma
    imagesc(time_spectrogram_zero, F, filtered_mean_spectrogram); %plot the log spectrum
    set(gca,'YDir', 'normal'); % flip the Y Axis so lower frequencies are at the bottom
%     ylim([60, 80]);
%     clim([-8.5, -7.5])
    ylim([0, 30]); % low gamma and below
    clim([-3, 2])
    % clim([-9, -4.5])
    % ylim([60, 100]); % high gamma
    % clim([-8.5, -7.5])

    h = colorbar;
    title('mean spectrogram');
    colormap(gca, 'inferno');
end

end
%}