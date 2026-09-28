%% DESCRIPTION
% This script can be used for loading EEG/EMG data and sleepscoring that
% are recorded and scored using Sleepscore by Viewpoint. The data is
% subsequently cut in order to align with fiber photometry data.

%% Specify mouse data

clear all

% data structure:
    % 1) FP raw data
    % 2) EEG raw data <<<< here you put path+file name for the .exp file (see example format below)
    % 3) input X
    % 4) input Y
    % 5) input Z
    
% mouse data
    m1 = {'' 'J:\CTN\NedergaardLAB\KjaerbyLab\Experimental projects\Exp1\m1.exp' '' '' ''};
    
mouse = m1;

%% loading and plotting EEG and EMG raw data
% Here you load the EEG and MEG raw data from the specified .exp file
% Make sure the "ExpToolbox" is added to the matlab path

% Add functions to path
addpath(genpath(['Q:\Personal_folders\Mie\EEG data from NH\EEG toolbox']));

% Import EEG raw data to matlab
ViewpointData.FileInfo=loadEXP([mouse{2}],'no'); %          <<<<<< mouse{2} should contain the file path to your .exp file. Make sure to update the index according to your mouse structure.

TimeReldebSec=0; %start extract data from the beginning (first bin)
%TimeRelEndSec=inf; %inf to include data until last bin
TimeRelEndSec=ViewpointData.FileInfo.BinFiles.Duration; %to include all data (also last time bin even if incomplete)

[Data,Time]=ExtractContinuousData([],ViewpointData.FileInfo,[],TimeReldebSec, TimeRelEndSec,[],1);

EMG_rawtrace = Data(1,1:end);
EEG_rawtrace = Data(2,1:end);

%time vector using sampling frequency
sampling_freq = ViewpointData.FileInfo.Fs;
EEG_time = (0:length(EMG_rawtrace)-1)/sampling_freq;

%% load EEG scoring
% Here you load you sleepscore saved in the .H file located in the same
% folder as you .exp file. The scoring should automatically be aligend to
% the raw EE/´G/EMG traces with the time_corerection - so no need to do
% manual alignment.

% loads hypno, ViewpointData needs to be a struct - see above
[FullHypno,TimeScaleAbs,TimeScaleBin,TimeScaleHypno]=ExtractFullHypno(ViewpointData,1);

FullHypno = FullHypno(find(FullHypno~=0,1):end);
time_correction = round(TimeScaleBin(1));
int_sig = zeros(1,time_correction);

wake_binary_vector = [int_sig FullHypno==1];
sws_binary_vector = [int_sig FullHypno==2];
REM_binary_vector = [int_sig FullHypno==4];

[wake_onset, wake_offset] = binary_to_OnOff(wake_binary_vector);
[sws_onset, sws_offset] = binary_to_OnOff(sws_binary_vector);
[REM_onset, REM_offset] = binary_to_OnOff(REM_binary_vector);

wake_duration = wake_offset-wake_onset;
duration_sws = sws_offset-sws_onset;
REM_duration = REM_offset-REM_onset;

sleepscore_time = [TimeScaleHypno TimeScaleHypno(end)+1:1:TimeScaleHypno(end)+time_correction];

fig = figure;
a = subplot(2,1,1);
    plot_sleep(EEG_time, EMG_rawtrace, sleepscore_time, wake_binary_vector, sws_binary_vector, REM_binary_vector);
    xlabel('time (s)');
    ylabel('EMG (V)');
b = subplot(2,1,2);
    plot_sleep(EEG_time, EEG_rawtrace, sleepscore_time, wake_binary_vector, sws_binary_vector, REM_binary_vector);
    xlabel('time (s)');
    ylabel('EEG (V)');
linkaxes([a,b],'x');

h = datacursormode(fig);
    h.UpdateFcn = @DataCursor_custom;
    h.SnapToDataVertex = 'on';
    datacursormode on

% 2-column vectors with on- and offsets for each state
wake_periods = [wake_onset wake_onset+wake_duration];
sws_periods = [sws_onset sws_onset+duration_sws];
REM_periods = [REM_onset REM_onset+REM_duration];


%% Dividing wake bouts into microarousals (MA) and wake w/o MA
% Here scored wake bouts with duration below 15 s are redefined as
% micro-arousals (MA). From here on wake bouts excl. MAs are named
% wake_woMA

MA_maxdur = 15; % maximum duration of microarrousal
MA_idx = find(wake_duration < MA_maxdur);
MA_onset = wake_onset(MA_idx);
MA_duration = wake_duration(MA_idx);
MA_binary_vector = zeros([1, (sum([ViewpointData.FileInfo.HypnoFiles.Duration]))+time_correction]);
for i=1:length(MA_onset) % making time vector for EEG scoring (frequency = 1Hz)
    t = MA_onset(i)+1;
    d = MA_duration(i)-1;
    MA_binary_vector(t:t+d) = 1;
end

% remove micrarrousal from wake vectors
wake_woMA_onset = wake_onset;
wake_woMA_onset(MA_idx) = [];
wake_woMA_duration = wake_duration;
wake_woMA_duration(MA_idx) = [];
wake_woMA_binary_vector = zeros([1, (sum([ViewpointData.FileInfo.HypnoFiles.Duration]))+time_correction]);
for i=1:length(wake_woMA_onset) % making time vector for EEG scoring (frequency = 1Hz)
    t = wake_woMA_onset(i)+1;
    d = wake_woMA_duration(i)-1;
    wake_woMA_binary_vector(t:t+d) = 1;
