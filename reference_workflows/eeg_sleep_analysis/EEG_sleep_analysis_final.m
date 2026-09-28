%% 1) Setting up
clear all
close all

% First, you need to make a variable for your subject. The second argument
% should be the path to your .exp file. This script is specifically for
% EEG/EMG and sleep analysis using .exp files. Regardless of which setup
% iyou used to record your EEG/EMG, you can get .exp file using the
% sleepscore app. 
% The third argument in your subject variable should be the day-month-year
% and time (see example below) when your recording started. Cehck in your
% original files!

no25 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\no25 whole\20220125_VC_25_2022-01-25_19-46-09-994.exp'  '01-Jan-2022 19:46:09'};
no747 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\20220903_747_AT_scoredx2\20220903_747_AT_2022-09-03_19-20-40-898.exp' '01-Jan-2022 19:20:40'};
no743 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\20220903_743_AT_scoredx2\__20220903_743_AT_2022-09-03_19-20-40-898.exp' '01-Jan-2022 19:20:40'};
no23 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\no23_whole file\20220119_VC_23_2022-01-19_19-56-08-643.exp' '01-Jan-2022 19:44:16'};
no1 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\no1_scored (converted only)\no1_converted_scored\no1_2022-01-17_10-26-12-234.exp' '02-Jan-2022 10:26:12'};
no5 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\no5_scored\no5_2022-01-17_10-26-12-234.exp' '02-Jan-2022 10:26:12'};
no9 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\no9 whole\20210122_VC_9_2022-01-22_20-19-40-318.exp' '01-Jan-2022 20:19:40'};
no11 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\no11 whole\20220119_VC_11_2022-01-19_19-56-08-643.exp' '01-Jan-2022 19:56:08'};
no19p1 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\no19 whole\no19_scored_2024_03_39_9.exp' '01-Jan-2022 19:46:09'};
no19p2 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\20220125_VC_19_scored\NO19_SCORE_finished.exp' '01-Jan-2022 19:46:09'};
no3 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\no3 whole\20220119_VC_3_2022-01-19_19-56-08-643.exp' '01-Jan-2022 19:56:08'};
no21 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Laurence\05+06.05\APPPS11\concatAPPPS11' '06-May-2024 09:01:02'};
no17 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\no17_whole\no17_2022-01-17_10-26-12-234.exp' '02-Jan-2022 10:26:12'};
no27 = {'x' 'J:\CTN\NedergaardLAB\Personal_folders\Celia Kjaerby\Viviane Master thesis project 2022-2023\Aim 1 Pilot data\20220119_Sleep and Aging\Sleepscores corrected - Yi and Klaudia\no27 whole\20220128_VC_27_2022-01-28_19-48-48-038.exp' '01-Jan-2022 19:48:48'};

mouse= no25; % Change to the subject you want to analyze
t1={(mouse{3})}; % Time when recording is started
t2={'02-Jan-2022 19:00:00'}; % Change to the day and time you want to start analyzing from!!
analysis_hours = 24; % Change! Specify how many HOURS (can be 0.5) from your chosen start time you want to be looking at!

%% 2) Extract data from exp. file

ViewpointData.FileInfo=loadEXP([mouse{2}],'no');
% Load sleepscores
TimeReldebSec=0;
TimeRelEndSec=ViewpointData.FileInfo.BinFiles.Duration;
[FullHypno,TimeScaleAbs,TimeScaleBin,TimeScaleHypno]=ExtractFullHypno(ViewpointData,1);

% Load EEG & EMG
TimeReldebSec=0; % Start extract data from the beginning (first bin)
TimeRelEndSec=inf; % Inf to include all data (until last bin)
[Data,Time]=ExtractContinuousData([],ViewpointData.FileInfo,[],TimeReldebSec, TimeRelEndSec,[],1);
sampling_freq = ViewpointData.FileInfo.Fs; % Sampling frequency
frq = sampling_freq;
EMG_rawtrace = Data(1,1:end);
EEG_rawtrace = Data(2,1:end);
EEG_time = (1:length(EEG_rawtrace));

t11=datevec(datenum(t1));
t22=datevec(datenum(t2));
interval_s = etime(t22,t11); % This calculates the interval from when recording was started to when we want to start analysing
time_correction =-4; %change it if you need to correct time. add time to shit the sleepscoring to the left. vice versa
FullHypno_h = FullHypno((interval_s+1+time_correction):(analysis_hours*3600+interval_s+time_correction));

wake_binary_vector = [FullHypno_h==1]; % Creates a binary vector for wake state
sws_binary_vector = [FullHypno_h==2]; % Creates a binary vector for NREM state
REM_binary_vector = [FullHypno_h==4]; % Creates a binary vector for REM state

[wake_onset, wake_offset] = binary_to_OnOff(wake_binary_vector); % Finds onsets and offset of wake periods
[sws_onset, sws_offset] = binary_to_OnOff(sws_binary_vector); % Finds onsets and offset of NREM periods
[REM_onset, REM_offset] = binary_to_OnOff(REM_binary_vector); % Finds onsets and offset of REM periods

