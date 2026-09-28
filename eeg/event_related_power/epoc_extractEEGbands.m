% updated on 2026-08-01
% This version included dB as output format and corrected power (^2)
% transformation of spectrogram output to both log_ratio and percent
% outputs

function [norm_band_power_epocs, time_spectrogram_zero, spectro_fs] = epoc_extractEEGbands(Time_points, EEG_trace, EEG_fs, varargin)

%EPOC_EXTRACTEEGBANDS
% This function extracts power band epochs from EEG or LFP traces, allowing 
% for optimized windowing and resolution settings suitable for faster signals.

% Input arguments:
%   Time_points: vector of time stamps (s) used for epoc analysis (default +/-60 s. 
%                To change epoc size, use 'time_before' and 'time_after' input arguments)
%   EEG_trace: the EEG or LFP trace you want to perform epoc analysis on 
%   EEG_fs: sampling frequency of the trace
%   Optional Parameters:
%       - 'power_bands': specify power bands in a cell array (default EEG bands: 
%                        delta, theta, sigma, beta, gamma lo, gamma hi)
%       - 'time_before': time in seconds leading up to event (default 60s)
%       - 'time_after': time in seconds following event (default 60s)
%       - 'analysis_window': window size for spectrogram analysis (default 5s for EEG, 0.5s recommended for LFP)
%       - 'window_overlap': overlap ratio for windowing (default 0.5, recommended 0.8 for LFP)
%       - 'normalization_periods': Nx2 matrix of [onset, offset] times (s) defining
%                        periods to use as the baseline for normalization (e.g. NREM
%                        bouts), independent of the epoch windows. If not provided,
%                        baseline is computed per band by pooling across all extracted
%                        epochs instead (see notes below).
%       - 'output_units': 'dB' (default), 'log_ratio', or 'percent'. All three
%                        express power relative to baseline_mean(band); they
%                        differ only in scale (see NORMALIZATION NOTES below).
%       - 'show_figure': display results (default true)

% Output arguments:
%   norm_band_power_epocs: 3D array of epoc bands (D1 is +/- 60 s epoc trace, D2 is the epoc number, D3 is EEG band)
%   time_spectrogram_zero: time vector matching length of norm_band_power_epocs
%   spectro_fs: sampling frequency of time_spectrogram_zero.

% ===========================
%   NORMALIZATION NOTES
% ===========================
% spectrogram() returns the complex STFT, S. abs(S) is MAGNITUDE, not power -
% power is abs(S).^2. This version squares explicitly so that "power" in the
% variable names (log_power, band_power_trace, etc.) is actually true power,
% not magnitude. (Previous versions took log(abs(S)) directly, which is a
% log-MAGNITUDE ratio - fine internally as long as you're consistent, but it
% mismatched the docstring/variable naming, which described everything as
% power.)
%
% Normalization is a log-domain baseline SUBTRACTION rather than a division:
%   norm_band(f in band, t, epoch) = log_power(f,t,epoch) - baseline_mean(band)
% This is the correct way to express "power relative to baseline" when already
% working in log space (subtracting logs = dividing raw power by baseline power).
%
% Three equivalent output scalings of that same log-power ratio are available
% via 'output_units':
%   'dB'        (default) = ratio * (10/log(10))  -> 0 = baseline, +3.01/-3.01 = double/half power
%   'log_ratio'            = ratio, unscaled       -> 0 = baseline, +/-log(2) = double/half power
%   'percent'               = 100*exp(ratio)        -> 100 = baseline, 200 = double, 50 = half
%
% If 'normalization_periods' is supplied, baseline_mean(band) is computed from
% spectrograms of those periods (e.g. NREM bouts) directly from the raw trace -
% not from a resampled continuous power trace - avoiding fs/rounding misalignment.
%
% If 'normalization_periods' is NOT supplied, baseline_mean(band) falls back to
% pooling across all extracted epochs (time + epoch dimensions), same as before,
% just done separately per band now instead of with one global scalar. Note this
% fallback is still somewhat circular if Time_points mark the events of interest,
% since the baseline then partly reflects those events. Use 'normalization_periods'
% whenever a state-defined baseline (e.g. NREM) is available.

% ===========================
%   INPUT PARSER SETUP
% ===========================
p = inputParser;

% Default parameters
default_power_bands = {[1, 4], [4, 8], [8, 15], [15, 30], [30,45], [65, 80]};
default_time_before = 60;
default_time_after = 60;
default_analysis_window = 5; 
default_window_overlap = 0.5;
default_normalization_periods = [];
default_output_units = 'dB';
default_show_figure = true;

