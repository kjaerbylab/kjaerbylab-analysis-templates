%% Sleep quantification
% Here you can do very basic quantification of the scored stages

wake_dur_analysis = diff(wake_woMA_periods_cut')';
sws_dur_analysis = diff(sws_periods_cut')';
REM_dur_analysis = diff(REM_periods_cut')';
MA_dur_analysis = diff(MA_periods_cut')';

% mean bout duration
mean_bout_dur_wake = mean(wake_dur_analysis);
mean_bout_dur_NREM = mean(sws_dur_analysis);
mean_bout_dur_REM = mean(REM_dur_analysis);
mean_bout_dur_MA = mean(MA_dur_analysis);

% total time spent (in seconds)
total_dur_wake = sum(wake_dur_analysis);
total_dur_NREM = sum(sws_dur_analysis);
total_dur_REM = sum(REM_dur_analysis);
total_dur_MA = sum(MA_dur_analysis);

% duration of total scoring - NOTE! In case of unscored sections, these
% won't count towards total duration. In that case consider using a
% different definition of total duration
total_dur_s = total_dur_wake + total_dur_NREM + total_dur_REM + total_dur_MA;
total_dur_h = total_dur_s/60/60;

% percent time spent out of total recording/scored time
percent_wake = total_dur_wake/total_dur_s*100;
percent_NREM = total_dur_NREM/total_dur_s*100;
percent_REM = total_dur_REM/total_dur_s*100;
percent_MA = total_dur_MA/total_dur_s*100;

% number of bouts per hour
freq_wake_h = length(wake_dur_analysis)/total_dur_h;
freq_NREM_h = length(sws_dur_analysis)/total_dur_h;
freq_REM_h = length(REM_dur_analysis)/total_dur_h;
freq_MA_h = length(MA_dur_analysis)/total_dur_h; % per h recording
freq_MA_h_NREM = length(MA_dur_analysis)/(total_dur_NREM/60/60); % per h NREM sleep