end

% 2-column vectors with on- and offsets for each state
MA_periods = [MA_onset MA_onset+MA_duration];
wake_woMA_periods = [wake_woMA_onset wake_woMA_onset+wake_woMA_duration];


%%  Alingment of EEG recording and FP recording
% Here you align EEG and EMG traces + sleep scoring according the the first
% TTL pulse from the fiber photometry setup. Data prior to the first TTL
% pulse will be removed, thus all aligned vectors are named with the suffix
% '_cut'


% TTL pulse from FP
TTL_pulse = Data(3,1:end); % 3 indicates the 3rd channel in which TTL pulses are stored
onset_EEG = find(diff(TTL_pulse>1*10^-3));
onset_EEG_time = onset_EEG/sampling_freq;
onset_EEG_time_diff = diff(onset_EEG_time);

TTL_gap_EEG = onset_EEG_time_diff > 6; % as standard TTL pulses are spaced 
if isempty(find(TTL_gap_EEG==1, 1))
    onset_EEG = onset_EEG(1);
else 
    onset_EEG = onset_EEG(find(onset_EEG_time_diff>5)+1);
end

TTL_EEG_onset = onset_EEG/sampling_freq+time_correction;

%Cutting EEG/EMG traces leading up to first TTL 
% Removing first seconds of EEG and EMG raw traces to align with FP trace
EMG_rawtrace_cut = EMG_rawtrace(round(TTL_EEG_onset*sampling_freq):end);
EEG_rawtrace_cut = EEG_rawtrace(round(TTL_EEG_onset*sampling_freq):end);
EEG_time_cut = (1:length(EEG_rawtrace_cut))/sampling_freq;

% Remove first seconds of EEG score to align with FP trace
wake_binary_vector_cut = wake_binary_vector(round(TTL_EEG_onset+1):end);
sws_binary_vector_cut = sws_binary_vector(round(TTL_EEG_onset+1):end);
REM_binary_vector_cut = REM_binary_vector(round(TTL_EEG_onset+1):end);

% Align onset, offset, and duration vectors based on TTL
[wake_onset_cut, wake_offset_cut] = binary_to_OnOff(wake_binary_vector_cut);
wake_duration_cut = wake_offset_cut - wake_onset_cut;

[sws_onset_cut, sws_offset_cut] = binary_to_OnOff(sws_binary_vector_cut);
sws_duration_cut = sws_offset_cut - sws_onset_cut;

[REM_onset_cut, REM_offset_cut] = binary_to_OnOff(REM_binary_vector_cut);
REM_duration_cut = REM_offset_cut - REM_onset_cut;


% Align period arrays according to TTL
wake_periods_cut = [wake_onset_cut wake_offset_cut];
sws_periods_cut = [sws_onset_cut sws_offset_cut];
REM_periods_cut = [REM_onset_cut REM_offset_cut];

% Time vector for sleep scoring (1 Hz)
sleepscore_time_cut = 0:length(wake_binary_vector_cut)-1; % should be same length for wake/sws/REM


% Alingment of MA vectors

% Remove first seconds of EEG score to align with FP trace
MA_binary_vector_cut = MA_binary_vector(round(TTL_EEG_onset+1):end);
wake_woMA_binary_vector_cut = wake_woMA_binary_vector(round(TTL_EEG_onset+1):end);

% Align onset, offset, and duration vectors based on TTL
[MA_onset_cut, MA_offset_cut] = binary_to_OnOff(MA_binary_vector_cut);
MA_duration_cut = MA_offset_cut - MA_onset_cut;

[wake_woMA_onset_cut, wake_woMA_offset_cut] = binary_to_OnOff(wake_woMA_binary_vector_cut);
wake_woMA_duration_cut = wake_woMA_offset_cut - wake_woMA_onset_cut;

MA_periods_cut = [MA_onset_cut MA_offset_cut];
wake_woMA_periods_cut = [wake_woMA_onset_cut wake_woMA_offset_cut];


%% Re-classify MA as NREM using boutscore_vector
% Here you can pool MAs with NREM sleep which can be beneficial for some
% analyses related to infraslow oscillations (eg. PSD analysis), where you
% don't want to divide your traces into short/pure NREM bouts

%State transitions (uncut vectors)
% Creating one vector with different behaviors represented by unique
% numbers (1=wake, 4=sws, 9=REM, 15=MA) at frequency 1Hz
boutscore_vector = zeros([1, (ViewpointData.FileInfo.HypnoFiles.Duration)+time_correction]);

% Here using the unaligned "uncut" vectors
for i=1:length(wake_woMA_onset)
    t = wake_woMA_onset(i)+1;
    d = wake_woMA_duration(i)-1;
    boutscore_vector(t:t+d) = 1; % wake=1
end

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

% re-classify MA as NREM
NREMinclMA_binary_vector = boutscore_vector==4 | boutscore_vector==15;
NREMinclMA_binary_vector_cut = NREMinclMA_binary_vector(round(TTL_EEG_onset+1):end);
[NREMinclMA_onset_cut, NREMinclMA_offset_cut] = binary_to_OnOff(NREMinclMA_binary_vector_cut);
NREMinclMA_duration_cut = NREMinclMA_offset_cut-NREMinclMA_onset_cut;
NREMinclMA_periods_cut = [NREMinclMA_onset_cut NREMinclMA_offset_cut];