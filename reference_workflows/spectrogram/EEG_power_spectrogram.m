%% EEG power spectrum analysis
% here you plot a power spectrogram (heatmap) for your EEG data and band
% power traces for the defined EEG frequency bands (incl sigma trace).

Data_EEG = EEG_rawtrace_cut; % should be a vector containing EEG data to perform analysis on
power_bands = {[1, 4], [4, 8], [8, 15], [15, 30]}; % define delta, theta, sigma, and beta, repsectively

frw = 0:0.2:30;
frq = sampling_freq; % sampling frequnecy of EEG data
window = 5; %sec. 1 for 30 sec
    
[transition_spectrogram, F, T] = spectrogram(Data_EEG,round(frq*window),[],frw,frq,'yaxis');
mean_spectrogram = log(abs(transition_spectrogram));
time_spectrogram_zero = T; 
filtered_mean_spectrogram = imgaussfilt(mean_spectrogram, 4);
  
figure()
a = subplot(4, 1, 1); % leave out this subplot if you don't have/want FP data to be plotted
    plot_sleep(ds_sec_signal, ds_delta465_filt, sleepscore_time_cut, wake_woMA_binary_vector_cut, sws_binary_vector_cut, REM_binary_vector_cut, MA_binary_vector_cut);
    title('NE2m');
 
b = subplot(4, 1, 2);
    imagesc(time_spectrogram_zero, F, filtered_mean_spectrogram); %plot the log spectrum
    set(gca,'YDir', 'normal'); % flip the Y Axis so lower frequencies are at the bottom
    ylim([0, 30]);
    caxis([-6.7, -4])
    colormap(gca, 'parula');
    hold on
    for band_i = 1:length(power_bands)
        plot([-295, -295], power_bands{band_i}, 'LineWidth', 5)
    end
    title('EEG power');
    ylabel('freq (Hz)');

c = subplot(4, 1, 3);
    band_power_collector = [T];
    for band_i = 1:length(power_bands)
        power_band = power_bands{band_i};
        power_trace = mean(mean_spectrogram(find(F==power_band(1)):find(F==power_band(2)), :), 1);
        normalized_power_trace = power_trace;
        band_power_collector = [band_power_collector; normalized_power_trace];
        plot(time_spectrogram_zero, normalized_power_trace)
        hold on
    end
    legend({'delta','theta','sigma','beta'});
    
d = subplot(4, 1, 4);
    sigma = band_power_collector(4,:); % sigma power trace
    plot(time_spectrogram_zero, sigma)
    title ('sigma')
    xlabel('time (s)');
  
linkaxes([a,b,c,d],'x');