% Adding parameters to parser
addRequired(p,'Time_points',@isnumeric);
addRequired(p,'EEG_trace',@isnumeric);
addRequired(p,'EEG_fs',@isnumeric);

addParameter(p, 'power_bands', default_power_bands, @iscell);
addParameter(p, 'time_before', default_time_before, @isnumeric);
addParameter(p, 'time_after', default_time_after, @isnumeric);
addParameter(p, 'analysis_window', default_analysis_window, @isnumeric);
addParameter(p, 'window_overlap', default_window_overlap, @isnumeric);
addParameter(p, 'normalization_periods', default_normalization_periods, @isnumeric);
addParameter(p, 'output_units', default_output_units, @(x) any(validatestring(x, {'dB','log_ratio','percent'})));
addParameter(p, 'show_figure', default_show_figure, @islogical);

% Parse inputs
parse(p, Time_points, EEG_trace, EEG_fs, varargin{:});

% Retrieve parameters
power_bands = p.Results.power_bands;
time_before = p.Results.time_before;
time_after = p.Results.time_after;
analysis_window = p.Results.analysis_window;
window_overlap = p.Results.window_overlap;
normalization_periods = p.Results.normalization_periods;
output_units = p.Results.output_units;
show_figure = p.Results.show_figure;

% ===========================
%   FREQUENCY & TIME SETUP
% ===========================
total_power_band = [0, power_bands{end}(end)];
frw = 0:0.5:total_power_band(end); 
spectro_fs = 1/(analysis_window * (1 - window_overlap));
noverlap_samples = round(EEG_fs * analysis_window * window_overlap);
window_samples = round(EEG_fs * analysis_window);

% ===========================
%   VALIDATE TIME POINTS
% ===========================
Time_points_incl = Time_points((Time_points + time_after) * EEG_fs < length(EEG_trace));
Time_points_incl = Time_points_incl(Time_points_incl - time_before > 0);

% Preallocate
% Dummy spectrogram to get the exact time vector length
dummy_trace = zeros(1, round((time_before + time_after) * EEG_fs));
[~, ~, T] = spectrogram(dummy_trace, window_samples, noverlap_samples, frw, EEG_fs, 'yaxis');

% Preallocate based on actual T length
band_power_trace = zeros(length(T), length(Time_points_incl), length(power_bands));
spectrogram_epocs = [];

% ===========================
%   LOOP THROUGH EPOCHS
% ===========================
for epoc_time_i = 1:length(Time_points_incl)
    epoc_time = Time_points_incl(epoc_time_i);
    eeg_epoc = EEG_trace(round((epoc_time - time_before) * EEG_fs):round((epoc_time + time_after) * EEG_fs));

    % Spectrogram computation
    [epoc_spectrogram, F, T] = spectrogram(eeg_epoc, window_samples, noverlap_samples, frw, EEG_fs, 'yaxis');
    log_epoc_spectrogram = log(abs(epoc_spectrogram).^2);  % true power (magnitude^2), not magnitude
    spectrogram_epocs = cat(3, spectrogram_epocs, epoc_spectrogram);

    % Extract power bands (raw log power, not yet baseline-corrected)
    for band_i = 1:length(power_bands)
        band = power_bands{band_i};
        band_epoc = mean(log_epoc_spectrogram(F >= band(1) & F <= band(2), :), 1);
        band_power_trace(1:length(band_epoc), epoc_time_i, band_i) = band_epoc;
    end
end

% ===========================
%   BASELINE (PER BAND)
% ===========================
baseline_mean = zeros(1, length(power_bands));

