% Spindle detection
% based on Uygun et al., Sleep Research Society 2019

function [spindle_center_filtered, spindle_onset_filtered, spindle_offset_filtered, eeg_data_spindlefilt] = spindle_detect(eeg_data, eeg_time, eeg_fs, sws_periods, varargin)

%SPINDLE_DETECT
% Input arguments:
%   eeg_data: vector containing EEG trace
%   eeg_time: time vector matching eeg_data (used for plotting)
%   eeg_fs: sampling frequency (Hz) for eeg_data 
%   sws_periods: n-by-2 matrix containing on-/offsets (s) of periods to include in detection
% Optional inputs:
%   'first_passband': spindle frequency range lower boundary (Hz), default 10 Hz
%   'second_passband': spindle frequency range upper boundary (Hz), default 15 Hz
%   'segment_length': segmentation window length (min)
%   'segment_overlap': fraction overlap between segmentation windows, e.g., 0.5 for 50%
%   'detection_thres': This factor determines event detection
%   'coherence_thres': This factor determines events duration (i.e. coupling of adjecent events).
%   'threshold_method': 'per_segment' (default) computes threshold from NREM data within
%                       each sliding window (original method). 'global_nrem' concatenates
%                       all NREM periods first, then uses sliding windows over that
%                       NREM-only signal to compute thresholds (script method). Note that
%                       with 'global_nrem', envelope and candidate detection still operate
%                       on the full EEG segment — only the threshold mean changes.
%   'show_figure': true/false whether to plot figure
%
% Output arguments:
%   spindle_center_filtered: center point of detected spindles during specified periods. NB! Center is given as samples, not seconds
%   spindle_onset_filtered: onset of spindles given in samples, not seconds
%   spindle_offset_filtered: offset of spindles given in samples, not seconds 
%   eeg_data_spindlefilt: full EEG trace filtered using the filter design applied for spindle detection

p = inputParser;

default_first_passband   = 10;             % spindle frequency lower bound (Hz). Uygun et al. uses 10 Hz
default_second_passband  = 15;             % spindle frequency upper bound (Hz). Uygun et al. uses 15 Hz
default_show_figure      = true;
default_segment_length   = 15;            % segmentation window length (min). Uygun et al. uses 15 minutes
default_segment_overlap  = 0.5;           % fraction overlap (e.g., 0.5 for 50%)
default_detection_thres  = 3.5;           % This factor determines event detection
default_coherence_thres  = 1.2;           % This factor determines events duration (i.e. coupling of adjecent events).
default_threshold_method = 'per_segment'; % 'per_segment' (original) or 'global_nrem' (script method)

addRequired(p, 'eeg_data',    @isnumeric);
addRequired(p, 'eeg_time',    @isnumeric);
addRequired(p, 'eeg_fs',      @isnumeric);
addRequired(p, 'sws_periods', @isnumeric);

addParameter(p, 'first_passband',   default_first_passband,   @isnumeric);
addParameter(p, 'second_passband',  default_second_passband,  @isnumeric);
addParameter(p, 'show_figure',      default_show_figure,      @islogical);
addParameter(p, 'segment_length',   default_segment_length,   @isnumeric);
addParameter(p, 'segment_overlap',  default_segment_overlap,  @isnumeric);
addParameter(p, 'detection_thres',  default_detection_thres,  @isnumeric);
addParameter(p, 'coherence_thres',  default_coherence_thres,  @isnumeric);
addParameter(p, 'threshold_method', default_threshold_method, @ischar);

parse(p, eeg_data, eeg_time, eeg_fs, sws_periods, varargin{:});

first_passband   = p.Results.first_passband;
second_passband  = p.Results.second_passband;
show_figure      = p.Results.show_figure;
segment_length   = p.Results.segment_length;
segment_overlap  = p.Results.segment_overlap;
detection_thres  = p.Results.detection_thres;
coherence_thres  = p.Results.coherence_thres;
threshold_method = p.Results.threshold_method;

% Filter design according to Uygun et al., Sleep Research Society 2019
first_stopband  = 3;  % Hz
second_stopband = 22; % Hz

