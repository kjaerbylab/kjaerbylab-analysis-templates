function [wavelt_trace, wavelt_freq, wavelt_pk_mean, wavelt_f_mean] = InfraslowWavelet(trace, trace_t, periods, trace_fs, min_dur, varargin)
%INFRASLOWWAVELET
% Performs wavelet analysis on a trace to assess infraslow oscillations 
% during specified periods. Uses Morlet wavelet transform to extract 
% power and frequency estimates, replacing PSD analysis.

% Input arguments:
%   trace         - signal vector
%   trace_t       - time vector (same length as trace)
%   periods       - n x 2 matrix [start_time, end_time] in seconds
%   trace_fs      - sampling frequency (Hz)
%   min_dur       - minimum period duration to include (s)
%
% Optional name-value pairs:
%   'show_figure_mean'   - plot the mean wavelet spectrum (default: false)
%   'show_figure_indvdl' - plot individual bout traces and spectra (default: false)
%
% Output arguments:
%   wavelt_trace   - weighted mean wavelet power spectrum
%   wavelt_freq    - corresponding frequencies (Hz)
%   wavelt_pk_mean - peak power in mean wavelet spectrum
%   wavelt_f_mean  - frequency of the peak power

% --- Input parsing ---
p = inputParser;
addRequired(p, 'trace', @isnumeric);
addRequired(p, 'periods', @isnumeric);
addRequired(p, 'trace_fs', @isnumeric);
addRequired(p, 'min_dur', @isnumeric);
addParameter(p, 'show_figure_mean', false, @islogical);
addParameter(p, 'show_figure_indvdl', false, @islogical);
parse(p, trace, periods, trace_fs, min_dur, varargin{:});

show_figure_mean   = p.Results.show_figure_mean;
show_figure_indvdl = p.Results.show_figure_indvdl;

% Assume original fs = 1000, target fs = 10 Hz → LPF at ~4–5 Hz
low_cutoff = 0.8;  % Hz
[b, a] = butter(4, low_cutoff / (trace_fs / 2)); % 4th order Butterworth
trace = filtfilt(b, a, trace);

% downsample (to increase processing speed)
ds_factor = floor(trace_fs / 10); % e.g., downsample to 10 Hz
trace = downsample(trace, ds_factor);
trace_t = downsample(trace_t, ds_factor);
trace_fs = trace_fs / ds_factor;

% --- Initialization ---
t1 = periods(:,1);
t2 = periods(:,2);
tsamp1 = max(floor(t1 * trace_fs), 1);
tsamp2 = min(floor(t2 * trace_fs), length(trace));

period_duration   = [];
wavetrans_pk      = [];
wavetrans_pk_f    = [];
ref_freq          = [];
included_count    = 0;

% Placeholder for preallocation
num_freqs   = [];
max_bouts   = size(periods, 1);
all_interp_powers = [];  % preallocated below after first bout