if ~isempty(normalization_periods)
    % --- Baseline from independently defined periods (e.g. NREM bouts) ---
    % Computed directly from spectrograms of the raw trace segments, avoiding
    % any resampled/continuous power trace and its fs-alignment problems.
    n_skipped_short = 0;
    for band_i = 1:length(power_bands)
        band = power_bands{band_i};
        band_values = [];
        for period_i = 1:size(normalization_periods, 1)
            on_s  = normalization_periods(period_i, 1);
            off_s = normalization_periods(period_i, 2);
            on_idx  = max(1, round(on_s * EEG_fs));
            off_idx = min(length(EEG_trace), round(off_s * EEG_fs));
            if off_idx <= on_idx
                continue
            end
            period_trace = EEG_trace(on_idx:off_idx);

            % Skip periods too short to fit a single analysis window -
            % spectrogram() errors if the segment is shorter than window_samples
            if length(period_trace) < window_samples
                if band_i == 1
                    n_skipped_short = n_skipped_short + 1;
                end
                continue
            end

            [period_spectrogram, F_period, ~] = spectrogram(period_trace, window_samples, noverlap_samples, frw, EEG_fs, 'yaxis');
            log_period_spectrogram = log(abs(period_spectrogram).^2);  % true power
            filtered_period_spectrogram = imgaussfilt(log_period_spectrogram, 4);

            band_mask = F_period >= band(1) & F_period <= band(2);
            band_values = [band_values, reshape(filtered_period_spectrogram(band_mask, :), 1, [])]; %#ok<AGROW>
        end
        if isempty(band_values)
            warning('No valid normalization_periods data found for band %d; falling back to epoch pooling for this band.', band_i);
            filtered_epoc_spectrogram = imgaussfilt(log(abs(spectrogram_epocs).^2), 4);
            band_mask = F >= band(1) & F <= band(2);
            baseline_mean(band_i) = mean(reshape(filtered_epoc_spectrogram(band_mask, :, :), 1, []));
        else
            baseline_mean(band_i) = mean(band_values);
        end
    end
    if n_skipped_short > 0
        warning('%d of %d normalization_periods were shorter than analysis_window (%.2fs) and were skipped.', ...
            n_skipped_short, size(normalization_periods,1), analysis_window);
    end
else
    % --- Fallback: baseline pooled across all extracted epochs, per band ---
    filtered_epoc_spectrogram = imgaussfilt(log(abs(spectrogram_epocs).^2), 4);
    for band_i = 1:length(power_bands)
        band = power_bands{band_i};
        band_mask = F >= band(1) & F <= band(2);
        baseline_mean(band_i) = mean(reshape(filtered_epoc_spectrogram(band_mask, :, :), 1, []));
    end
end

% ===========================
%   NORMALIZATION & OUTPUT
% ===========================
% Log-domain baseline subtraction per band (equivalent to power/baseline ratio)
norm_band_power_epocs = zeros(size(band_power_trace));
for band_i = 1:length(power_bands)
    norm_band_power_epocs(:, :, band_i) = band_power_trace(:, :, band_i) - baseline_mean(band_i);
end

% Convert units if requested.
%   'dB'        (default): ratio * (10/log(10)) -> 0 = baseline, +/-3.01 dB = double/half power
%   'log_ratio'           : leaves values as-is, log(power/baseline), 0 = baseline
%   'percent'             : exponentiates back out of log space, 100 = baseline
switch output_units
    case 'dB'
        norm_band_power_epocs = norm_band_power_epocs * (10 / log(10));
    case 'percent'
        norm_band_power_epocs = 100 * exp(norm_band_power_epocs);
    % 'log_ratio' needs no further conversion
end

time_spectrogram_zero = T - time_before;

% ===========================
%   OPTIONAL PLOTTING
% ===========================
if show_figure
    figure
    for plot_number = 1:length(power_bands)
        subplot(length(power_bands), 1, plot_number);
        plot(time_spectrogram_zero, squeeze(mean(norm_band_power_epocs(:,:,plot_number), 2)));
        title(['Band ', num2str(power_bands{plot_number}(1)), '-', num2str(power_bands{plot_number}(2)), ' Hz']);
        switch output_units
            case 'dB'
                ylabel('Power (dB)');
            case 'percent'
                ylabel('% of baseline');
            otherwise
                ylabel('log(power/baseline)');
        end
    end
end
end

%% Old version
% updated on 2026-07-28
% This version fixed issues with normalization in previous version: Now
% normalization is done wihtin frequency band and normalization factor is
% now subtracted from log(power) instead of dividing by it, consistent with
% math principles when working in log space.
% NB! when no normalization_periods are input the function still defaults
% to use only EEG from all epoch as normalization window.