wake_duration = wake_offset-wake_onset; % Finds durations of all wake periods
duration_sws = sws_offset-sws_onset; % Finds durations of all NREM periods
REM_duration = REM_offset-REM_onset; % Finds durations of all REM periods

wake_periods = [wake_onset wake_onset+wake_duration]; % Puts wake onsets and offsets into one matrix
sws_periods = [sws_onset sws_onset+duration_sws]; % Puts NREM onsets and offsets into one matrix
REM_periods = [REM_onset REM_onset+REM_duration]; % Puts REM onsets and offsets into one matrix

%% 3) Interpolate gaps in EEG/EMG 
% Some recordsings are automatically backed up at 18.00. These recordigns have a gap in EEG/EMG traces that must be
% removed to run the spectogram function. Even if your recording doesn't
% have gaps, run this part, it is quick and won't affect your analysis.

EEG_NaNs = find(isnan(EEG_rawtrace)); % Finds the gaps

if ~isempty(EEG_NaNs)
    EEG_nans = isnan(EEG_rawtrace); % identify NaNs
    EEG_nans_n = 1:numel(EEG_rawtrace); % vector of indices, used for indexing below
    EEG_intpl = EEG_rawtrace; % copy of velocity used for interpolation
    EEG_intpl(EEG_nans) = interp1(EEG_nans_n(~EEG_nans), EEG_rawtrace(~EEG_nans), EEG_nans_n(EEG_nans));
    EEG_rawtrace = EEG_intpl;
    
    EMG_nans = isnan(EMG_rawtrace); % identify NaNs
    EMG_nans_n = 1:numel(EMG_rawtrace); % vector of indices, used for indexing below
    EMG_intpl = EMG_rawtrace; % copy of velocity used for interpolation
    EMG_intpl(EMG_nans) = interp1(EMG_nans_n(~EMG_nans), EMG_rawtrace(~EMG_nans), EMG_nans_n(EMG_nans));
    EMG_rawtrace = EMG_intpl;
end

if isnan(EEG_rawtrace(end))
    EEG_rawtrace = EEG_rawtrace(1:end-1);
    EMG_rawtrace = EMG_rawtrace(1:end-1);
    EEG_time = EEG_time(1:end-1);
end


intervalss = round(interval_s*sampling_freq); % Start point of your analysis period in EEG frequency
stoptime = round(analysis_hours*3600*sampling_freq+(intervalss+1)); % Stop point of your analysis period in EEG frequency

EEG = EEG_rawtrace((intervalss+1):stoptime); % This selects the time period that you want to analyze from the raw EEG trace
EMG = EMG_rawtrace((intervalss+1):stoptime); % This selects the time period that you want to analyze from the raw EMG trace

% EEG(1:2*frq) = [];
% EMG(1:2*frq) = [];
% EMG(end:end+(2*frq)) = 0;
% EEG(end:end+(2*frq)) = 0;
EEG_time = (1:length(EEG))./sampling_freq; % Time of each value in the EEG vector
Duration = EEG_time(end); % Time in hours of your period of analysis



%% 4) This figure is super heavy to work with. Better to skip, but it's a good check that the traces and sleepscored align!!

% Time vector for sleep scoring (1 Hz)
sleepscore_time = 0:length(wake_binary_vector)-1; % Should be same length for wake/sws/REM binary vectors

fig = figure;
a = subplot(2,1,1);
    plot_sleep(downsample(EEG_time, 10), downsample(EMG,10), sleepscore_time, wake_binary_vector, sws_binary_vector, REM_binary_vector);
    xlabel('time (s)');
    ylabel('EMG (V)');
b = subplot(2,1,2);
    plot_sleep(downsample(EEG_time, 10), downsample(EEG,10), sleepscore_time, wake_binary_vector, sws_binary_vector, REM_binary_vector);
    xlabel('time (s)');
    ylabel('EEG (V)');
linkaxes([a,b],'x');

h = datacursormode(fig);
    h.UpdateFcn = @DataCursor_custom;
    h.SnapToDataVertex = 'on';
    datacursormode on

%% 5) Dividing wake bouts into microarousals (MA) and wake w/o MA

MA_maxdur = 15; % Maximum duration of microarrousal
MA_idx = find(wake_duration < MA_maxdur);
MA_onset = wake_onset(MA_idx);
MA_duration = wake_duration(MA_idx);
MA_binary_vector = zeros([1, round(Duration)]);
for i=1:length(MA_onset) % Making time vector for EEG scoring (frequency = 1Hz)
    t = MA_onset(i)+1;
    d = MA_duration(i)-1;
    MA_binary_vector(t:t+d) = 1;
end

% Remove micrarrousal from wake vectors
wake_woMA_onset = wake_onset;
wake_woMA_onset(MA_idx) = [];
wake_woMA_duration = wake_duration;
wake_woMA_duration(MA_idx) = [];
wake_woMA_binary_vector = zeros([1, round(Duration)]);
for i=1:length(wake_woMA_onset) % Making time vector for EEG scoring (frequency = 1Hz)
    t = wake_woMA_onset(i)+1;
    d = wake_woMA_duration(i)-1;
    wake_woMA_binary_vector(t:t+d) = 1;
