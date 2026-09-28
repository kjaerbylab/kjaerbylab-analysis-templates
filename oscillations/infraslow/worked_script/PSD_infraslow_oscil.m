%% DESCRIPTION
% This script can be used to make a power spectral density analysis on
% traces that show infraslow oscillations (e.g. NE and sigma traces)

%% PSD on NE trace

signal_trace = delta465_filt; %             <<< Specify which trace the analysis should be used for
fs = signal_fs; %                           <<< Specify sampling frequency of your signal trace
analysis_periods = NREMinclMA_periods; %    <<< Specify which bouts should be included
min_period_dur = 120; %                     <<< Specify minimum bout duration for bout to be included in the analysis

% power spectral densities
t1 = analysis_periods(:,1);
t2 = analysis_periods(:,2);

tsamp1 = floor(t1*fs); %eeg start time 
tsamp2 = floor(t2*fs); %eeg end time
NREM_data = cell(1, numel(tsamp1));

PXX = [];
PXXlog = [];
PXX_pk_f = [];
PXX_pk = [];

NREM_data_collect = [];
period_duration = [];

for i=1:numel(tsamp1)
    period_length_i = tsamp2(i)-tsamp1(i);
    if period_length_i < min_period_dur*fs % periods shorter than 120 s are excluded from analysis
        continue
    end
    if tsamp2(i) > length(signal_trace) % if last period ends after trace 
       tsamp2(i) = length(signal_trace);
    end
    period_duration = [period_duration period_length_i/fs];
    NREM_data{i} = signal_trace(tsamp1(i):tsamp2(i));
    timetrace_i = sec_signal(tsamp1(i):tsamp2(i));
    
    %detrend (and center around 0)
    [p,s,mu] = polyfit((1:numel(NREM_data{i}))',NREM_data{i},5);
    f_y = polyval(p,(1:numel(NREM_data{i}))',[],mu);
    detrend_data = NREM_data{i} - f_y';        % Detrend data
    
    [pxx, f] = pwelch(detrend_data, [], [],[0:0.002:0.1], fs); %
    logpxx = 10*log10(pxx);
    FX{i} = f;
    [pxx_pk_psd, max_idx] = max(pxx);
    PXX_pk = [PXX_pk pxx_pk_psd];
    pxx_pk_f = f(max_idx);
    PXX_pk_f = [PXX_pk_f pxx_pk_f];
    %PXXlog = [PXXlog logpxx'];
    PXX = [PXX pxx'];
    
    figure
    set(gcf, 'Position',  [100, 300, 1500, 250])
    a = subplot(1,2,1);
        %a.Position = [0.1300 0.1100 0.6200 0.8150];
        plot(timetrace_i,NREM_data{i});
        hold on
        plot(timetrace_i,detrend_data);
        legend({'raw','fitted'})
        hold off
    b = subplot(1,2,2);
        %b.Position = [0.8140 0.1100 0.1533 0.8150];
        plot(f,pxx);
end

weighted_mean_PXX_iso = sum(period_duration.*PXX,2)/sum(period_duration); % weigthed mean trace (period durations are used as weights)

[PXX_iso_pk_mean, PXX_iso_pk_idx] = max(weighted_mean_PXX_iso); % peak power from mean trace
PXX_iso_f_mean = f(PXX_iso_pk_idx);

prism_psd_iso = weighted_mean_PXX_iso;
prism_freq_iso = f;

% power spectral density plot
figure
    plot(prism_freq_iso,prism_psd_iso)
    xlabel('frequency (Hz)');
    ylabel('PSD');