%{
function [norm_band_power_epocs, time_spectrogram_zero, spectro_fs] = epoc_extractEEGbands(Time_points, EEG_trace, EEG_fs, varargin)

%EPOC_EXTRACTEEGBANDS
% This function extracts power band epochs from EEG or LFP traces, allowing 
% for optimized windowing and resolution settings suitable for faster signals.

% Input arguments:
%   Time_points: vector of time stamps (s) used for epoc analysis (default +/-60 s. 
%                To change epoc size, use 'time_before' and 'time_after' input arguments)
%   EEG_trace: the EEG or LFP trace you want to perform epoc analysis on 
%   EEG_fs: sampling frequency of the trace
%   Optional Parameters:
%       - 'power_bands': specify power bands in a cell array (default EEG bands: 
%                        delta, theta, sigma, beta, gamma lo, gamma hi)
%       - 'time_before': time in seconds leading up to event (default 60s)
%       - 'time_after': time in seconds following event (default 60s)
%       - 'analysis_window': window size for spectrogram analysis (default 5s for EEG, 0.5s recommended for LFP)
%       - 'window_overlap': overlap ratio for windowing (default 0.5, recommended 0.8 for LFP)
%       - 'normalization_periods': Nx2 matrix of [onset, offset] times (s) defining
%                        periods to use as the baseline for normalization (e.g. NREM
%                        bouts), independent of the epoch windows. If not provided,
%                        baseline is computed per band by pooling across all extracted
%                        epochs instead (see notes below).
%       - 'output_units': 'log_ratio' (default) or 'percent'. 'log_ratio' returns
%                        log(power/baseline), centered at 0 (0 = baseline, +/-log(2)
%                        = double/half baseline). 'percent' returns 100*power/baseline,
%                        centered at 100 (100 = baseline, 200 = double, 50 = half).
%       - 'show_figure': display results (default true)

% Output arguments:
%   norm_band_power_epocs: 3D array of epoc bands (D1 is +/- 60 s epoc trace, D2 is the epoc number, D3 is EEG band)
%   time_spectrogram_zero: time vector matching length of norm_band_power_epocs
%   spectro_fs: sampling frequency of time_spectrogram_zero.

% ===========================
%   NORMALIZATION NOTES
% ===========================
% Normalization is now done PER BAND (not pooled across all bands with a single
% scalar), and is a log-domain baseline SUBTRACTION rather than a division:
%   norm_band(f in band, t, epoch) = log_power(f,t,epoch) - baseline_mean(band)
% This is the correct way to express "power relative to baseline" when already
% working in log space (subtracting logs = dividing raw power by baseline power).
%
% If 'normalization_periods' is supplied, baseline_mean(band) is computed from
% spectrograms of those periods (e.g. NREM bouts) directly from the raw trace -
% not from a resampled continuous power trace - avoiding fs/rounding misalignment.
%
% If 'normalization_periods' is NOT supplied, baseline_mean(band) falls back to
% pooling across all extracted epochs (time + epoch dimensions), same as before,
% just done separately per band now instead of with one global scalar. Note this
% fallback is still somewhat circular if Time_points mark the events of interest,
% since the baseline then partly reflects those events. Use 'normalization_periods'
% whenever a state-defined baseline (e.g. NREM) is available.

% ===========================
%   INPUT PARSER SETUP
% ===========================
p = inputParser;

% Default parameters
default_power_bands = {[1, 4], [4, 8], [8, 15], [15, 30], [30,45], [65, 80]};
default_time_before = 60;
default_time_after = 60;
default_analysis_window = 5; 
default_window_overlap = 0.5;
default_normalization_periods = [];
default_output_units = 'log_ratio';
default_show_figure = true;

% Adding parameters to parser
addRequired(p,'Time_points',@isnumeric);
addRequired(p,'EEG_trace',@isnumeric);
addRequired(p,'EEG_fs',@isnumeric);

addParameter(p, 'power_bands', default_power_bands, @iscell);
addParameter(p, 'time_before', default_time_before, @isnumeric);
addParameter(p, 'time_after', default_time_after, @isnumeric);
addParameter(p, 'analysis_window', default_analysis_window, @isnumeric);
addParameter(p, 'window_overlap', default_window_overlap, @isnumeric);
addParameter(p, 'normalization_periods', default_normalization_periods, @isnumeric);
addParameter(p, 'output_units', default_output_units, @(x) any(validatestring(x, {'log_ratio','percent'})));
addParameter(p, 'show_figure', default_show_figure, @islogical);

% Parse inputs
parse(p, Time_points, EEG_trace, EEG_fs, varargin{:});

% Retrieve parameters
power_bands = p.Results.power_bands;
time_before = p.Results.time_before;
time_after = p.Results.time_after;
analysis_window = p.Results.analysis_window;
window_overlap = p.Results.window_overlap;
normalization_periods = p.Results.normalization_periods;
output_units = p.Results.output_units;
show_figure = p.Results.show_figure;

% ===========================
%   FREQUENCY & TIME SETUP
% ===========================
total_power_band = [0, power_bands{end}(end)];
frw = 0:0.5:total_power_band(end); 
spectro_fs = 1/(analysis_window * (1 - window_overlap));
noverlap_samples = round(EEG_fs * analysis_window * window_overlap);
window_samples = round(EEG_fs * analysis_window);

% ===========================
%   VALIDATE TIME POINTS
% ===========================
Time_points_incl = Time_points((Time_points + time_after) * EEG_fs < length(EEG_trace));
Time_points_incl = Time_points_incl(Time_points_incl - time_before > 0);

% Preallocate
% Dummy spectrogram to get the exact time vector length
dummy_trace = zeros(1, round((time_before + time_after) * EEG_fs));
[~, ~, T] = spectrogram(dummy_trace, window_samples, noverlap_samples, frw, EEG_fs, 'yaxis');

% Preallocate based on actual T length
band_power_trace = zeros(length(T), length(Time_points_incl), length(power_bands));
spectrogram_epocs = [];

% ===========================
%   LOOP THROUGH EPOCHS
% ===========================
for epoc_time_i = 1:length(Time_points_incl)
    epoc_time = Time_points_incl(epoc_time_i);
    eeg_epoc = EEG_trace(round((epoc_time - time_before) * EEG_fs):round((epoc_time + time_after) * EEG_fs));

    % Spectrogram computation
    [epoc_spectrogram, F, T] = spectrogram(eeg_epoc, window_samples, noverlap_samples, frw, EEG_fs, 'yaxis');
    log_epoc_spectrogram = log(abs(epoc_spectrogram));
    spectrogram_epocs = cat(3, spectrogram_epocs, epoc_spectrogram);

    % Extract power bands (raw log power, not yet baseline-corrected)
    for band_i = 1:length(power_bands)
        band = power_bands{band_i};
        band_epoc = mean(log_epoc_spectrogram(F >= band(1) & F <= band(2), :), 1);
        band_power_trace(1:length(band_epoc), epoc_time_i, band_i) = band_epoc;
    end
end

% ===========================
%   BASELINE (PER BAND)
% ===========================
baseline_mean = zeros(1, length(power_bands));

if ~isempty(normalization_periods)
    % --- Baseline from independently defined periods (e.g. NREM bouts) ---
    % Computed directly from spectrograms of the raw trace segments, avoiding
    % any resampled/continuous power trace and its fs-alignment problems.
    n_skipped_short = 0;
    for band_i = 1:length(power_bands)
        band = power_bands{band_i};
        band_values = [];
        for period_i = 1:size(normalization_periods, 1)
            on_s  = normalization_periods(period_i, 1);
            off_s = normalization_periods(period_i, 2);
            on_idx  = max(1, round(on_s * EEG_fs));
            off_idx = min(length(EEG_trace), round(off_s * EEG_fs));
            if off_idx <= on_idx
                continue
            end
            period_trace = EEG_trace(on_idx:off_idx);

            % Skip periods too short to fit a single analysis window -
            % spectrogram() errors if the segment is shorter than window_samples
            if length(period_trace) < window_samples
                if band_i == 1
                    n_skipped_short = n_skipped_short + 1;
                end
                continue
            end

            [period_spectrogram, F_period, ~] = spectrogram(period_trace, window_samples, noverlap_samples, frw, EEG_fs, 'yaxis');
            log_period_spectrogram = log(abs(period_spectrogram));
            filtered_period_spectrogram = imgaussfilt(log_period_spectrogram, 4);

            band_mask = F_period >= band(1) & F_period <= band(2);
            band_values = [band_values, reshape(filtered_period_spectrogram(band_mask, :), 1, [])]; %#ok<AGROW>
        end
        if isempty(band_values)
            warning('No valid normalization_periods data found for band %d; falling back to epoch pooling for this band.', band_i);
            filtered_epoc_spectrogram = imgaussfilt(log(abs(spectrogram_epocs)), 4);
            band_mask = F >= band(1) & F <= band(2);
            baseline_mean(band_i) = mean(reshape(filtered_epoc_spectrogram(band_mask, :, :), 1, []));
        else
            baseline_mean(band_i) = mean(band_values);
        end
    end
    if n_skipped_short > 0
        warning('%d of %d normalization_periods were shorter than analysis_window (%.2fs) and were skipped.', ...
            n_skipped_short, size(normalization_periods,1), analysis_window);
    end
else
    % --- Fallback: baseline pooled across all extracted epochs, per band ---
    filtered_epoc_spectrogram = imgaussfilt(log(abs(spectrogram_epocs)), 4);
    for band_i = 1:length(power_bands)
        band = power_bands{band_i};
        band_mask = F >= band(1) & F <= band(2);
        baseline_mean(band_i) = mean(reshape(filtered_epoc_spectrogram(band_mask, :, :), 1, []));
    end
end

% ===========================
%   NORMALIZATION & OUTPUT
% ===========================
% Log-domain baseline subtraction per band (equivalent to power/baseline ratio)
norm_band_power_epocs = zeros(size(band_power_trace));
for band_i = 1:length(power_bands)
    norm_band_power_epocs(:, :, band_i) = band_power_trace(:, :, band_i) - baseline_mean(band_i);
end

% Convert units if requested. 'log_ratio' (default) leaves values as-is:
% log(power/baseline), 0 = baseline. 'percent' exponentiates back out of log
% space and scales so 100 = baseline (matches intuitive "% of baseline" framing).
if strcmp(output_units, 'percent')
    norm_band_power_epocs = 100 * exp(norm_band_power_epocs);
end

time_spectrogram_zero = T - time_before;

% ===========================
%   OPTIONAL PLOTTING
% ===========================
if show_figure
    figure
    for plot_number = 1:length(power_bands)
        subplot(length(power_bands), 1, plot_number);
        plot(time_spectrogram_zero, squeeze(mean(norm_band_power_epocs(:,:,plot_number), 2)));
        title(['Band ', num2str(power_bands{plot_number}(1)), '-', num2str(power_bands{plot_number}(2)), ' Hz']);
        if strcmp(output_units, 'percent')
            ylabel('% of baseline');
        else
            ylabel('log(power/baseline)');
        end
    end
end
end
%}