end

wake_binary_vector = wake_woMA_binary_vector;
% 2-column vectors with on- and offsets for each state
MA_periods = [MA_onset MA_onset+MA_duration];
wake_woMA_periods = [wake_woMA_onset wake_woMA_onset+wake_woMA_duration];
wake_woMA_offset = wake_woMA_periods(:,2);



%% 6) Re-classify MA as NREM using boutscore_vector
% Here you can pool MAs with NREM sleep which can be beneficial for some
% analyses related to infraslow oscillations (eg. PSD analysis), where you
% don't want to divide your traces into short/pure NREM bouts

% State transitions (uncut vectors)
% Creating one vector with different behaviors represented by unique
% numbers (1=wake, 4=sws, 9=REM, 15=MA) at frequency 1Hz
boutscore_vector = zeros([1, round(Duration)]);

for i=1:length(sws_onset)
    t = sws_onset(i)+1;
    d = duration_sws(i)-1;
    boutscore_vector(t:t+d) = 4; % sws=4
end

if ~isnan(REM_onset)
    for i=1:length(REM_onset)
        t = REM_onset(i)+1;
        d = REM_duration(i)-1;
        boutscore_vector(t:t+d) = 9; %REM=9
    end
end

for i=1:length(MA_onset)
    t = MA_onset(i)+1;
    d = MA_duration(i)-1;
    boutscore_vector(t:t+d) = 15; %MA=15
end

% Re-classify MA as NREM
NREM_incl_MA_vector = sws_binary_vector + MA_binary_vector;
[NREM_incl_MA_onset, NREM_incl_MA_offset] = binary_to_OnOff(NREM_incl_MA_vector);
NREM_incl_MA_duration = NREM_incl_MA_offset - NREM_incl_MA_onset;

%% 7) Make standard hypnogram for plotting

collect_ = NaN(1, length(wake_binary_vector)); % A vector for wake, NREM and REM (MAs are considered wake here)
collect_t = NaN(1, length(wake_binary_vector)); % A vector for collecting NREM incl MA
for i = 1:length(wake_binary_vector)
    if wake_binary_vector(i) == 1
        collect_(i) = 3;
    end

     if sws_binary_vector(i) == 1
        collect_(i) = 1;
     end

     if REM_binary_vector(i) == 1
        collect_(i) = 2;
     end
     if MA_binary_vector(i) == 1
        collect_(i) = 4;
     end
     if MA_binary_vector(i) == 1 | sws_binary_vector(i) == 1
         collect_t(i) = 1;
     end
end

%% 8) Analysis of sleep stages - proportions

% Here you specify which over how many hours (it can be eveyr half an hour,
% every 10 minutes, whatever you want) you need information about each
% sleep stage
start_x = 1; % CHANGE, start hour of your analysis
y = 1; % CHANGE! If you want information per hour, keep it at 1. Per 2h, change to 2, per half an hour, change to 0.5 
stop_x = 24; % CHANGE, stop hour of your analysis
periods_number= length(start_x:y:stop_x);

