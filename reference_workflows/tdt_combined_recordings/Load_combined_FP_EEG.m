clear all
close all

% data structure:
    % 1) TDT file FP
    % 2) TDT file including EEG/EMG
    % 3) 1: 465 channel name
    % 4) 1: 405 channel name 
    % 5) 1: 560 channel name
    % 6) 2: 465 channel name
    % 7) 2: 405 channel name 
    % 8) 2: 560 channel name 
    % 9) EEG channel name
    % 10) EEG channel
    % 11) EMG channel name
    % 12) synchronization channel name FP rig
    % 13) synchronization channel name EEG rig
    % 14) interval for fitting (polyfit)


%build-up
name = {'file_destination_FP' 'file_destination_EEG' 'channel_name_blue_1' 'channel_name_violet_1' 'channel_name_red_1' 'channel_name_blue_2' 'channel_name_violet_2' 'channel_name_red_2' 'EEG channel name' 'EEG channel name' 'EMG channel name 1' 'synchronization pulse name FP rig' 'synchronization pulse name EEG rig'  'time period for fitting' };

%example - does not match the below code entirely (does not have two EEG channels
Mouse_117 = {'J:\CTN\NedergaardLAB\KjaerbyLab\Julia\Batch 1 LgDel\Sleep recordings\6h FP_EEG_combined\230929_117FPEEG6h' 'J:\CTN\NedergaardLAB\KjaerbyLab\Julia\Batch 1 LgDel\Sleep recordings\6h FP_EEG_combined\230929_117FPEEG6h' 'x65A' 'x05A' 'red' 'x65C' 'x05C' 'red' 'EEGw' 1 'EMG1' 'PtC0' 'PtC0' (1:20000)};
Mouse_124 = {'J:\CTN\NedergaardLAB\KjaerbyLab\Julia\Batch 1 LgDel\Sleep recordings\6h FP_EEG_combined\230929124_FPEEG6h' 'J:\CTN\NedergaardLAB\KjaerbyLab\Julia\Batch 1 LgDel\Sleep recordings\6h FP_EEG_combined\230929_117FPEEG6h' 'x65A' 'x05A' 'red' 'x65C' 'x05C' 'red' 'EEGw' 2 'EMG2' 'PtC0' 'PtC0' (1:20000)};


mouse = Mouse_117 ;
%% load data

data_FPrig = TDTbin2mat(mouse{1}); % FP rig 
data_EEGrig= TDTbin2mat(mouse{2}); %EEG rig - might be the same as above
%% extract channels

signal_fs = data_FPrig.streams.(mouse{3}).fs; % sampling frequency for fiber photometry signal
signal_465_1 = data_FPrig.streams.(mouse{3}).data; %signal
signal_405_1 = data_FPrig.streams.(mouse{4}).data; %isosbetstic control
%signal_560_FPrig = data_FPrig.streams.(mouse{5}).data; %red signal

signal_465_2 = data_FPrig.streams.(mouse{6}).data; %signal
signal_405_2 = data_FPrig.streams.(mouse{7}).data; %isosbetstic control
%signal_560_FPrig = data_FPrig.streams.(mouse{8}).data; %red signal

EEG_fs = data_EEGrig.streams.(mouse{9}).fs; %sampling frequency for EEG signal 

EEG = data_EEGrig.streams.(mouse{9}).data; %EEG signal
EEG = EEG(mouse{10},:); %add channel (1 or 2)
EMG = data_EEGrig.streams.(mouse{11}).data; %EMG 

%% remove period before TTL pulse

% TTL pusle for FP
TTL_FP = data_FPrig.epocs.(mouse{12}).onset;
first_TTL = TTL_FP(1)*signal_fs;
onset_FP = first_TTL;
if first_TTL<1
    onset_FP = 1;
end

% TTL pusle for EEG
TTL_FP_EEG = data_EEGrig.epocs.(mouse{12}).onset; %CHOOSE RIG THAT EEG IS ACQUIRED ON
first_TTL_EEG = TTL_FP_EEG(1)*EEG_fs;
onset_FP_EEG = first_TTL_EEG;
if first_TTL_EEG<1
    onset_FP_EEG = 1;
end

signal_465_1 = signal_465_1(onset_FP:end);
signal_405_1 = signal_405_1(onset_FP:end);

signal_465_2 = signal_465_2(onset_FP:end);
signal_405_2 = signal_405_2(onset_FP:end);

EEG = EEG(onset_FP_EEG:end);
EMG = EMG(onset_FP_EEG:end);


%% time signal

fs_signal_1 = 1:1:length(signal_465_1);
sec_signal_1 = fs_signal_1/signal_fs; % time vector for fiber photometry signal

fs_signal_2 = 1:1:length(signal_465_2);
sec_signal_2 = fs_signal_2/signal_fs; % time vector for fiber photometry signal

fs_signal_EEG = 1:1:length(EEG);
sec_signal_EEG = fs_signal_EEG/EEG_fs; % time vector for EEG signal

fs_signal_EMG = 1:1:length(EMG);
sec_signal_EMG = fs_signal_EMG/EEG_fs; % time vector for EMG signal

%% Normalize and plot
% Here the fluorescence traces are normalised based on a fit of the 405 nm
% channel. This should remove the drift in the 465 nm channel. make sure to
% check the fit in the plot and adjust fitting interval if the fit is not
% working properly.

MeanFilterOrder = 1000; % for smoothing
MeanFilter = ones(MeanFilterOrder,1)/MeanFilterOrder;

reg = polyfit(signal_405_1(round(mouse{14}*signal_fs)), signal_465_1(round(mouse{14}*signal_fs)), 1);
a = reg(1);
b = reg(2);
controlFit_465 = a.*signal_405_1 + b;
controlFit_465 =  filtfilt(MeanFilter,1,double(controlFit_465));
normDat = (signal_465_1 - controlFit_465)./controlFit_465;
delta_465_1 = normDat * 100;

figure
a = subplot(4,1,1);
    plot(sec_signal_1(1000:end), signal_405_1(1000:end));
    title('raw control');
b = subplot(4,1,2);
    plot(sec_signal_1(1000:end), signal_465_1(1000:end));
    title('raw signal');
c = subplot(4,1,3);
    plot(sec_signal_1(1000:end), signal_465_1(1000:end));
    hold on
    plot(sec_signal_1(1000:end), controlFit_465(1000:end));
    title('fitted control');
d = subplot(4,1,4);
    plot(sec_signal_1(1000:end), delta_465_1(1000:end));
    title('normalized signal');
linkaxes([a,b,c,d],'x');

% smoothing traces
delta465_filt_1 = filtfilt(MeanFilter,1,double(delta_465_1));
ds_factor_FP = 100; % also used for plotting later (section 9b)

% downsampling traces for plotting
ds_delta465_filt_1 = downsample(delta465_filt_1, ds_factor_FP);
ds_sec_signal_1 = downsample(sec_signal_1, ds_factor_FP); % for plotting

reg2 = polyfit(signal_405_2(round(mouse{14}*signal_fs)), signal_465_2(round(mouse{14}*signal_fs)), 1);
a2 = reg2(1);
b2 = reg2(2);
controlFit_465_2 = a2.*signal_405_2 + b2;
controlFit_465_2 =  filtfilt(MeanFilter,1,double(controlFit_465_2));
normDat_2 = (signal_465_2 - controlFit_465_2)./controlFit_465_2;
delta_465_2 = normDat_2 * 100;

figure
a = subplot(4,1,1);
    plot(sec_signal_2(1000:end), signal_405_2(1000:end));
    title('raw control');
b = subplot(4,1,2);
    plot(sec_signal_2(1000:end), signal_465_2(1000:end));
    title('raw signal');
c = subplot(4,1,3);
    plot(sec_signal_2(1000:end), signal_465_2(1000:end));
    hold on
    plot(sec_signal_2(1000:end), controlFit_465_2(1000:end));
    title('fitted control');
d = subplot(4,1,4);
    plot(sec_signal_2(1000:end), delta_465_2(1000:end));
    title('normalized signal');
linkaxes([a,b,c,d],'x');

% smoothing traces
delta465_filt_2 = filtfilt(MeanFilter,1,double(delta_465_2));
ds_factor_FP = 100; % also used for plotting later (section 9b)

% downsampling traces for plotting
ds_delta465_filt_2 = downsample(delta465_filt_2, ds_factor_FP);
ds_sec_signal_2 = downsample(sec_signal_2, ds_factor_FP); % for plotting

% Plot filtered trace(the index 1000:end removes the first second of the recoding for nicer plotting)
figure
a = subplot(4,1,1);
    plot(sec_signal_EEG, EEG);
    title('EEG2');
b = subplot(4,1,2);
    plot(sec_signal_EEG, EMG);
    title('EMG2');
c = subplot(4,1,3);
    plot(ds_sec_signal_1, ds_delta465_filt_1)
    title('signal 1');
d = subplot(4,1,4);
    plot(ds_sec_signal_2, ds_delta465_filt_2)
    title('signal 2');
linkaxes([a,b,c,d],'x');


% Z-score
delta465_Zscore_1 = (delta465_filt_1-mean(delta465_filt_1))/std(delta465_filt_1);
delta465_Zscore_2 = (delta465_filt_2-mean(delta465_filt_2))/std(delta465_filt_2);

