%% DESCRIPTION
% This template is for batch processing all your recordings within an
% experiment. For each mouse you will save a .mat file containing the
% workspace with variables that you need for subsequent analysis.
% You need to adjust which output parameters you want to keep down by the
% 'clearvars' function

%% Specify mouse data
% Here you specify all the input arguments for each mouse (e.g. file locations, channel names, interval for fitting, etc.)
% Make sure to adjust the file location and name of the preprocessed data - here mouse{6}
% - and adjust the index numbers according to the number of input arguments.
% It's also a good idea to update the data structure description for
% yourself to remember what the input arguments are.

clear all

% data structure:
    % 1) FP raw data
    % 2) EEG raw data
    % 3) input X
    % 4) input Y
    % 5) input Z
    % 6) path/file name to save preprocessed data. NB! change this for each recording (see example format below)
    
% mouse batch
    m1 = {'' '' '' '' '' "J:\CTN\NedergaardLAB\KjaerbyLab\MATLAB\preprocessed data\m1.mat"};
    m2 = {'' '' '' '' '' "J:\CTN\NedergaardLAB\KjaerbyLab\MATLAB\preprocessed data\m2.mat"};
    m3 = {'' '' '' '' '' "J:\CTN\NedergaardLAB\KjaerbyLab\MATLAB\preprocessed data\m3.mat"};
    m4 = {'' '' '' '' '' "J:\CTN\NedergaardLAB\KjaerbyLab\MATLAB\preprocessed data\m4.mat"};
    m5 = {'' '' '' '' '' "J:\CTN\NedergaardLAB\KjaerbyLab\MATLAB\preprocessed data\m5.mat"};
    

%% start loop to preprocess data

mice = {m1 m2 m3 m4 m5};
for recording = 1:length(mice)
mouse = mice{recording};

%% Preprocessing
% Here you put all the preprocessing steps/sections you need


%% end of loop (preprocess data)
% Here you clear all variables except the ones specified after -except.
% These are the ones you want to save with your workspace. They should 
% include the variables you need for subsequent analysis.

% keep only data.info to make files smaller and faster to load
data_clean = {'epocs' 'snips' 'streams' 'scalars' 'time_ranges'};
data = rmfield(data,data_clean);

clearvars -except data signal_fs sec_signal delta465_filt ds_sec_signal ds_delta465_filt ViewpointData sampling_freq EMG_rawtrace_cut... % <<< NB! Make sure to adjust these to your own needs
    EEG_rawtrace_cut EEG_time_cut wake_binary_vector_cut sws_binary_vector_cut REM_binary_vector_cut MA_binary_vector_cut ...
    wake_woMA_binary_vector_cut NREMinclMA_binary_vector_cut sleepscore_time_cut wake_periods_cut sws_periods_cut REM_periods_cut ...
    MA_periods_cut wake_woMA_periods_cut NREMinclMA_periods_cut mice mouse recording

path_file_name = mouse{6}; % Adjust index number if you make changes to the cell data structure
save(path_file_name);

end

%% load preprocessed data
% After you have run the loop above, each mouse should have their
% preprocessed data saved wihtin a .mat file. You can load one .mat at a
% time with the script below and do your subsequent analysis.

clearvars -except mice

mouse = mice{4}; %          <<<< here you specify which recording to load
path_file_name = mouse{6};
load(path_file_name);