for i=start_x:y:stop_x % Change! (For example if you want from the first hour to the third hour every half an hour, you would do: 1:0.5:3
    sleepscoring_part=collect_((i-1)*3600+1:i*3600);
    NREM_part(i)=sum(sleepscoring_part==1); % NREM_part gives you info about the total duration of NREM per specified time (per hour/half an hour/2 hours)
    REM_part(i)=sum(sleepscoring_part==2); % Same for REM
    MA_part(i)=sum(sleepscoring_part==4); % Same for MAs
    Wake_part(i)=sum(sleepscoring_part==3); % Same for wake
    sleepscoring_part2=NREM_incl_MA_vector((i-1)*3600+1:i*3600);
    NREM_incl_MA_part(i) = sum(sleepscoring_part2 == 1); % Same for NREM incl MAs
end
% You can export the vectors above to Prism to have duration of each period
% per hour/2h/half an hour etc.

 % Percentage time spent in each state per hour
 NREM_per=NREM_part./(3600*y);
 NREM_incl_MA_per=NREM_incl_MA_part./(3600*y);
 MA_per=MA_part./(3600*y);
 REM_per=REM_part./(3600*y);
 wake_per=Wake_part./(3600*y);
 % You can export the vectors above to Prism to have percentage of each period
 % per hour/2h/half an hour etc.

% Here we will get mean duration of bout per specified period (per h/0.5h
% etc) as well as mean duration per hour (or other period) and number of
% bouts per hour (or other period) 
NREM_count=zeros(1,periods_number);
NREM_duration_sum=zeros(1,periods_number);
for i=1:length(sws_onset)
    NREM_hour=floor(sws_onset(i)./(3600*y))+1;
    if NREM_hour>(periods_number*y)
        NREM_hour=(periods_number*y);
    end
    NREM_duration_sum(NREM_hour)=NREM_duration_sum(NREM_hour)+duration_sws(i);
    NREM_count(NREM_hour)=NREM_count(NREM_hour)+1;
end
NREM_mean=NREM_duration_sum./NREM_count;

NREM_incl_MA_count=zeros(1,periods_number);
NREM_incl_MA_duration_sum=zeros(1,periods_number);
for i=1:length(NREM_incl_MA_onset)
    NREM_incl_MA_hour=floor(NREM_incl_MA_onset(i)./(3600*y))+1;
    if NREM_incl_MA_hour>(periods_number*y)
        NREM_incl_MA_hour=(periods_number*y);
    end
    NREM_incl_MA_duration_sum(NREM_incl_MA_hour)=NREM_incl_MA_duration_sum(NREM_incl_MA_hour)+NREM_incl_MA_duration(i);
    NREM_incl_MA_count(NREM_incl_MA_hour)=NREM_incl_MA_count(NREM_incl_MA_hour)+1;
end
NREM_incl_MA_mean=NREM_incl_MA_duration_sum./NREM_incl_MA_count;

MA_count=zeros(1,periods_number);
MA_duration_sum=zeros(1,periods_number);
for i=1:length(MA_onset)
    MA_hour=floor(MA_onset(i)./(3600*y))+1;
    if MA_hour>(periods_number*y)
        MA_hour=(periods_number*y);
    end
    MA_duration_sum(MA_hour)=MA_duration_sum(MA_hour)+MA_duration(i);
    MA_count(MA_hour)=MA_count(MA_hour)+1;
end
MA_mean=MA_duration_sum./MA_count;

REM_count=zeros(1,periods_number);
REM_duration_sum=zeros(1,periods_number);
for i=1:length(REM_onset)
    REM_hour=floor(REM_onset(i)./(3600*y))+1;
    if REM_hour>(periods_number*y)
        REM_hour=(periods_number*y);
    end
    REM_duration_sum(REM_hour)=REM_duration_sum(REM_hour)+REM_duration(i);
    REM_count(REM_hour)=REM_count(REM_hour)+1;
end
REM_mean=REM_duration_sum./REM_count;


wake_count=zeros(1,periods_number);
wake_duration_sum=zeros(1,periods_number);
for i=1:length(wake_woMA_onset)
    wake_hour=floor(wake_woMA_onset(i)./(3600*y))+1;
    if wake_hour>(periods_number*y)
        wake_hour=(periods_number*y);
    end
    wake_duration_sum(wake_hour)=wake_duration_sum(wake_hour)+wake_duration(i);
    wake_count(wake_hour)=wake_count(wake_hour)+1;
end
wake_mean=Wake_part./wake_count;

% MA per minute of NREM
MA_per_NREM=MA_count./(NREM_duration_sum/60);

% % Total duration and cum. perc per dark and light phase
% Stages_total_1_12 = [sum(NREM_part(1:12))  sum(Wake_part(1:12)) sum(REM_part(1:12)) sum(MA_part(1:12)) sum(NREM_incl_MA_part(1:12))]';
% % Stages_total_12_24 = [sum(NREM_part(13:24))  sum(Wake_part(13:24)) sum(REM_part(13:24)) sum(MA_part(13:24)) sum(NREM_incl_MA_part(13:24))]';
% Percentage_1_12 = [mean(NREM_per(1:12)) mean(wake_per(1:12)) mean(REM_per(1:12)) mean(MA_per(1:12)) mean(NREM_incl_MA_per(1:12))]';
% % Percentage_12_24 = [mean(NREM_per(13:24)) mean(wake_per(13:24)) mean(REM_per(13:24)) mean(MA_per(13:24)) mean(NREM_incl_MA_per(13:24))]';

%% 10) Get the spectogram for different sleep phases
start_time = 0; % Change, starting hour for PSD analysis
stop_time = 12; % Change, last hour for PSD analysis
stage = 4; % CHANGE!! Choose 1 for NREM incl MAs, 2 for NREM, 3 for REM, 4 for wake
analysis_window = 5; % Change if needed! 

frq = sampling_freq; % Sampling frequnecy of EEG data
frw = 0:0.2:100;
power_bands = {[0.1,1],[1, 4], [4, 8], [8, 15], [15, 30],[30, 60], [60 100]};
start_sampling = start_time*3600+1;
stop_sampling =stop_time*3600;

REM_binary_vector_cut = REM_binary_vector(start_sampling :stop_sampling); % Choosing REM periods that happen only within the specified time period
sws_binary_vector_cut = sws_binary_vector(start_sampling :stop_sampling); % Choosing NREM periods that happen only within the specified time period
wake_binary_vector_cut =wake_binary_vector(start_sampling :stop_sampling); % Choosing wake periods that happen only within the specified time period
MA_binary_vector_cut = MA_binary_vector(start_sampling :stop_sampling);
NREMinclMA_binary_vector_cut= NREM_incl_MA_vector(start_sampling :stop_sampling); % Choosing NREM incl MAs periods that happen only within the specified time period
sleepscore_time_cut = 0:length(wake_binary_vector_cut)-1; % Should be same length for wake/sws/REM binary vectors

