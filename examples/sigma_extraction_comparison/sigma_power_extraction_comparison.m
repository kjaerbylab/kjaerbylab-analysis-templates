%% compare_sigma_methods.m
% Benchmarks 4 ways of extracting 10-15 Hz "sigma" power from an EEG trace:
%   1) designfilt (IIR, explicit stopband attenuation) + Hilbert
%   2) Butterworth (order 4) + Hilbert
%   3) FIR (Hamming) + Hilbert
%   4) CWT squared envelope (restricted freq range for speed)
%   5) (reference only) spectrogram-based log-power, interpolated to full fs
%
% Loads EEG_rawtrace and fs_eeg if they exist in the workspace; otherwise
% generates a synthetic trace with embedded ~12 Hz spindle bursts so you
% can sanity-check the methods even without real data.

%% --- Get / generate data -------------------------------------------------
if ~exist('EEG', 'var') || ~exist('fs_eeg', 'var')
    fprintf('No EEG_rawtrace/fs_eeg found - generating synthetic test signal.\n');
    fs_eeg = 200;                 % Hz
    dur    = 60;                  % seconds
    t      = (0:1/fs_eeg:dur-1/fs_eeg)';
    EEG = 0.5*randn(size(t));               % background noise
    EEG = EEG + 0.3*sin(2*pi*2*t); % slow oscillation (delta-ish)

    % Insert a few synthetic spindles (12 Hz bursts, ~1 s, amplitude-modulated)
    spindle_centers = [10 25 40 50]; % seconds
    for c = spindle_centers
        env = exp(-((t-c).^2)/(2*0.3^2));            % ~1 s gaussian envelope
        EEG = EEG + 1.5*env.*sin(2*pi*12*t);
    end
    EEG = EEG(:);
end

EEG = double(EEG(:));
N = numel(EEG);
t = (0:N-1)'/fs_eeg;

results = struct();

%% --- 1) designfilt (IIR, explicit stopbands) + Hilbert -------------------
tic
d_filt = designfilt('bandpassiir', ...
    'StopbandFrequency1', 3 / (fs_eeg/2), ...
    'PassbandFrequency1', 10 / (fs_eeg/2), ...
    'PassbandFrequency2', 15 / (fs_eeg/2), ...
    'StopbandFrequency2', 22 / (fs_eeg/2), ...
    'StopbandAttenuation1', 24, ...
    'StopbandAttenuation2', 24, ...
    'DesignMethod', 'butter');
EEG_filt_designfilt = filtfilt(d_filt, EEG);
% results.designfilt.power = abs(hilbert(EEG_filt_designfilt)).^2;
% results.designfilt.power = log(abs(hilbert(EEG_filt_designfilt)).^2);

sigma_power = abs(hilbert(EEG_filt_designfilt)).^2;   % full-rate power, from your existing pipeline

% Downsample power trace - infraslow content is well below 1 Hz, so this loses nothing
ds_factor = round(fs_eeg / 10); % e.g. gives ~10 Hz
sigma_power_ds = resample(sigma_power, 1, ds_factor);
fs_power = fs_eeg / ds_factor;

% Bandpass in the infraslow range (e.g. 0.01-0.05 Hz, periods of 20-100 s)
% d_iso = designfilt('bandpassiir', ...
%     'PassbandFrequency1', 0.01, 'StopbandFrequency1', 0.005, ...
%     'PassbandFrequency2', 0.05, 'StopbandFrequency2', 0.08, ...
%     'StopbandAttenuation1', 24, 'StopbandAttenuation2', 24, ...
%     'SampleRate', fs_power, 'DesignMethod', 'butter');
d_iso = designfilt('bandpassiir', ...
    'PassbandFrequency1', 0.01, 'StopbandFrequency1', 0.005, ...
    'PassbandFrequency2', 0.08,  'StopbandFrequency2', 0.12, ...
    'StopbandAttenuation1', 24, 'StopbandAttenuation2', 24, ...
    'SampleRate', fs_power, 'DesignMethod', 'butter');

iso_trace = filtfilt(d_iso, sigma_power_ds);

t_iso = (0:length(iso_trace)-1)' / fs_power;
iso_trace_full = interp1(t_iso, iso_trace, t, 'linear', 'extrap');
results.designfilt.power = iso_trace_full;

results.designfilt.time  = toc;

