%% DESCRIPTION
% In this script you load fiber photometry traces and normalize them to get
% dF/F (or Z-score). The traces will also be aligned by cutting the first
% chunk of data leading up to the first TTL pulse

%% Specify mouse data
% Below you specify input arguments for each recording. Make sure to update
% the name of the channels according to your specific recordings. Adjust
% the fitting interval used for polyfit if the plotted fit looks off.

clear all

% data structure:
% 1) FP raw data <<<< here you put path for your FP data folder (see example format below)
% 2) EEG raw data 
% 3) 465 channel name
% 4) 405 channel name
% 5) TTL channel name
% 6) interval used for signal normalization
% 7) laser channel name - OPTIONAL (only used for optogenetic stimulations)

% mouse data
mouse = {'/Users/tmp942/Documents/FP/Isa_FP_EMG_EEG_040624' '' 'x465A' 'x405A' 'Pu1_' (1:10000)};

%% Load FP data
% Here fiber photometry data is loaded and cut according to the first TTL
% pulse.

data = TDTbin2mat(mouse{1});

% Display available fields in data.streams and data.epocs for debugging
disp('Available fields in data.streams:');
disp(fieldnames(data.streams));

disp('Available fields in data.epocs:');
disp(fieldnames(data.epocs));

% Check if the required fields are present
if isfield(data.streams, mouse{3})
    disp(['Field ', mouse{3}, ' found in data.streams.']);
else
    disp(['Field ', mouse{3}, ' NOT found in data.streams.']);
end

if isfield(data.streams, mouse{4})
    disp(['Field ', mouse{4}, ' found in data.streams.']);
else
    disp(['Field ', mouse{4}, ' NOT found in data.streams.']);
end

if isfield(data.epocs, mouse{5})
    disp(['Field ', mouse{5}, ' found in data.epocs.']);
else
    disp(['Field ', mouse{5}, ' NOT found in data.epocs.']);
end

% Proceed only if all required fields are present
if isfield(data.streams, mouse{3}) && isfield(data.streams, mouse{4}) && isfield(data.epocs, mouse{5})
    signal_fs = data.streams.(mouse{3}).fs;

    signal_465 = data.streams.(mouse{3}).data; % hSyn-NE2m
    signal_405 = data.streams.(mouse{4}).data; % autofluorescence

    % removing FP trace prior to first TTL pulse
    TTL_FP = data.epocs.(mouse{5}).onset;
    TTL_gap = diff(TTL_FP) > 10 + 1;
    if isempty(find(TTL_gap == 1, 1))
        TTL_onset = TTL_FP(1);  % when TTL pulse train is only started once
    else 
        TTL_onset = TTL_FP(find(TTL_gap == 1) + 1); % when TTL pulse train is started more than once
    end

    first_TTL = TTL_onset(1) * signal_fs; % sampling point # to start with
    onset_FP = first_TTL;

    signal_465 = signal_465(onset_FP:end);
    signal_405 = signal_405(onset_FP:end);
else
    error('Required fields are not present in the data. Please check the channel names and data file.');
end

%% Normalize and plot
% Here the fluorescence traces are normalized based on a fit of the 405 nm
% channel. This should remove the drift in the 465 nm channel. make sure to
% check the fit in the plot and adjust fitting interval if the fit is not
% working properly.

MeanFilterOrder = 1000; % for smoothing
MeanFilter = ones(MeanFilterOrder, 1) / MeanFilterOrder;

fs_signal = 1:length(signal_465);
sec_signal = fs_signal / signal_fs;

[p, ~, mu] = polyfit(signal_405(round(mouse{6} * signal_fs)), signal_465(round(mouse{6} * signal_fs)), 1); % three-output version of polyfit help to scale and center data
controlFit = polyval(p, signal_405, [], mu);
controlFit = filtfilt(MeanFilter, 1, double(controlFit));
normDat = (signal_465 - controlFit) ./ controlFit;
delta_465 = normDat * 100;

figure
a = subplot(4, 1, 1);
    plot(sec_signal(1000:end), signal_405(1000:end));
    title('raw control');
b = subplot(4, 1, 2);
    plot(sec_signal(1000:end), signal_465(1000:end));
    title('raw signal');
c = subplot(4, 1, 3);
    plot(sec_signal(1000:end), signal_465(1000:end));
    hold on
    plot(sec_signal(1000:end), controlFit(1000:end));
    title('fitted control');
d = subplot(4, 1, 4);
    plot(sec_signal(1000:end), delta_465(1000:end));
    title('normalized signal');
linkaxes([a, b, c, d], 'x');

% smoothing traces
delta465_filt = filtfilt(MeanFilter, 1, double(delta_465));
ds_factor_FP = 100; % also used for plotting later

% downsampling traces for plotting
ds_delta465_filt = downsample(delta465_filt, ds_factor_FP);
ds_sec_signal = downsample(sec_signal, ds_factor_FP); % for plotting

% Plot filtered trace (the index 1000:end removes the first second of the recording for nicer plotting)
figure
plot(ds_sec_signal, ds_delta465_filt)
title('dF/F');

% Z-score
delta465_Zscore = (delta465_filt - mean(delta465_filt)) / std(delta465_filt);

%% Load laser stimulations saved with the TDT data tank (OPTIONAL)
% In case you did optogenetic stimulations (or other stimulations) that are
% controlled by Synapse and saved as an epoc channel, you can load them with
% the following script. Just specify the field name of the stimulation as
% recorded in TDT data tank.

if length(mouse) > 6 && ~isempty(mouse{7}) && isfield(data.epocs, mouse{7})
    % load laser on- and offsets
    laser_on = data.epocs.(mouse{7}).onset - TTL_onset;
    laser_on = laser_on(laser_on >= 0);
    laser_off = data.epocs.(mouse{7}).offset - TTL_onset;
    laser_off = laser_off(laser_off >= 0);

    % Create binary vector from on/offsets
    laser_binary_vector = zeros([1, length(sec_signal)]); 
    for i = 1:length(laser_on)
        on = round(laser_on(i) * signal_fs); 
        off = round(laser_off(i) * signal_fs);
        laser_binary_vector(on:off) = 1;
    end

    ds_laser_binary_vector = downsample(laser_binary_vector, ds_factor_FP);

    figure
    a = subplot(2, 1, 1);
        plot(ds_sec_signal, ds_delta465_filt)
        title('dF/F');
    b = subplot(2, 1, 2);
        plot(ds_sec_signal, ds_laser_binary_vector)
        ylim([-1 2])
        title('laser');
    linkaxes([a, b], 'x');
end