%% Old version
% updated on 2025-05-08
% This version had issues with normalization: adding arbitrary number (+2)
% to get positive values; normalizing across all frequencies instead of
% per frequency band; dividing by rather than subtracting normalization 
% factor (which violates log transform principles); used only EEG wihtin 
% epoch as normalization window (NB! the latter is still the default when 
% normalization_periods are missing.

%{
function [norm_band_power_epocs, time_spectrogram_zero, spectro_fs] = epoc_extractEEGbands(Time_points, EEG_trace, EEG_fs, varargin)

%EPOC_EXTRACTEEGBANDS
% This function extracts power band epochs from EEG or LFP traces, allowing 
% for optimized windowing and resolution settings suitable for faster signals.

% Input arguments:
%   Time_points: vector of time stamps (s) used for epoc analysis (default +/-60 s. 
%                To change epoc size, use 'time_before' and 'time_after' input arguments)
%   EEG_trace: the EEG or LFP trace you want to perform epoc analysis on 
%   EEG_fs: sampling frequency of the trace
%   Optional Parameters:
%       - 'power_bands': specify power bands in a cell array (default EEG bands: 
%                        delta, theta, sigma, beta, gamma lo, gamma hi)
%       - 'time_before': time in seconds leading up to event (default 60s)
%       - 'time_after': time in seconds following event (default 60s)
%       - 'analysis_window': window size for spectrogram analysis (default 5s for EEG, 0.5s recommended for LFP)
%       - 'window_overlap': overlap ratio for windowing (default 0.5, recommended 0.8 for LFP)
%       - 'show_figure': display results (default true)

% Output arguments:
%   norm_band_power_epocs: 3D array of epoc bands (D1 is +/- 60 s epoc trace, D2 is the epoc number, D3 is EEG band)
%   time_spectrogram_zero: time vector matching length of norm_band_power_epocs
%   spectro_fs: sampling frequency of time_spectrogram_zero.

% ===========================
%   INPUT PARSER SETUP
% ===========================
p = inputParser;

% Default parameters
default_power_bands = {[1, 4], [4, 8], [8, 15], [15, 30], [30,45], [65, 80]};
default_time_before = 60;
default_time_after = 60;
default_analysis_window = 5; 
default_window_overlap = 0.5;
default_show_figure = true;

% Adding parameters to parser
addRequired(p,'Time_points',@isnumeric);
addRequired(p,'EEG_trace',@isnumeric);
addRequired(p,'EEG_fs',@isnumeric);

addParameter(p, 'power_bands', default_power_bands, @iscell);
addParameter(p, 'time_before', default_time_before, @isnumeric);
addParameter(p, 'time_after', default_time_after, @isnumeric);
addParameter(p, 'analysis_window', default_analysis_window, @isnumeric);
addParameter(p, 'window_overlap', default_window_overlap, @isnumeric);
addParameter(p, 'show_figure', default_show_figure, @islogical);

% Parse inputs
parse(p, Time_points, EEG_trace, EEG_fs, varargin{:});

% Retrieve parameters
power_bands = p.Results.power_bands;
time_before = p.Results.time_before;
time_after = p.Results.time_after;
analysis_window = p.Results.analysis_window;
window_overlap = p.Results.window_overlap;
show_figure = p.Results.show_figure;

% ===========================
%   FREQUENCY & TIME SETUP
% ===========================
total_power_band = [0, power_bands{end}(end)];
frw = 0:0.5:total_power_band(end); 
spectro_fs = 1/(analysis_window * (1 - window_overlap));

% ===========================
%   VALIDATE TIME POINTS
% ===========================
Time_points_incl = Time_points((Time_points + time_after) * EEG_fs < length(EEG_trace));
Time_points_incl = Time_points_incl(Time_points_incl - time_before > 0);

% Preallocate
% Dummy spectrogram to get the exact time vector length
dummy_trace = zeros(1, round((time_before + time_after) * EEG_fs));
[~, ~, T] = spectrogram(dummy_trace, round(EEG_fs * analysis_window), round(EEG_fs * analysis_window * window_overlap), frw, EEG_fs, 'yaxis');

% Preallocate based on actual T length
band_power_trace = zeros(length(T), length(Time_points_incl), length(power_bands));
spectrogram_epocs = [];

% ===========================
%   LOOP THROUGH EPOCHS
% ===========================
for epoc_time_i = 1:length(Time_points_incl)
    epoc_time = Time_points_incl(epoc_time_i);
    eeg_epoc = EEG_trace(round((epoc_time - time_before) * EEG_fs):round((epoc_time + time_after) * EEG_fs));

    % Spectrogram computation
    [epoc_spectrogram, F, T] = spectrogram(eeg_epoc, round(EEG_fs * analysis_window), round(EEG_fs * analysis_window * window_overlap), frw, EEG_fs, 'yaxis');
    log_epoc_spectrogram = log(abs(epoc_spectrogram));
    spectrogram_epocs = cat(3, spectrogram_epocs, epoc_spectrogram);

    % Extract power bands
    for band_i = 1:length(power_bands)
        band = power_bands{band_i};
        band_epoc = mean(log_epoc_spectrogram(F >= band(1) & F <= band(2), :), 1);
        band_power_trace(1:length(band_epoc), epoc_time_i, band_i) = band_epoc;
    end
end

% ===========================
%   NORMALIZATION & OUTPUT
% ===========================
log_epoc_spectrogram = log(abs(spectrogram_epocs));
filtered_mean_spectrogram = imgaussfilt(log_epoc_spectrogram, 4);
normalization_factor = mean(mean(mean(filtered_mean_spectrogram)));
norm_band_power_epocs = band_power_trace / -normalization_factor + 2;
time_spectrogram_zero = T - time_before;

% ===========================
%   OPTIONAL PLOTTING
% ===========================
if show_figure
    figure
    for plot_number = 1:length(power_bands)
        subplot(length(power_bands), 1, plot_number);
        plot(time_spectrogram_zero, squeeze(mean(norm_band_power_epocs(:,:,plot_number), 2)));
        title(['Band ', num2str(power_bands{plot_number}(1)), '-', num2str(power_bands{plot_number}(2)), ' Hz']);
    end
end
end
%}

%% Original function 
% Old version manually guessed the expected number of time bins via a size_correction 
% factor (round((time_before+time_after)*spectro_fs - size_correction),
% where size_correction was 1 or 2 depending on window size) — fragile and
% prone to off-by-one/mismatch errors depending on Chronux/MATLAB's actual
% windowing.

%{
function [norm_band_power_epocs, time_spectrogram_zero, spectro_fs] = epoc_extractEEGbands(Time_points, EEG_trace, EEG_fs, varargin)

%EPOC_EXTRACTEEGBANDS
% Input arguments:
%   Time_points: vector of time stamps (s) used for epoc analysis (default +/-60 s. To change epoc size, use 'time_before' and 'time_after' input arguments)
%   EEG_trace: is the EEG trace you want to perform epoc analysis on 
%   EEG_fs: sampling frequency of EEG
%   'power_bands' (optional): specify power bands in a cell array. (default EEG bands: delta, theta, sigma, beta, gamma lo, gamma hi)
%
% Output arguments:
%   norm_band_power_epocs: %3D array of epoc bands (D1 is +/- 60 s epoc trace, D2 is the epoc number, D3 is EEG band)
%   time_spectrogram_zero: time vector matching length of norm_band_power_epocs
%   spectro_fs: sampling frequncy of time_spectrogram_zero.

p = inputParser;

default_power_bands = {[1, 4], [4, 8], [8, 15], [15, 30] [30,45] [65, 80]};
default_time_before = 60; % time in seconds leading up to event
default_time_after = 60; % time in seconds following event
default_show_figure = true;

addRequired(p,'Time_points',@isnumeric);
addRequired(p,'EEG',@isnumeric);
addRequired(p,'EEG_fs',@isnumeric);

addParameter(p, 'power_bands', default_power_bands, @iscell);
addParameter(p, 'time_before', default_time_before, @isnumeric);
addParameter(p, 'time_after', default_time_after, @isnumeric);
addParameter(p, 'show_figure', default_show_figure, @islogical);

parse(p, Time_points, EEG_trace, EEG_fs, varargin{:});

power_bands = p.Results.power_bands;
time_before = p.Results.time_before;
time_after = p.Results.time_after;
show_figure = p.Results.show_figure;

analysis_window = 5; %sec. 1 for 30 sec
total_power_band = [0, power_bands{end}(end)];
frw = 0:0.2:total_power_band(end);
spectro_fs = 1/(analysis_window/2);

Time_points_incl = Time_points((Time_points+time_after)*EEG_fs < length(EEG_trace));
Time_points_incl = Time_points_incl(Time_points_incl-time_before > 0);

if analysis_window > 1
    size_correction = 2;    % to make empty vector for preallocation fit in size with data size from looping
else 
    size_correction = 1;
end

band_power_trace = zeros(round((time_before+time_after)*spectro_fs-size_correction), length(Time_points_incl), length(power_bands));
spectrogram_epocs = [];

for epoc_time_i=1:length(Time_points_incl)
    eopc_time = Time_points_incl(epoc_time_i);
    % create EEG epoc trace   
    eeg_epoc = EEG_trace(round((eopc_time - time_before)*EEG_fs):round((eopc_time + time_after)*EEG_fs));      

    % powerspectrogram on EEG epoc trace
    [epoc_spectrogram, F, T] = spectrogram(eeg_epoc,round(EEG_fs*analysis_window),[],frw,EEG_fs,'yaxis'); % F = frequenciy vector, T=time vector
    log_epoc_spectrogram = log(abs(epoc_spectrogram));
    spectrogram_epocs = cat(3, spectrogram_epocs, epoc_spectrogram);

    for band_i = 1:length(power_bands)
        band = power_bands{band_i};
        band_epoc = mean(log_epoc_spectrogram(find(F==band(1)):find(F==band(2)), :), 1);
        band_power_trace(1:length(band_epoc),epoc_time_i,band_i) = band_epoc; %3D array: D1 is +/- 60 s epoc trace, D2 is the epoc number, D3 is EEG band           
    end

end

%{
log_spectrogram = log(abs(spectrogram_epocs));
mean_spectrogram = nanmean(log_spectrogram, 3);
%mean_spectrogram = log(abs(spectrogram_epocs));
norm_time = abs(T-(time_before/3*2));
norm_sampling = find(norm_time == min(norm_time));
normalization_factor = mean(mean(mean_spectrogram));
%}

log_epoc_spectrogram = log(abs(spectrogram_epocs));
filtered_mean_spectrogram = imgaussfilt(log_epoc_spectrogram, 4);
normalization_factor = mean(mean(mean(filtered_mean_spectrogram))); %3D mean

% normalization of EEG band power traces to avoid negative values
norm_band_power_epocs = band_power_trace/-normalization_factor+2;

time_spectrogram_zero = T-time_before; % time vector matching band power traces

collect_band_epoc_means = squeeze(mean(norm_band_power_epocs,2)); % band means

if show_figure
    
    if isequal(power_bands,default_power_bands)
        plotName = {'event - mean delta','event - mean theta','event - mean sigma','event - mean beta','event - mean gamma low', 'event - mean gamma high'}; %default EEG bands
    else
        plotName = {'band 1 mean','band 2 mean','band 3 mean','band 4 mean','band 5 mean', 'band 6 mean' 'band 7 mean' 'band 8 mean' 'band 9 mean'}; %custom EEG bands
    end
    
    figure
    for plot_number = 1:length(power_bands)
        Ax{plot_number} = subplot(length(power_bands), 1, plot_number);
        plot(time_spectrogram_zero, collect_band_epoc_means(:,plot_number))
        title(plotName(plot_number))
    end
    linkaxes([Ax{:}],'x')
end
end

%}