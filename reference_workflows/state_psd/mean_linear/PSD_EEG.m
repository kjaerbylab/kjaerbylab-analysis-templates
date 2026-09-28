%% Power spectral density (PSD) on EEG
% Power spectral density calculation of EEG signal using Welch's method.
% This gives a plot of power across EEG frequencies

% select which state you want to run PSD on and specify EEG trace
analysis_period = sws_periods_cut; % should be a matrix of on- and offsets
EEG_trace = EEG_rawtrace_cut; % should be vector containing the EEG trace

% power spectral densities
t1 = analysis_period(:,1);
t2 = analysis_period(:,2);

tsamp1 = floor(t1*sampling_freq); %eeg start time 
tsamp2 = floor(t2*sampling_freq); %eeg end time
NREM_data = cell(1, numel(tsamp1));

PXX = [];
NREM_data_collect = [];

for i=1:numel(tsamp1)
    NREM_data{i} = EEG_trace(tsamp1(i):tsamp2(i));
    NREM_data_cut = EEG_trace(tsamp1(i):tsamp2(i));
    NREM_data_collect = [NREM_data_collect NREM_data_cut];
    [pxx, f] = pwelch(NREM_data{i}, [], [],[0:0.2:100], sampling_freq);
    logpxx = 10*log10(pxx);
    FX{i} = f;
    PXX(:,i) = logpxx;
    PXX(:,i) = pxx;
end

mean_PXX = mean(PXX,2);

prism_psd = mean_PXX(f<45);
prism_freq = f(f<45);

% power spectral density plot
figure
plot(prism_freq,prism_psd)

mean_sigma_power_density = mean(mean_PXX(f>8 & f<15));
mean_delta_power_density = mean(mean_PXX(f>1 & f<4));
mean_theta_power_density = mean(mean_PXX(f>4 & f<8));
mean_beta_power_density = mean(mean_PXX(f>15 & f<30));

prism_band_collect = [mean_delta_power_density mean_theta_power_density mean_sigma_power_density mean_beta_power_density]';