d_filt = designfilt('bandpassiir', ...
               'StopbandFrequency1', first_stopband  / (eeg_fs / 2), ...
               'PassbandFrequency1', first_passband  / (eeg_fs / 2), ...
               'PassbandFrequency2', second_passband / (eeg_fs / 2), ...
               'StopbandFrequency2', second_stopband / (eeg_fs / 2), ...
               'StopbandAttenuation1', 24, ...
               'StopbandAttenuation2', 24, ...
               'DesignMethod', 'butter');

% Segmentation window
segmnt_length_s = segment_length * 60 * eeg_fs;       % convert segment length to samples
step_size       = segmnt_length_s * (1 - segment_overlap); % segmentation step size (samples)

sws_onset  = sws_periods(:,1);
sws_offset = sws_periods(:,2);

if ~isa(eeg_data, 'double')
    eeg_data = double(eeg_data);
end

% 750ms envelope window
window_size = round(0.75 * eeg_fs);

% Spindle duration limits
spindle_maxdur = 10;  % seconds
spindle_mindur = 0.5; % seconds

% -------------------------------------------------------------------------
% Pre-compute global NREM cubed RMS if using 'global_nrem' method.
% This replicates the script approach: filter the full EEG, compute the
% envelope, cube it, then extract and concatenate NREM-only samples.
% The resulting cubed_rms_NREM and a mapping back to original EEG indices
% (NREM_to_EEG_idx) are used inside the loop to compute the threshold mean
% from sliding windows over the NREM-only signal.
% -------------------------------------------------------------------------
if strcmp(threshold_method, 'global_nrem')
    filtered_EEG_full = filtfilt(d_filt, eeg_data);
    [env_full, ~]     = envelope(filtered_EEG_full, window_size, 'rms');
    cubed_rms_full    = env_full .^ 3;

    n_samps          = length(cubed_rms_full);
    sws_periods_samp = round(sws_periods * eeg_fs);  % convert sws_periods to samples
    sws_periods_samp(:,1) = max(sws_periods_samp(:,1), 0);          % clamp onsets  >= 0
    sws_periods_samp(:,2) = min(sws_periods_samp(:,2), n_samps);    % clamp offsets <= signal length

    NREM_chunks      = arrayfun(@(i) cubed_rms_full((sws_periods_samp(i,1)+1):sws_periods_samp(i,2)), ...
                                1:size(sws_periods_samp,1), 'UniformOutput', false);
    NREM_idx_chunks  = arrayfun(@(i) (sws_periods_samp(i,1)+1):sws_periods_samp(i,2), ...
                                1:size(sws_periods_samp,1), 'UniformOutput', false);

    cubed_rms_NREM   = cell2mat(cellfun(@(x) x(:)', NREM_chunks,     'UniformOutput', false));  % NREM-only cubed RMS (concatenated)
    NREM_to_EEG_idx  = cell2mat(cellfun(@(x) x(:)', NREM_idx_chunks, 'UniformOutput', false));  % mapping: NREM position -> EEG sample index

    % Build continuity mask so spindles cannot straddle NREM bout boundaries
    epoch_lengths        = cellfun(@length, NREM_chunks);
    epoch_end_idx        = cumsum(epoch_lengths);
    is_NREM_continuous   = true(1, sum(epoch_lengths));
    is_NREM_continuous(epoch_end_idx(1:end-1)) = false;

    % Sliding window parameters over the NREM-only signal (mirrors the script)
    nrem_seg_length = round(segment_length * 60 * eeg_fs);
    nrem_step_size  = round(nrem_seg_length * (1 - segment_overlap));
    nrem_seg_starts = 1:nrem_step_size:(length(cubed_rms_NREM) - nrem_seg_length + 1);
    if nrem_seg_starts(end) < (length(cubed_rms_NREM) - nrem_seg_length + 1)
        nrem_seg_starts(end+1) = length(cubed_rms_NREM) - nrem_seg_length + 1;
    end

    % Pre-compute per-window thresholds over the NREM-only signal.
    % Each NREM sample is assigned the mean from the window it falls in;
    % where windows overlap, the last window's mean is used (matches script
    % behaviour where threshold is recomputed fresh each iteration).
    nrem_mean_map = zeros(size(cubed_rms_NREM));
    for s = 1:length(nrem_seg_starts)
        seg_s = nrem_seg_starts(s);
        seg_e = min(seg_s + nrem_seg_length - 1, length(cubed_rms_NREM));
        seg_mean = mean(cubed_rms_NREM(seg_s:seg_e));
        nrem_mean_map(seg_s:seg_e) = seg_mean;
    end
end
% -------------------------------------------------------------------------

all_spindle_events = [];

for segment_idx = 1:floor((length(eeg_data) - segmnt_length_s) / step_size) + 1
    start_idx = (segment_idx - 1) * step_size + 1;
    end_idx   = start_idx + segmnt_length_s - 1;

    if end_idx > length(eeg_data)
        end_idx = length(eeg_data);
    end

    eeg_segment  = eeg_data(round(start_idx):round(end_idx));
    filtered_EEG = filtfilt(d_filt, eeg_segment);

    [env, ~]  = envelope(filtered_EEG, window_size, 'rms');
    cubed_rms = env .^ 3;

    % -----------------------------------------------------------------
    % Threshold computation — branches on threshold_method
    % -----------------------------------------------------------------
    if strcmp(threshold_method, 'global_nrem')
        % Find which NREM-only samples fall within this EEG segment and
        % retrieve their pre-computed window means. Use the median of those
        % means as the segment threshold (robust when window coverage is uneven).
        seg_eeg_indices  = round(start_idx):round(end_idx);
        nrem_in_seg_mask = ismember(NREM_to_EEG_idx, seg_eeg_indices);

        if ~any(nrem_in_seg_mask)
            continue;  % no NREM in this segment, skip
        end

        mean_cubed_rms = median(nrem_mean_map(nrem_in_seg_mask));

    else
        % Original per_segment method: use only NREM bouts entirely within
        % this segment's boundaries to compute the mean.
        sigma_NREM = [];
        for i = 1:length(sws_onset) - 1
            onset_idx  = round(sws_onset(i)  * eeg_fs - start_idx + 1);
            offset_idx = round(sws_offset(i) * eeg_fs - start_idx + 1);

            if onset_idx > 0 && offset_idx <= segmnt_length_s
                sigma_NREM = [sigma_NREM; cubed_rms(onset_idx:offset_idx)'];
            end
        end

        if isempty(sigma_NREM)
            continue;
        end

        mean_cubed_rms = mean(sigma_NREM);
    end
    % -----------------------------------------------------------------

    lower_threshold = coherence_thres * mean_cubed_rms;
    upper_threshold = detection_thres * mean_cubed_rms;

    spindle_candidates = find(cubed_rms > upper_threshold);
    above_lower        = cubed_rms > lower_threshold;

    if any(above_lower)
        [spindle_candidate_onset, spindle_candidate_offset] = binary_to_OnOff(above_lower);
    else
        continue;
    end

    spindle_events = [];
    for i = 1:length(spindle_candidate_onset)
        for j = 1:length(spindle_candidates)
            candidate_idx = spindle_candidates(j);
            if candidate_idx >= spindle_candidate_onset(i) && candidate_idx <= spindle_candidate_offset(i)
                spindle_events = [spindle_events; spindle_candidate_onset(i), spindle_candidate_offset(i)];
                break;
            end
        end
    end
    
    if isempty(spindle_events)
        fprintf('Segment %d: no spindle events detected above threshold (detection_thres = %.1f). Skipping.\n', segment_idx, detection_thres);
        continue;
    end
    
    % Exclude spindles outside duration limits
    durations  = spindle_events(:,2) - spindle_events(:,1);
    valid_idx  = durations > spindle_mindur * eeg_fs & durations < spindle_maxdur * eeg_fs;
    spindle_filter = spindle_events(valid_idx, :);

    % For 'global_nrem': additionally exclude any candidate that straddles
    % an NREM bout boundary (replicates the is_NREM_continuous check in the script).
    if strcmp(threshold_method, 'global_nrem') && ~isempty(spindle_filter)
        spindle_filter_adj = spindle_filter + (start_idx - 1);  % back to EEG indices
        keep = true(size(spindle_filter_adj, 1), 1);
        for i = 1:size(spindle_filter_adj, 1)
            ev_start = spindle_filter_adj(i,1);
            ev_end   = spindle_filter_adj(i,2);
            % find positions of these EEG indices in NREM_to_EEG_idx
            nrem_pos_start = find(NREM_to_EEG_idx == ev_start, 1);
            nrem_pos_end   = find(NREM_to_EEG_idx == ev_end,   1);
            if ~isempty(nrem_pos_start) && ~isempty(nrem_pos_end)
                if any(~is_NREM_continuous(nrem_pos_start:nrem_pos_end-1))
                    keep(i) = false;
                end
            end
        end
        spindle_filter = spindle_filter(keep, :);
    end

    % Adjust indices back to full EEG
    spindle_filter = spindle_filter + (start_idx - 1);

    all_spindle_events = [all_spindle_events; spindle_filter];
end

all_spindle_events = sortrows(all_spindle_events);

% Only keep spindles detected in overlapping segments (original logic)
overlapping_spindle_events = [];

for i = 1:size(all_spindle_events, 1) - 1
    current_onset  = all_spindle_events(i,   1);
    current_offset = all_spindle_events(i,   2);
    next_onset     = all_spindle_events(i+1, 1);
    next_offset    = all_spindle_events(i+1, 2);

    overlap_onset  = max(current_onset,  next_onset);
    overlap_offset = min(current_offset, next_offset);

    if overlap_onset < overlap_offset
        overlapping_spindle_events = [overlapping_spindle_events; overlap_onset, overlap_offset];
    end
end

% Add spindles from first and last non-overlapping half-windows
first_segment_offset  = segment_length * (1 - segment_overlap) * 60 * eeg_fs;
first_segment_spindles = all_spindle_events(all_spindle_events(:,1) < first_segment_offset, :);

last_segment_onset    = length(eeg_data) - segment_length * (1 - segment_overlap) * 60 * eeg_fs + 1;
last_segment_spindles  = all_spindle_events(all_spindle_events(:,2) > last_segment_onset, :);

final_spindle_events = sortrows([overlapping_spindle_events; first_segment_spindles; last_segment_spindles]);
spindle_onset  = final_spindle_events(:,1);
spindle_offset = final_spindle_events(:,2);
spindle_center = (spindle_onset + spindle_offset) / 2;

% Filter to NREM periods
spindle_center_filtered  = [];
spindle_onset_filtered   = [];
spindle_offset_filtered  = [];

for i = 1:length(sws_onset)
    indices = find(spindle_center >= (sws_onset(i) * eeg_fs) & spindle_center <= (sws_offset(i) * eeg_fs));
    spindle_center_filtered  = [spindle_center_filtered;  round(spindle_center(indices))];
    spindle_onset_filtered   = [spindle_onset_filtered;   round(spindle_onset(indices))];
    spindle_offset_filtered  = [spindle_offset_filtered;  round(spindle_offset(indices))];
end

valid = spindle_onset_filtered > 0;
spindle_onset_filtered   = spindle_onset_filtered(valid);
spindle_offset_filtered  = spindle_offset_filtered(valid);
spindle_center_filtered  = spindle_center_filtered(valid);

eeg_data_spindlefilt = filtfilt(d_filt, eeg_data);

if show_figure
    figure
    a = subplot(2,1,1);
        plot(eeg_time, eeg_data)
        title('raw EEG');
        hold on
        for i = 1:length(spindle_onset_filtered)
            plot(eeg_time(spindle_onset_filtered(i):spindle_offset_filtered(i)), ...
                 eeg_data(spindle_onset_filtered(i):spindle_offset_filtered(i)), 'r-')
        end
    b = subplot(2,1,2);
        plot(eeg_time, eeg_data_spindlefilt);
        hold on
        for i = 1:length(spindle_onset_filtered)
            plot(eeg_time(spindle_onset_filtered(i):spindle_offset_filtered(i)), ...
                 eeg_data_spindlefilt(spindle_onset_filtered(i):spindle_offset_filtered(i)), 'r-')
        end
        title(sprintf('filtered EEG  [threshold\\_method: %s]', threshold_method));
        xlabel('time (s)')
    linkaxes([a,b],'x');
end

end %function
%{
% Old version (based on Yi ~2025 script)
% based on Uygun et al., Sleep Research Society 2019

function [spindle_center_filtered, spindle_onset_filtered, spindle_offset_filtered, eeg_data_spindlefilt] = spindle_detect(eeg_data, eeg_time, eeg_fs, sws_periods, varargin)

%SPINDLE_DETECT
% Input arguments:
%   eeg_data: vector containing EEG trace
%   eeg_time: time vector matching eeg_data (used for plotting)
%   eeg_fs: sampling frequency (Hz) for eeg_data 
%   sws_periods: n-by-2 matrix containing on-/offsets (s) of periods to include in detection
% OptionaLinputs:
%   'first_passband': spindle frequency range lower boundary (Hz), default 10 Hz
%   'second_passband': spindle frequency range upper boundary (Hz), default 15 Hz
%   'segment_length': segmentation window length (min)
%   'segment_overlap': fraction overlap between segmentation windows, e.g., 0.5 for 50%
%   'detection_thres': This factor determines event detection
%   'coherence_thres': This factor determines events duration (i.e. coupling of adjecent events).
%   'show_figure': true/false whether to plot figure
%
% Output arguments:
%   spindle_center_filtered: center point of detected spindles during specified periods. NB! Center is given as samples, not seconds
%   spindle_onset_filtered: onset of spindles given in samples, not seconds
%   spindle_offset_filtered: offset of spindles given in samples, not seconds 
%   eeg_data_spindlefilt: full EEG trace filtered using the filter design applied for spindle detection

p = inputParser;

default_first_passband = 10;     % spindle frequency lower bound (Hz). Uygun et al. uses 10 Hz
default_second_passband = 15;   % spindle frequency upper bound (Hz). Uygun et al. uses 15 Hz
default_show_figure = true;
default_segment_length = 15;    % segmentation window length (min). Uygun et al. uses 15 minutes
default_segment_overlap = 0.5;  % fraction overlap (e.g., 0.5 for 50%)
default_detection_thres = 3.5;  % This factor determines event detection
default_coherence_thres = 1.2;  % This factor determines events duration (i.e. coupling of adjecent events).

addRequired(p,'eeg_data',@isnumeric);
addRequired(p,'eeg_time',@isnumeric);
addRequired(p,'eeg_fs',@isnumeric);
addRequired(p,'sws_periods',@isnumeric)

addParameter(p, 'first_passband', default_first_passband, @isnumeric);
addParameter(p, 'second_passband', default_second_passband, @isnumeric);
addParameter(p, 'show_figure', default_show_figure, @islogical);
addParameter(p, 'segment_length', default_segment_length, @isnumeric);
addParameter(p, 'segment_overlap', default_segment_overlap, @isnumeric);
addParameter(p, 'detection_thres', default_detection_thres, @isnumeric);
addParameter(p, 'coherence_thres', default_coherence_thres, @isnumeric);

parse(p, eeg_data, eeg_time, eeg_fs, sws_periods, varargin{:});

first_passband = p.Results.first_passband;
second_passband = p.Results.second_passband;
show_figure = p.Results.show_figure;
segment_length = p.Results.segment_length;
segment_overlap = p.Results.segment_overlap;
detection_thres = p.Results.detection_thres;
coherence_thres = p.Results.coherence_thres;

% Filter design according to Uygun et al., Sleep Research Society 2019
% filtering band 
first_stopband = 3; % Hz
second_stopband = 22; % Hz

d_filt = designfilt('bandpassiir', ...
               'StopbandFrequency1', first_stopband / (eeg_fs / 2), ...
               'PassbandFrequency1', first_passband / (eeg_fs / 2), ...
               'PassbandFrequency2', second_passband / (eeg_fs / 2), ...
               'StopbandFrequency2', second_stopband / (eeg_fs / 2), ...
               'StopbandAttenuation1', 24, ...
               'StopbandAttenuation2', 24, ...
               'DesignMethod', 'butter');

% segmentation window
segmnt_length_s = segment_length * 60 * eeg_fs; % convert segment length to samples
step_size = segmnt_length_s * (1 - segment_overlap); % segmentation step size (sec)

sws_onset = sws_periods(:,1);
sws_offset = sws_periods(:,2);

if ~isa(eeg_data, 'double')
    eeg_data = double(eeg_data);
end

% 750ms envelope
window_s = 0.75; 
window_size = round(window_s * eeg_fs); 

% Spindle duration 0.5~10s
spindle_maxdur = 10; % in seconds
spindle_mindur = 0.5; % in seconds

all_spindle_events = [];
for segment_idx = 1:floor((length(eeg_data) - segmnt_length_s) / step_size) + 1
    start_idx = (segment_idx - 1) * step_size + 1;
    end_idx = start_idx + segmnt_length_s - 1;
    
    if end_idx > length(eeg_data)
       end_idx = length(eeg_data);
    end
    
    eeg_segment = eeg_data(round(start_idx):round(end_idx));
    
    % Filter the EEG data
    filtered_EEG = filtfilt(d_filt, eeg_segment);

    % 750ms envelope
    [env, ~] = envelope(filtered_EEG, window_size, 'rms');
    cubed_rms = env .^ 3; % cubing to enhance SNR
    
    % cubed_rms in NREM
    sigma_NREM = [];
    for i = 1:length(sws_onset) - 1
        onset_idx = round(sws_onset(i) * eeg_fs - start_idx + 1);
        offset_idx = round(sws_offset(i) * eeg_fs - start_idx + 1);

        % Ensure indices are within the valid range
        if onset_idx > 0 && offset_idx <= segmnt_length_s                    % excluded bouts that overlap with boundaries
            sigma_NREM = [sigma_NREM; cubed_rms(onset_idx:offset_idx)'];
        end
    end

    % Skip this segment if sigma_NREM is empty (i.e. no sws bouts within segment)
    if isempty(sigma_NREM)
        continue; 
    end
    
    mean_cubed_rms = mean(sigma_NREM);
    
    % Calculate thresholds for the segment: upper-threshold for events
    % detection, lower-thershold for the events duration. 
    lower_threshold = coherence_thres * mean_cubed_rms;
    upper_threshold = detection_thres * mean_cubed_rms;                     % <<<<<<< Change the detection_thres if too strict.
    
    % Detect spindle candidates
    spindle_candidates = find(cubed_rms > upper_threshold);
    above_lower = cubed_rms > lower_threshold;
    
    if any(above_lower)  
        [spindle_candidate_onset, spindle_candidate_offset] = binary_to_OnOff(above_lower);
    else
        continue;  
    end
    
    spindle_events = [];
    for i = 1:length(spindle_candidate_onset)
        for j = 1:length(spindle_candidates)
            candidate_idx = spindle_candidates(j);
            if candidate_idx >= spindle_candidate_onset(i) && candidate_idx <= spindle_candidate_offset(i)      % spindle detection depends on oscillation ampl
                spindle_events = [spindle_events; spindle_candidate_onset(i), spindle_candidate_offset(i)];     % so on- /offsets of spindles are based on when cubed rms goes above/below thresh
                break;
            end
        end
    end
    
    % exclude spindles that are too short or too long
    durations = spindle_events(:, 2) - spindle_events(:, 1); % Calculate durations of each spindle event
    valid_idx = durations > spindle_mindur * eeg_fs & durations < spindle_maxdur * eeg_fs; % Create logical mask for events within desired duration
    spindle_filter = spindle_events(valid_idx, :); % Apply the mask to filter the events

    % Adjust spindle event indices to the original EEG data
    spindle_filter = spindle_filter + (start_idx - 1);                          % spindle filter contains columns of on-/offsets (idx) of detected spindles?
    
    all_spindle_events = [all_spindle_events; spindle_filter];
end

all_spindle_events = sortrows(all_spindle_events);

% only the overlapped spindle will be stored (i.e. spindles need to be detected by neightbouring/overlapping segments)
overlapping_spindle_events = [];
final_spindle_events = [];

for i = 1:size(all_spindle_events, 1) - 1
    current_onset = all_spindle_events(i, 1);
    current_offset = all_spindle_events(i, 2);
    next_onset = all_spindle_events(i + 1, 1);
    next_offset = all_spindle_events(i + 1, 2);
    
    overlap_onset = max(current_onset, next_onset);
    overlap_offset = min(current_offset, next_offset);
    
    if overlap_onset < overlap_offset
        overlapping_spindle_events = [overlapping_spindle_events; overlap_onset, overlap_offset];
    end
end

% Add spindles from the first and last 7.5 minutes (since these have zero overlap we assume correct detection)                          
first_segment_onset = 1; 
first_segment_offset = segment_length*(1-segment_overlap) * 60 * eeg_fs;
first_segment_spindles = all_spindle_events(all_spindle_events(:, 1) < first_segment_offset, :);

last_segment_onset = length(eeg_data) - segment_length*(1-segment_overlap) * 60 * eeg_fs + 1;
last_segment_offset = length(eeg_data);
last_segment_spindles = all_spindle_events(all_spindle_events(:, 2) > last_segment_onset, :);

% Combine all spindle events
final_spindle_events = [overlapping_spindle_events; first_segment_spindles; last_segment_spindles];
final_spindle_events = sortrows(final_spindle_events);
spindle_onset = final_spindle_events(:, 1);
spindle_offset = final_spindle_events(:, 2);

% Calculate sigma center for plot and filter
spindle_center = (spindle_onset + spindle_offset) / 2;

% Filter sigma center based on NREM onset/offset
spindle_center_filtered = [];
spindle_onset_filtered = [];
spindle_offset_filtered = [];
for i = 1:length(sws_onset)
    indices = find(spindle_center >= (sws_onset(i) * eeg_fs) & spindle_center <= (sws_offset(i) * eeg_fs));
    spindle_center_filtered = [spindle_center_filtered; round(spindle_center(indices))];
    spindle_onset_filtered = [spindle_onset_filtered; round(spindle_onset(indices))];          % NB! all timepoints are given in samples rather than seconds
    spindle_offset_filtered = [spindle_offset_filtered; round(spindle_offset(indices))];
end

valid = spindle_onset_filtered > 0; % to prevent rounding to zero
spindle_onset_filtered = spindle_onset_filtered(valid);
spindle_offset_filtered = spindle_offset_filtered(valid);
spindle_center_filtered = spindle_center_filtered(valid);

eeg_data_spindlefilt = filtfilt(d_filt, eeg_data); % full egg trace filtered in spindle range

if show_figure
    % inspection of detection
    figure
    a = subplot(2,1,1);
        plot(eeg_time, eeg_data)
        title('raw EEG');
        hold on
        for i = 1:length(spindle_onset_filtered)
            plot(eeg_time(spindle_onset_filtered(i):spindle_offset_filtered(i)), eeg_data(spindle_onset_filtered(i):spindle_offset_filtered(i)), 'r-')
        end
    b = subplot(2,1,2);
        plot(eeg_time, eeg_data_spindlefilt);
        hold on
        for i = 1:length(spindle_onset_filtered)
            plot(eeg_time(spindle_onset_filtered(i):spindle_offset_filtered(i)), eeg_data_spindlefilt(spindle_onset_filtered(i):spindle_offset_filtered(i)), 'r-')
        end
        title('filtered EEG');
        xlabel('time (s)')
    linkaxes([a,b],'x');
end

end %function
%}