[~, ~, ~, ~] = PSDinfraslow2(iso_trace_full, t, NREMinclMA_periods, fs_eeg, 120, 'show_figure_mean', true);

%% Yi's method
tic

resample_fre=5;
sigma_band = bandpass(EEG, [10 15], fs_eeg);
signal_trace= abs(hilbert(sigma_band)).^2;
t = (0:length(signal_trace)-1) / fs_eeg;
sec_idx = floor(t*resample_fre) + 1;
sigma_power = accumarray(sec_idx(:), signal_trace(:), [], @mean);

t_yi = (0:length(sigma_power)-1)' / resample_fre;
sigma_power_full = interp1(t_yi, sigma_power, t, 'linear', 'extrap');

results.Yi.power = sigma_power_full(:);
results.Yi.time  = toc;

[~, ~, ~, ~] = PSDinfraslow2(sigma_power_full, t, NREMinclMA_periods, fs_eeg, 120, 'show_figure_mean', true);

%% Butterworth (order 4) + Hilbert
tic
[sos, g] = butter(4, [10 15]/(fs_eeg/2), 'bandpass');
EEG_filt_butter = filtfilt(sos, g, EEG);
results.butter.power = abs(hilbert(EEG_filt_butter)).^2;
results.butter.time  = toc;

[~, ~, ~, ~] = PSDinfraslow2(results.butter.power', t, NREMinclMA_periods, fs_eeg, 120, 'show_figure_mean', true);


%% FIR (Hamming) + Hilbert
tic
f_low = 10; f_high = 15; pad_sec = 2;
fir_order = min(3*fix(fs_eeg/f_low), round(fs_eeg*pad_sec));
if mod(fir_order,2) ~= 0
    fir_order = fir_order + 1;
end
bpFilt = fir1(fir_order, [f_low f_high]/(fs_eeg/2), 'bandpass', hamming(fir_order+1));
EEG_filt_fir = filtfilt(bpFilt, 1, EEG);
results.fir.power = abs(hilbert(EEG_filt_fir)).^2;
results.fir.time  = toc;

%% CWT squared envelope (restricted range for speed) 
tic
[sw, f] = cwt(EEG, fs_eeg, 'FrequencyLimits', [5 30], 'amor');
band_idx = f >= 10 & f <= 15;
% squared magnitude = power; mean across the sigma scales
results.cwt.power = mean(abs(sw(band_idx, :)).^2, 1)';
results.cwt.time  = toc;

%% Spectrogram-based log power (reference, coarse time res) 
tic
% window = 2; % seconds
window = 5; % seconds
frw = 0:0.2:30;
[S, F, T] = spectrogram(EEG, round(fs_eeg*window), [], frw, fs_eeg, 'yaxis');
mean_spectrogram = log(abs(S));
band = (F >= 10) & (F <= 15);
spec_power_coarse = mean(mean_spectrogram(band, :), 1);
% interpolate onto full-rate time base for visual comparison
spec_power = interp1(T, spec_power_coarse, t, 'linear', 'extrap')';
results.spectrogram.power = spec_power(:);
results.spectrogram.time  = toc;

[~, ~, ~, ~] = PSDinfraslow2(spec_power', t, NREMinclMA_periods, fs_eeg, 120, 'show_figure_mean', true);

%% Lecci 2017 method
tic
Lecci_ISO = sigma_infraslow_continuous_v2(EEG, fs_eeg);
% Lecci_ISO = sigma_infraslow_continuous_v2(EEG_rawtrace, fs_eeg, 'fitFreqRange', [0.005 0.03]);

t_lecci = (0:numel(Lecci_ISO.cleanBandPower.sigma)-1) * 4; % seconds, epochLen = 4

% figure
% plot(t_lecci, Lecci_ISO.normBandPower.sigma, 'Color', [0.8 0.8 0.8]); hold on
% plot(t_lecci, Lecci_ISO.cleanBandPower.sigma, 'b')
% xlabel('Time (min)'); ylabel('Sigma power (% of mean)')
% legend('raw','artifact-cleaned')
% 
% % the band-pass filtered infraslow oscillation, same timebase:
% figure
% plot(t_lecci, Lecci_ISO.filteredSigma.timecourse)
% xlabel('Time (min)'); ylabel('Filtered sigma power')

power_trace = Lecci_ISO.filteredSigma.timecourse;
% power_trace = Lecci_ISO.filteredSigma.sigma;

% interpolate onto full-rate time base for visual comparison
Lecci_power = interp1(t_lecci, power_trace, t, 'linear', 'extrap')';

results.Lecci.power = Lecci_power(:);
results.Lecci.time  = toc;

[~, ~, ~, ~] = PSDinfraslow2(Lecci_power', t, NREMinclMA_periods, fs_eeg, 120, 'show_figure_mean', true);

figure
plot(t_lecci, power_trace)
hold on
plot(t_lecci, smooth(power_trace,10))

%% --- Normalize all traces (z-score) for visual comparison -------------------
% methods = {'designfilt','butter','fir','cwt','spectrogram', 'Yi'};
methods = {'spectrogram', 'designfilt', 'Lecci'};
colors  = lines(numel(methods));

figure('Name','Sigma power method comparison','Position',[100 100 1100 700]);

% Top: raw EEG
a = subplot(3,1,1);
plot(t, EEG, 'k');
title('Raw EEG'); xlabel('Time (s)'); ylabel('V'); xlim([t(1) t(end)]);

% Middle: overlaid z-scored power traces
b = subplot(3,1,2); hold on;
for i = 1:numel(methods)
    p = results.(methods{i}).power;
    p_z = (p - mean(p)) / std(p);
    plot(t, p_z, 'Color', colors(i,:), 'DisplayName', methods{i});
end
hold off;
legend('show'); title('Sigma power traces (z-scored for comparison)');
xlabel('Time (s)'); ylabel('Z-score'); xlim([t(1) t(end)]);
linkaxes([a,b], 'x')

% Bottom: runtime comparison
subplot(3,1,3);
times = cellfun(@(m) results.(m).time, methods);
bar(times);
set(gca, 'XTickLabel', methods);
ylabel('Time (s)'); title('Computation time');
grid on;

%% --- Pairwise correlations (excluding edge artifacts) -----------------------
edge = round(fs_eeg*2); % drop 2 s at each end (filter/CWT edge effects)
valid = (edge+1):(N-edge);

power_mat = zeros(numel(valid), numel(methods));
for i = 1:numel(methods)
    power_mat(:,i) = results.(methods{i}).power(valid);
end

R = corr(power_mat);
fprintf('\nPairwise correlation of sigma power traces (z-scored, edges trimmed):\n');
T_corr = array2table(R, 'VariableNames', methods, 'RowNames', methods);
disp(T_corr);

fprintf('\nComputation times (s):\n');
for i = 1:numel(methods)
    fprintf('  %-12s %.4f\n', methods{i}, results.(methods{i}).time);
end

%% --- PSD comparison of power traces (infraslow range) -----------------------
% Add any extra traces to `results` (e.g. results.Yi.power) and to `methods`
% before this section. All traces are assumed to be at full fs_eeg rate
% (interpolate first if a trace is at a different rate, as with the ISO trace).

methods_psd = methods; % copy in case you want a different set for PSD vs. overlay
% e.g.: methods_psd = {'designfilt','butter','fir','cwt','spectrogram','Yi'};

fs_power_psd = 10; % target rate for PSD analysis (Hz)
ds_factor    = round(fs_eeg / fs_power_psd);
fs_power_psd = fs_eeg / ds_factor; % actual rate after integer downsampling

window_sec     = 250; % seconds - long enough for several ISO cycles
window_samples = round(window_sec * fs_power_psd);

figure('Name','PSD of sigma power traces','Position',[100 100 900 500]);
hold on;
colors_psd = lines(numel(methods_psd));
for i = 1:numel(methods_psd)
    p = results.(methods_psd{i}).power;
    p_ds = resample(p, 1, ds_factor);

    % shrink window if trace is too short for the requested window length
    win = min(window_samples, floor(numel(p_ds)/2));
    noverlap = round(win * 0.5);

    [pxx, f] = pwelch(p_ds, hamming(win), noverlap, [], fs_power_psd);
    plot(f, 10*log10(pxx), 'Color', colors_psd(i,:), 'DisplayName', methods_psd{i});
end
hold off;
legend('show');
xlim([0 0.5]); % focus on infraslow / slow range
xlabel('Frequency (Hz)'); ylabel('Power (dB)');
title('PSD of sigma power traces (infraslow range)');
grid on;
