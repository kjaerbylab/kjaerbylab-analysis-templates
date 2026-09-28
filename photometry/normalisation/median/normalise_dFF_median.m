%% DESCRIPTION
% This script can be used as an alternative to the normalisation that is
% based on fitting the 405 nm channel. Instead the median of signal is used
% to get dF/F. This should only be used when 405 is not available or if it
% cannot be used due to artefacts in the 405 channel.

%% Normalisation (dF/F) using the median

MeanFilterOrder = 1000; % for smoothing
MeanFilter = ones(MeanFilterOrder,1)/MeanFilterOrder;

fs_signal = 1:length(signal_465);
sec_signal = fs_signal/signal_fs;

med_465 = median(signal_465);

% deltaF/F
delta_465 = ((signal_465 - med_465)/med_465)*100;

% you might need to detrend the data
delta_465_detrend = detrend(delta_465);

delta_465_filt = filtfilt(MeanFilter,1,double(delta_465_detrend));

ds_delta_465_filt = downsample(delta_465_filt, 100);

fs_signal = 1:1:length(delta_465_filt);
sec_signal = fs_signal/signal_fs;
ds_sec_signal = downsample(sec_signal, 100);

figure
plot(ds_sec_signal(1000:end), ds_delta_465_filt(1000:end))
title('dF/F');