[wake_onset_cut, wake_offset_cut] = binary_to_OnOff(wake_binary_vector_cut); % Finding onset and offsets of those wake periods that happen only within the specified time interval
wake_duration_cut = wake_offset_cut - wake_onset_cut; % Finding duration of each of those periods

[sws_onset_cut, sws_offset_cut] = binary_to_OnOff(sws_binary_vector_cut); % Finding onset and offsets of those NREM periods that happen only within the specified time interval
sws_duration_cut = sws_offset_cut - sws_onset_cut;

[MA_onset_cut, MA_offset_cut] = binary_to_OnOff(MA_binary_vector_cut);
MA_duration_cut = MA_offset_cut - MA_onset_cut;

[REM_onset_cut, REM_offset_cut] = binary_to_OnOff(REM_binary_vector_cut); % Finding onset and offsets of those REM periods that happen only within the specified time interval
REM_duration_cut = REM_offset_cut - REM_onset_cut;

[NREMinclMA_onset_cut, NREMinclMA_offset_cut] = binary_to_OnOff(NREMinclMA_binary_vector_cut); % Finding onset and offsets of those NREM incl MAs periods that happen only within the specified time interval
NREMinclMA_duration_cut = NREMinclMA_offset_cut-NREMinclMA_onset_cut;


EMG_rawtrace_cut = EMG(start_sampling*sampling_freq:stop_sampling*sampling_freq);
EEG_rawtrace_cut = EEG(start_sampling*sampling_freq:stop_sampling*sampling_freq);
EEG_time_cut = (1:length(EEG_rawtrace_cut))/sampling_freq;

t1 = cell(1,4); % initiating a cell for saving the vectors for rach stage
t1{1} = NREMinclMA_onset_cut;
t1{2} = sws_onset_cut;
t1{3} = REM_onset_cut;
t1{4} = wake_onset_cut;

t2 = cell(1,5);
t2{1} = NREMinclMA_offset_cut;
t2{2} = sws_offset_cut;
t2{3} = REM_offset_cut;
t2{4} = wake_offset_cut;


tsamp1 = floor(t1{stage}*sampling_freq); % EEG start time 
tsamp2 = floor(t2{stage}*sampling_freq); % EEG end time


PXX = [];
All_data_collect = [];
PXX_pk = []; 
PXX_pk_f =[];
PXXlog = [];

for i=1:numel(tsamp1)
    if tsamp1(i) == 0
        tsamp1(i) = 1;
    else
    end
    All_data{i} = EEG_rawtrace_cut(tsamp1(i):tsamp2(i));
    All_data_cut = EEG_rawtrace_cut(tsamp1(i):tsamp2(i));
    All_data_collect = [All_data_collect All_data_cut];
    [pxx, f] = pwelch(All_data{i}, [], [],[0:0.2:100], sampling_freq);
    logpxx = 10*log10(pxx);
    FX{i} = f;
    PXX(:,i) = logpxx; 
end

mean_PXX = mean(PXX,2); % Export to Prism - power per frequency
f = f'; % Export to Prism as x-axis, different frequencies 



for power_number = 1:7 % Put 2:5 if you are only interested in the basic frequencies (delta, theta, sigma, beta)
    % switch power_number
    %     case 1
    %         power_band = power_bands{1};
    %     case 2
    %         power_band = power_bands{2};
    %     case 3
    %         power_band = power_bands{3};
    %     case 4
    %         power_band = power_bands{4};
    %     case 5
    %         power_band = power_bands{5};
    %     case 6
    %         power_band = power_bands{6};
    %     case 7
    %         power_band = power_bands{7};
    %     otherwise
    %         error('Invalid power number');
    % end
    % 

    power_band = power_bands{power_number};
    [transition_spectrogram, F, T] = spectrogram(All_data_collect,round(frq*analysis_window),[] ,frw,frq,'yaxis');
    mean_spectrogram = log(abs(transition_spectrogram));
    time_spectrogram_zero = T; 
    filtered_mean_spectrogram = imgaussfilt(mean_spectrogram, 4); 
    specto_fs = length(T)/T(end);
    normalization_factor=mean(mean(filtered_mean_spectrogram));
    power_trace = mean(filtered_mean_spectrogram(find(F==power_band(1)):find(F==power_band(2)), :), 1);
    normalized_power_trace = power_trace / -normalization_factor + 2;


    mean_power_trace{power_number} = normalized_power_trace; 
 
    [pks, pklocs, w, p] = findpeaks(normalized_power_trace, T, 'MinPeakDistance',10, 'MinPeakProminence',0.008); % Find peaks method for more detailed analysis
    
    % Calculate results for this power number
    Band_freq = length(pks)/(length(All_data_collect)/sampling_freq);
    Band_perc90 = prctile(normalized_power_trace,90);
    Band_perc10 = prctile(normalized_power_trace,10);
    Band_Ampl = Band_perc90 - Band_perc10; 
    Band_mean_power = mean(normalized_power_trace);
    results_frequency{power_number} = [Band_freq, Band_Ampl, Band_mean_power]; % Stores band frequency, band amplitude and power for NREM -> wake transitions, ready for export to Prism
