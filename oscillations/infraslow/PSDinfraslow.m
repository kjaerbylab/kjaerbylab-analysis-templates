function [psd_trace, psd_freq, PXX_pk_mean, PXX_f_mean] = PSDinfraslow(trace, trace_t, periods, trace_fs, min_dur, varargin)

%PSDINFRASLOW
% Input arguments:
%   trace: is the trace you want to assess for infraslow oscillations
%   trace_t: time trace (s) matching lenght of trace
%   periods: is an n by 2 matrix where n is the number of periods,
%   column 1 contains onset and coulmn 2 offset of each period (in s).
%   These periods determine which part of the data is analyzed
%   trace_fs: is the sample frequency for the trace.
%   min_dur: is the minimum duration for a bout to be included
% Output arguments:
%   psd_trace: mean PSD trace (weighted based on period durations)
%   psd_freq: psd frequencies (x-axis for plotting)
%   PXX_pk_mean: peak value from PSD trace
%   PXX_f_mean: peak frequency from PSD trace

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

% power spectral densities
t1 = periods(:,1);
t2 = periods(:,2);

tsamp1 = floor(t1*trace_fs); %eeg start time 
tsamp2 = floor(t2*trace_fs); %eeg end time

PXX = [];
PXX_pk_f = [];
PXX_pk = [];

period_duration = [];

for i=1:numel(tsamp1)
    period_length_i = tsamp2(i)-tsamp1(i);
    if period_length_i < min_dur*trace_fs % periods shorter than 120 s are excluded from analysis
        continue
    end
    if tsamp2(i) > length(trace) % if last period ends after trace 
       tsamp2(i) = length(trace);
    end
    period_duration = [period_duration period_length_i/trace_fs];
    trace_i = trace(tsamp1(i):tsamp2(i));
    timetrace_i = trace_t(tsamp1(i):tsamp2(i));
    
    % detrend (and center around 0)
    [p,~,mu] = polyfit((1:numel(trace_i))',trace_i,5);
    f_y = polyval(p,(1:numel(trace_i))',[],mu);
    detrend_data = trace_i - f_y';        % Detrend data
    
    [pxx, f] = pwelch(detrend_data, [], [],[0:0.0005:0.1], trace_fs); %
    % [pxx, f] = pwelch(detrend_data, [], [],[0:0.002:0.1], trace_fs); %
    [pxx_pk_psd, max_idx] = max(pxx);
    PXX_pk = [PXX_pk pxx_pk_psd];
    pxx_pk_f = f(max_idx);
    PXX_pk_f = [PXX_pk_f pxx_pk_f];
    PXX = [PXX pxx'];
    
    if show_figure_indvdl
        figure
        set(gcf, 'Position',  [100, 300, 1500, 250])
        a = subplot(1,2,1);
            plot(timetrace_i,trace_i);
            hold on
            plot(timetrace_i,detrend_data);
            legend({'raw','fitted'})
            hold off
        b = subplot(1,2,2);
            plot(f,pxx);
    end
end

weightedMean_tracePXX = sum(period_duration.*PXX,2)/sum(period_duration); %period duration is used as weights
[PXX_pk_mean, PXX_NE_pk_idx] = max(weightedMean_tracePXX); % peak power from mean trace
PXX_f_mean = f(PXX_NE_pk_idx);

%prism_psd_NE = weighted_mean_PXX_NE/mean(weighted_mean_PXX_NE); % normalised power
psd_trace = weightedMean_tracePXX;
psd_freq = f;

if show_figure_mean
    % power spectral density plot
    figure
        plot(psd_freq,psd_trace)
        xlabel('frequency (Hz)');
        ylabel('PSD');
end

end