% --- Process each period ---
for i = 1:numel(tsamp1)
    period_length_i = tsamp2(i) - tsamp1(i);
    if period_length_i < min_dur * trace_fs
        continue;
    end

    % Extract segment and detrend
    trace_i     = trace(tsamp1(i):tsamp2(i));
    timetrace_i = trace_t(tsamp1(i):tsamp2(i));
    [polyfit_p, ~, mu] = polyfit((1:numel(trace_i))', trace_i, 5);
    f_y         = polyval(polyfit_p, (1:numel(trace_i))', [], mu);
    detrend_data = trace_i - f_y';

    % Wavelet transform
    [cwt_coeffs, f] = cwt(detrend_data, trace_fs, 'FrequencyLimits', [0.005 0.1]);
    avg_power = mean(abs(cwt_coeffs).^2, 2); % mean power across time

    % First valid bout: define reference frequency and preallocate
    if isempty(ref_freq)
        ref_freq = f;
        num_freqs = numel(ref_freq);
        all_interp_powers = NaN(num_freqs, max_bouts);
    end

    % Interpolate to reference frequency axis
    try
        interp_power = interp1(f, avg_power, ref_freq, 'linear', NaN);
    catch
        warning('Interpolation failed for bout %d, skipping.', i);
        continue;
    end

    % Skip if interpolation completely failed
    if all(isnan(interp_power))
        warning('All values NaN in interpolated power for bout %d, skipping.', i);
        continue;
    elseif any(isnan(interp_power))
        warning('Some NaNs in interpolated power for bout %d, including with NaN masking.', i);
    end

    % Store results
    included_count = included_count + 1;
    all_interp_powers(:, included_count) = interp_power;
    period_duration(included_count) = period_length_i / trace_fs;

    [wt_pk_power, max_idx] = max(interp_power);
    wavetrans_pk   = [wavetrans_pk, wt_pk_power];
    wavetrans_pk_f = [wavetrans_pk_f, ref_freq(max_idx)];

    if show_figure_indvdl
        figure;
        set(gcf, 'Position', [100, 300, 1500, 250]);
        subplot(1,2,1);
            plot(timetrace_i, detrend_data);
            title(sprintf('Detrended Signal (Bout %d)', i));
        subplot(1,2,2);
            plot(ref_freq, interp_power);
            title('Interpolated Wavelet Power Spectrum');
            xlabel('Frequency (Hz)');
            ylabel('Power');
    end
end

fprintf('Total included periods (interpolated): %d out of %d\n', included_count, numel(tsamp1));

if included_count == 0
    error('No valid periods were included after interpolation.');
end

% --- Truncate unused columns ---
all_interp_powers = all_interp_powers(:, 1:included_count);

% --- Weighted average across bouts (ignoring NaNs) ---
weightedMean_traceWT = nansum(all_interp_powers .* period_duration, 2) ./ ...
                       nansum(repmat(period_duration, num_freqs, 1), 2);

% --- Outputs ---
[wavelt_pk_mean, WT_pk_idx] = max(weightedMean_traceWT);
wavelt_f_mean  = ref_freq(WT_pk_idx);
wavelt_trace   = weightedMean_traceWT;
wavelt_freq    = ref_freq;

if show_figure_mean
    figure;
        plot(wavelt_freq, wavelt_trace, 'LineWidth', 1.5);
        xlabel('Frequency (Hz)');
        ylabel('Wavelet Power');
        title('Mean Infraslow Wavelet Power Spectrum');
end

end


%{
function [wavelt_trace, wavelt_freq, wavelt_pk_mean, wavelt_f_mean] = InfraslowWavelet(trace, trace_t, periods, trace_fs, min_dur, varargin)
%WAVELETINFRASLOWANALYSIS
% This function performs Wavelet Analysis on the provided trace to assess 
% infraslow oscillations in specified periods. It replaces PSD analysis 
% with a Morlet wavelet transform to extract power and frequency estimates 
% during NREM episodes.

% Input arguments:
%   trace: is the trace you want to assess for infraslow oscillations
%   trace_t: time trace (s) matching the length of trace
%   periods: is an n by 2 matrix where n is the number of periods,
%   column 1 contains onset and column 2 offset of each period (in s).
%   These periods determine which part of the data is analyzed
%   trace_fs: is the sample frequency for the trace.
%   min_dur: is the minimum duration for a bout to be included

% Output arguments:
%   wavelt_trace: mean wavelet power trace (weighted based on period durations)
%   wavelt_freq: wavelet frequencies (x-axis for plotting)
%   wavelt_pk_mean: peak power from the wavelet mean trace
%   wavelt_f_mean: peak frequency from the wavelet mean trace

p = inputParser;
default_show_figure_mean = false;
default_show_figure_indvdl = false;
addRequired(p,'trace',@isnumeric);
addRequired(p,'periods',@isnumeric);
addRequired(p,'trace_fs',@isnumeric);
addRequired(p,'min_dur',@isnumeric);
addParameter(p, 'show_figure_mean', default_show_figure_mean, @islogical);
addParameter(p, 'show_figure_indvdl', default_show_figure_indvdl, @islogical);
parse(p,trace, periods, trace_fs, min_dur,varargin{:});
show_figure_mean = p.Results.show_figure_mean;
show_figure_indvdl = p.Results.show_figure_indvdl;

% Define periods
t1 = periods(:,1);
t2 = periods(:,2);
tsamp1 = max(floor(t1*trace_fs), 1); % Prevent index 0
tsamp2 = min(floor(t2*trace_fs), length(trace)); % Prevent overflow

wavetrans = [];
wavetrans_pk_f = [];
wavetrans_pk = [];
period_duration = [];
ref_freq = [];
first_iteration = true; % Flag for the first iteration

included_count = 0;

for i=1:numel(tsamp1)
    period_length_i = tsamp2(i)-tsamp1(i);
    if period_length_i < min_dur*trace_fs
        continue
    end
    period_duration = [period_duration period_length_i/trace_fs];
    trace_i = trace(tsamp1(i):tsamp2(i));
    timetrace_i = trace_t(tsamp1(i):tsamp2(i));
    
    % Detrend the data
    [p,~,mu] = polyfit((1:numel(trace_i))',trace_i,5);
    f_y = polyval(p,(1:numel(trace_i))',[],mu);
    detrend_data = trace_i - f_y';
    
    % Wavelet Transform
    [cwt_coeffs, f] = cwt(detrend_data, trace_fs, 'FrequencyLimits', [0.005 0.1]); % cwt_coeffs contains wavelet coefficients at each frequency (f) for each time point.
    wavlt_power = abs(cwt_coeffs).^2; % power of the coefficients
    avg_power = mean(wavlt_power, 2);

    % === Plot scalogram only for the first iteration ===
    % if first_iteration
    %     time_vector = (0:length(detrend_data)-1) / trace_fs;
    %     figure;
    %     imagesc(time_vector, f, abs(cwt_coeffs));
    %     axis xy;
    %     xlabel('Time (s)');
    %     ylabel('Frequency (Hz)');
    %     title('Scalogram of First Bout');
    %     colorbar;
    %     first_iteration = false; % Set to false after the first iteration
    % end

    % Initialize or accumulate power
    if isempty(wavetrans)
        wavetrans = avg_power;
        ref_freq = f;
    else
        % Ensure size compatibility
        if numel(wavetrans) == numel(avg_power)
            wavetrans = wavetrans + avg_power;
            included_count = included_count + 1;
        else
            warning('Inconsistent frequency resolution between periods, skipping this bout.');
            continue;
        end
    end

    [wt_pk_power, max_idx] = max(avg_power); % peak from power spectrum
    wavetrans_pk = [wavetrans_pk wt_pk_power];
    wavetrans_pk_f = [wavetrans_pk_f f(max_idx)];
    
    if show_figure_indvdl
        figure
        set(gcf, 'Position',  [100, 300, 1500, 250])
        subplot(1,2,1);
            plot(timetrace_i, detrend_data);
            title('Detrended Signal');
        subplot(1,2,2);
            plot(f, avg_power);
            title('Wavelet Power Spectrum');
            xlabel('Frequency (Hz)');
            ylabel('Power');
    end
end

fprintf('Total included periods: %d out of %d\n', included_count, numel(tsamp1));

% Weighted mean calculation
weightedMean_traceWT = sum(period_duration.*wavetrans,2)/sum(period_duration);
[wavelt_pk_mean, WT_pk_idx] = max(weightedMean_traceWT);
wavelt_f_mean = ref_freq(WT_pk_idx);

% Outputs
wavelt_trace = weightedMean_traceWT;
wavelt_freq = ref_freq;

if show_figure_mean
    figure
        plot(wavelt_freq, wavelt_trace);
        xlabel('frequency (Hz)');
        ylabel('Wavelet Power');
        title('Mean Wavelet Power Spectrum');
end

end

%}