end
   
figure()
   a= subplot(3, 1, 1);
    imagesc(time_spectrogram_zero, F, filtered_mean_spectrogram); %plot the log spectrum
    set(gca,'YDir', 'normal'); % flip the Y Axis so lower frequencies are at the bottom
    ylim([0, 30]);
    caxis([-7.5, -5])
    colormap(gca, 'parula');
    hold on
    for band_i = 1:length(power_bands)
        plot([-295, -295], power_bands{band_i}, 'LineWidth', 5)
    end
    title('EEG power');
    ylabel('freq (Hz)');

  b= subplot(3, 1, 2);
    band_power_collector = [T];
    for band_i = 1:length(power_bands)
        power_band = power_bands{band_i};
        power_trace = mean(mean_spectrogram(find(F==power_band(1)):find(F==power_band(2)), :), 1);
        normalized_power_trace = power_trace;
        band_power_collector = [band_power_collector; normalized_power_trace]; % the first line --T; then the order of power_bands your defined
        plot(time_spectrogram_zero, normalized_power_trace)
        hold on
    end
    legend({'infraslow' 'delta','theta','sigma','beta' 'low gamma' 'high gamma'});
    
 c= subplot(3, 1, 3);
    sigma = band_power_collector(5,:); % sigma power trace
    plot(time_spectrogram_zero, sigma)
    title ('sigma')
    xlabel('time (s)');
  
linkaxes([a,b,c],'x');

infraslow = band_power_collector(2,:);
delta = band_power_collector(3,:);
theta = band_power_collector(4,:);
sigma = band_power_collector(5,:);
beta = band_power_collector(6,:);
low_gamma = band_power_collector(7,:);
high_gamma = band_power_collector(8,:);

mean_infraslow = mean(infraslow); % It gives you average (unnormalized) infraslow power in the period you specified
mean_delta = mean(delta); % It gives you average (unnormalized) delta power in the period you specified
mean_theta = mean(theta); % It gives you average (unnormalized) theta power in the period you specified
mean_sigma = mean(sigma); % It gives you average (unnormalized) sigma power in the period you specified
mean_beta = mean(beta); % It gives you average (unnormalized) beta power in the period you specified
mean_low_gamma = mean(low_gamma); % It gives you average (unnormalized) low gamma power in the period you specified
mean_high_gamma = mean(high_gamma); % It gives you average (unnormalized) high gamma power in the period you specified



% PSD of insfraslow oscillations in the different sleep stages
       
slow_data = cell(1, numel(tsamp1));

PXX = [];
PXXlog = [];
PXX_pk_f = [];
PXX_pk = [];

slow_data_collect = [];
period_duration = [];

for i=1:numel(tsamp1)
    period_length_i = tsamp2(i)-tsamp1(i);

    if tsamp2(i) > length(EEG_rawtrace_cut) % if last period ends after trace 
       tsamp2(i) = length(EEG_rawtrace_cut);
    end
    period_duration = [period_duration period_length_i/frq];
    slow_data{i} = EEG_rawtrace_cut(tsamp1(i):tsamp2(i));
    timetrace_i = EEG_time_cut(tsamp1(i):tsamp2(i));
    
    %detrend (and center around 0)
    [p,s,mu] = polyfit((1:numel(slow_data{i}))',slow_data{i},5);
    f_y = polyval(p,(1:numel(slow_data{i}))',[],mu);
    detrend_data = slow_data{i} - f_y';        % Detrend data
    
    [pxx, f] = pwelch(detrend_data, [], [],[0:0.002:0.1], frq); %
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
        plot(timetrace_i,slow_data{i});
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


%% 12) State transitions - we will analyze different frequency bands across state transitions
% Creating one vector with different behaviors represented by unique
% numbers (1=wake, 4=sws, 9=REM, 15=MA) at frequency 1Hz
  

boutscore_vector = zeros([1, round(Duration)]);

% Here using the aligned "cut" vectors
if isnan(wake_onset_cut)~=1
    for i=1:length(wake_onset_cut)
        t = wake_onset_cut(i)+1;
        d = wake_duration_cut(i)-1;
        boutscore_vector(t:t+d) = 1; % wake=1
    end
end


if isnan(sws_onset_cut)~=1
    for i=1:length(sws_onset_cut)
        t = sws_onset_cut(i)+1;
        d = sws_duration_cut(i)-1;
        boutscore_vector(t:t+d) = 4; % sws=4
    end
end

if isnan(REM_onset_cut)~=1
    for i=1:length(REM_onset_cut)
        t = REM_onset_cut(i)+1;
        d = REM_duration_cut(i)-1;
        boutscore_vector(t:t+d) = 9; %REM=9
    end
end

if isnan(MA_onset_cut)~=1
    for i=1:length(MA_onset_cut)
        t = MA_onset_cut(i)+1;
        d = MA_duration_cut(i)-1;
        boutscore_vector(t:t+d) = 15; %MA=15
    end
end

% Vectors indicate time of transitions in seconds
transition_sws_wake =  find(diff(boutscore_vector)== -3);
transition_REM_wake =  find(diff(boutscore_vector)== -8);
transition_sws_MA =  find(diff(boutscore_vector)== 11);
transition_REM_sws =  find(diff(boutscore_vector)== -5);
transition_sws_REM =  find(diff(boutscore_vector)== 5);
transition_REM_MA =  find(diff(boutscore_vector)== 6);


before = 100; %sec, change if needed!
after = 100; %sec, change if needed!

analysis_window = 5; % Change if needed. For longer recordings, 5 is okay, for shorter maybe lower? 
power_bands = {[0.1,1],[1, 4], [4, 8], [8, 15], [15, 30],[30, 60], [60 100]};
results_sws_wake = cell(7, 1); 
results_sws_REM = cell(7, 1); 
results_sws_MA = cell(7, 1); 
results_REM_MA = cell(7, 1); 
results_REM_wake = cell(7, 1); 

for power_number = 1:7 % Put 2:5 if you are only interested in the basic frequencies (delta, theta, sigma, beta)
    switch power_number
        case 1
            power_band = power_bands{1};
        case 2
            power_band = power_bands{2};
        case 3
            power_band = power_bands{3};
        case 4
            power_band = power_bands{4};
        case 5
            power_band = power_bands{5};
        case 6
            power_band = power_bands{6};
        case 7
            power_band = power_bands{7};
        otherwise
            error('Invalid power number');
    end
    

power_band = power_bands{power_number};
sampling_freq = round(sampling_freq);

collect_sws_wake = []; % Initiate vector for collection of all transitions from NREM -> wake
analysis_window = 1; % Change if needed! 
for i = 1:length(transition_sws_wake)
    trans = transition_sws_wake(i);
    if trans < before || trans > EEG_time(end)-100
        continue
    end
    EEG_transition = EEG_rawtrace_cut((trans-before)*sampling_freq: (trans+after)*sampling_freq); % Select EEG periods at state transitions
    [transition_spectrogram, F, T] = spectrogram(EEG_transition,round(frq*analysis_window),[],frw,frq,'yaxis'); % Get the spectrogram 
    mean_spectrogram = log(abs(transition_spectrogram)); 
    time_spectrogram_zero = T; 
    filtered_mean_spectrogram = imgaussfilt(mean_spectrogram, 4);
    % specto_fs = length(T)/T(end);
    % norm_time = abs(T-(100/3*2)); 
    % norm_sampling = find(norm_time == min(norm_time));
    % normalization_factor = mean(mean(mean_spectrogram(find(F==total_power_band(1)):find(F==total_power_band(2)), 1:norm_sampling)));
    normalization_factor=mean(mean(filtered_mean_spectrogram));
    power_transition = mean(mean_spectrogram(find(F==power_band(1)):find(F==power_band(2)), :), 1);
    normalized_power_transition = power_transition/-normalization_factor+2;
    collect_sws_wake(:,i) = normalized_power_transition;
    normalized_power_trace = mean(collect_sws_wake,2); % Average over all NREM -> wake transitions
    normalized_power_trace= normalized_power_trace'; 
end

   mean_power_trace_sws_wake{power_number} = normalized_power_trace; % For export to Prism! Gives a vector of all the frequency bands changes over time at transition


collect_REM_wake = [];
%transitions = [transition_sws_wake; transition_REM_wake; transition_sws_MA; transition_REM_sws; transition_sws_REM; transition_REM_MA];
for i = 1:length(transition_REM_wake)
    trans = transition_REM_wake(i);
    if trans < before|| trans > EEG_time(end)-100
        continue
    end
    EEG_transition = EEG_rawtrace_cut((trans-before)*sampling_freq: (trans+after)*sampling_freq);
    [transition_spectrogram, F, T] = spectrogram(EEG_transition,round(frq*analysis_window),[],frw,frq,'yaxis');
    mean_spectrogram = log(abs(transition_spectrogram));
    time_spectrogram_zero = T; 
    filtered_mean_spectrogram = imgaussfilt(mean_spectrogram, 4);
    specto_fs = length(T)/T(end);
    norm_time = abs(T-(100/3*2)); 
    % norm_sampling = find(norm_time == min(norm_time));
    % normalization_factor = mean(mean(mean_spectrogram(find(F==total_power_band(1)):find(F==total_power_band(2)), 1:norm_sampling)));
    normalization_factor=mean(mean(filtered_mean_spectrogram));
    power_transition = mean(filtered_mean_spectrogram(find(F==power_band(1)):find(F==power_band(2)), :), 1);
    normalized_power_transition = power_transition/-normalization_factor+2;
    collect_REM_wake(:,i) = normalized_power_transition';
    normalized_power_trace = mean(collect_REM_wake,2);
    normalized_power_trace= normalized_power_trace';
end

 mean_power_trace_REM_wake{power_number} = normalized_power_trace; % For export to Prism! Gives a vector of all the frequency bands changes over time at transition

collect_sws_MA = [];
for i = 1:length(transition_sws_MA)
    trans = transition_sws_MA(i);
    if trans < before+1|| trans > EEG_time(end)-100
        continue
    end
    EEG_transition = EEG_rawtrace_cut((trans-before)*sampling_freq: (trans+after)*sampling_freq);
    [transition_spectrogram, F, T] = spectrogram(EEG_transition,round(frq*analysis_window),[],frw,frq,'yaxis');
    mean_spectrogram = log(abs(transition_spectrogram));
    time_spectrogram_zero = T; 
    filtered_mean_spectrogram = imgaussfilt(mean_spectrogram, 4);
    specto_fs = length(T)/T(end);
    norm_time = abs(T-(100/3*2)); 
    % norm_sampling = find(norm_time == min(norm_time));
    % normalization_factor = mean(mean(mean_spectrogram(find(F==total_power_band(1)):find(F==total_power_band(2)), 1:norm_sampling)));
    normalization_factor=mean(mean(filtered_mean_spectrogram));
    power_transition = mean(filtered_mean_spectrogram(find(F==power_band(1)):find(F==power_band(2)), :), 1);
    normalized_power_transition = power_transition/-normalization_factor+2;
    collect_sws_MA(:,i) = normalized_power_transition';
    normalized_power_trace = mean(collect_sws_MA,2);
    normalized_power_trace= normalized_power_trace';
end

mean_power_trace_sws_MA{power_number} = normalized_power_trace; % For export to Prism! Gives a vector of all the frequency bands changes over time at transition

  
collect_sws_REM = [];
for i = 1:length(transition_sws_REM)
    trans = transition_sws_REM(i);
    if trans < before|| trans > EEG_time(end)-100
        continue
    end
    EEG_transition = EEG_rawtrace_cut((trans-before)*sampling_freq: (trans+after)*sampling_freq);
    [transition_spectrogram, F, T] = spectrogram(EEG_transition,round(frq*analysis_window),[],frw,frq,'yaxis');
    mean_spectrogram = log(abs(transition_spectrogram));
    time_spectrogram_zero = T; 
    filtered_mean_spectrogram = imgaussfilt(mean_spectrogram, 4);
    specto_fs = length(T)/T(end);
    norm_time = abs(T-(100/3*2)); 
    % norm_sampling = find(norm_time == min(norm_time));
    % normalization_factor = mean(mean(mean_spectrogram(find(F==total_power_band(1)):find(F==total_power_band(2)), 1:norm_sampling)));
    normalization_factor=mean(mean(filtered_mean_spectrogram));
    power_transition = mean(filtered_mean_spectrogram(find(F==power_band(1)):find(F==power_band(2)), :), 1);
    normalized_power_transition = power_transition/-normalization_factor+2;
    collect_sws_REM(:,i) = normalized_power_transition';
    normalized_power_trace = mean(collect_sws_REM,2);
    normalized_power_trace= normalized_power_trace';
end

mean_power_trace_sws_REM{power_number} = normalized_power_trace; % For export to Prism! Gives a vector of all the frequency bands changes over time at transition

collect_REM_MA = [];
for i = 1:length(transition_REM_MA)
    trans = transition_REM_MA(i);
    if trans < before|| trans > EEG_time(end)-100
        continue
    end
    EEG_transition = EEG_rawtrace_cut((trans-before)*sampling_freq: (trans+after)*sampling_freq);
    [transition_spectrogram, F, T] = spectrogram(EEG_transition,round(frq*analysis_window),[],frw,frq,'yaxis');
    mean_spectrogram = log(abs(transition_spectrogram));
    time_spectrogram_zero = T; 
    filtered_mean_spectrogram = imgaussfilt(mean_spectrogram, 4);
    specto_fs = length(T)/T(end);
    norm_time = abs(T-(100/3*2)); 
    % norm_sampling = find(norm_time == min(norm_time));
    % normalization_factor = mean(mean(mean_spectrogram(find(F==total_power_band(1)):find(F==total_power_band(2)), 1:norm_sampling)));
    normalization_factor=mean(mean(filtered_mean_spectrogram));
    power_transition = mean(filtered_mean_spectrogram(find(F==power_band(1)):find(F==power_band(2)), :), 1);
    normalized_power_transition = power_transition/-normalization_factor+2;
    collect_REM_MA(:,i) = normalized_power_transition';
    normalized_power_trace = mean(collect_REM_MA,2);
    normalized_power_trace= normalized_power_trace';
end

mean_power_trace_REM_MA{power_number} = normalized_power_trace; % For export to Prism! Gives a vector of all the frequency bands changes over time at transition

end 
