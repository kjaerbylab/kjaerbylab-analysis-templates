%% Íntro

%To run this code you need:
% 1) Event variables stored in a nx1 double format and they need to be in
% seconds. If you want to run the plotting code as is, include 4 event
% variables.
% 2) Your animals 3-digit name stored in the 3rd position in the loading list
%so you can call it as 'mouse{3}' (or just change the code).
% 3) RR intervals, FP data and EEG loaded and preprocessed.
% 4) Add the animals you're running to a list called 'o' (that's what we're
% looping over).
%% resample NE
% Original signal
fs_original = signal_fs_124;  % original sampling frequency
fs_new = 64;                           % new sampling frequency

% Load or define your original signal here, e.g.,
% delta465_filt_2_124 = load('your_data_file.mat').your_signal_variable;

% Calculate the greatest common divisor to find the optimal downsample factor
gcd_fs = gcd(round(fs_original), fs_new);

% Compute downsample and upsample factors
P = fs_new / gcd_fs;
Q = round(fs_original) / gcd_fs;

% Resample the signal
delta465_cross_124 = resample(delta465_filt_2_124, P, Q);
%Create associated time vector
sec_signal_cross_124 = (1:length(delta465_cross_124))/fs_new;

% You can now use delta465_resampled for further processing, such as cross-correlation with the RR signal

%% Collect data for cross correlation
%add the names of your event variables down here
event_var_blank = {'NREMexclMA_periods_pklocs', 'SWS_before_MA_pklocs', 'SWS_before_wake_pklocs', 'REM_before_wake_pklocs'};
var_lenght = length(event_var_blank)*length(o);

%Time before and after the event you want to look at
epoc_start = 30;
epoc_end = 60;

iteration_counter = 0;

% Initialize collector arrays
NE_cross = cell(var_lenght, 2);
RR_cross = cell(var_lenght, 2);

for idx = 1:length(o)
    mouse = o{idx};
    % Since mouse{3} contains the ID for all mice, directly use it to create the mouseID
    mouseID = mouse{3}; % Extract the unique ID from the third index
    disp(['Processing mouse ID: ', mouseID]);
    ID = sprintf('M%s', mouseID);

        % Create a new cell array for storing the renamed variables
    event_var = cell(size(event_var_blank));
    for i = 1:length(event_var_blank)
        event_var{i} = sprintf('%s_%s', event_var_blank{i}, mouseID);
    end

    % Format the variable names for EEG and other signals
    sec_signal_2 = sprintf('sec_signal_cross_%s', mouseID);
    NE_fs = sprintf('RR_fs_%s', mouseID);
    delta465_filt_2 = sprintf('delta465_cross_%s', mouseID);
    RR = sprintf('RR_%s', mouseID);
    RR_time = sprintf('RR_time_%s', mouseID);
    RR_fs = sprintf('RR_fs_%s', mouseID);


    % Access the variables dynamically
    sec_signal_2 = eval(sec_signal_2);
    NE_fs = eval(NE_fs);
    delta465_filt_2 = eval(delta465_filt_2);
    RR = eval(RR);
    RR_time = eval(RR_time);
    RR_fs = eval(RR_fs);

    % Iterate over each sleep stage (event variable) and its NE trough variables
    for stage_idx = 1:length(event_var)
        event_type_name = event_var{stage_idx}; % Select the current event type
        event_type = eval(event_type_name); %Extract the actual data
        num_events = length(event_type); % Number of events for the current sleep stage
        iteration_counter = iteration_counter + 1;  % Increment the counter each time the loop runs

        % Resetting collectors for each sleep stage
        NE_peak_epoc_collector = [];
        RR_collector = [];

        mid_point = ceil(epoc_start * RR_fs);  % This should be the index of the event time
        total_epoch_length = ceil((epoc_start + epoc_end) * RR_fs);

        % Extract NE and RR for the current sleep stage
        for i = 1:length(event_type)
            NEpk_i = event_type(i);
            if NEpk_i > sec_signal_2(end) - epoc_end % Skip if event is too close to end of recording
                disp(['Event ', num2str(i), ' skipped due to proximity to start/end of recording']);
                continue;
            end

            % Extract NE epochs
            NEpk_epoc_i = delta465_filt_2((NEpk_i - epoc_start) * NE_fs : (NEpk_i + epoc_end) * NE_fs);
            NE_peak_epoc_collector = [NE_peak_epoc_collector; NEpk_epoc_i];

            HRB_i = event_type(i);
            if HRB_i < RR_time(1) + epoc_start || HRB_i > RR_time(end) - epoc_end
                disp(['Event ', num2str(i), ' skipped due to proximity to start/end of recording']);
                continue;  % Skip this event
            end

            [~, event_idx] = min(abs(RR_time - HRB_i));  % Find the event index in filtered_RR_time

            epoch_start_idx = max(event_idx - mid_point + 1, 1);
            epoch_end_idx = min(event_idx + (total_epoch_length - mid_point), length(RR));

            if epoch_end_idx - epoch_start_idx + 1 <= total_epoch_length
                RR_collector(1:(epoch_end_idx - epoch_start_idx + 1), i) = RR(epoch_start_idx:epoch_end_idx);
            end
        end      
        
        % Append the collected data to the corresponding all array
        NE_cross{iteration_counter, 1} = event_var{stage_idx};
        NE_cross{iteration_counter, 2} = NE_peak_epoc_collector;
        RR_cross{iteration_counter, 1} = event_var{stage_idx};
        RR_cross{iteration_counter, 2} = RR_collector';

        NE_length = size(NE_cross{stage_idx, 2}, 2); % number of columns in NE data
        RR_length = size(RR_cross{stage_idx, 2}, 2); % number of columns in RR data
    
        %determine if the same number of datapoints are extracted from the
        %2 data types - if not, cut them from the end.
        if NE_length ~= RR_length
            % Calculate the difference and determine which one is longer
            diff = abs(NE_length - RR_length);
            if NE_length > RR_length
                % NE is longer, trim it
                NE_cross{stage_idx, 2} = NE_cross{stage_idx, 2}(:, 1:end-diff);
                warning_msg = sprintf('Warning: NE and RR not the same length. Cutting %d datapoints from NE %s.', diff, NE_cross{stage_idx, 1});
            else
                % RR is longer, trim it
                RR_cross{stage_idx, 2} = RR_cross{stage_idx, 2}(:, 1:end-diff);
                warning_msg = sprintf('Warning: NE and RR not the same length. Cutting %d datapoints from RR %s.', diff, RR_cross{stage_idx, 1});
            end
            % Display the warning message
            disp(warning_msg);
        end
    end
end

%% Calculate crosscorelation
SamplingRate = RR_fs_124; % Hz (assuming that it is the same as before)
event_n = length(RR_cross); %How many event there are 

cross_corr = cell(event_n, 4); % Fixed name here from cross_cor to cross_corr to match further usage

for stage = 1:event_n
    % period_name = summary_index(stage); % Make sure 'summary_index' is defined and has the same length as 'event_n'
    NE = NE_cross{stage, 2};
    RR = RR_cross{stage, 2};

    correlation_collector = [];

    % Ensure NE and RR have the same number of epochs recorded to prevent indexing errors
    min_epochs = min(size(NE, 1), size(RR, 1));
    for i = 1:min_epochs
        NE_period = NE(i, :);
        RR_period = RR(i, :);

        [cc1, lags] = xcorr(NE_period, RR_period, 'coeff'); % 'coeff' normalizes the correlation
        correlation_collector = [correlation_collector, cc1'];
    end

    % Calculate the mean of all correlations in the correlation collector if non-empty
    if ~isempty(correlation_collector)
        mean_correlations = mean(correlation_collector, 2);
        % Calculate standard error of the mean (SEM)
        N = size(correlation_collector, 2); % Number of observations is the number of columns
        std_dev = std(correlation_collector, 0, 2); % Standard deviation across columns
        SEM = std_dev / sqrt(N); % Standard error of the mean
    else
        mean_correlations = [];
        SEM = [];
    end

    cross_corr{stage, 1} = RR_cross{stage, 1}; %Get the event title
    cross_corr{stage, 2} = mean_correlations;
    cross_corr{stage, 3} = SEM; % Store the standard error in the 3rd column
    cross_corr{stage, 4} = lags; 
end


%% Cross correlation plot
% Define the titles for each subplot
subplot_titles = {'NREM', 'NREM to MA', 'NREM to Wake', 'REM to Wake'};

% Define the overall title and figure setup
figure;
sgtitle('Cross Correlation Between NE and RR'); % Super title for the whole figure
set(gcf,'color','white')

% Initialize variables to store global min and max
% global_min = Inf;
% global_max = -Inf;
% 
% % First pass: Determine the global min and max across all subplots
% for i = 1:4
%     mean_correlations = cross_corr{i, 2};
%     SEM = cross_corr{i, 4};
%     temp_min = min(mean_correlations - SEM);
%     temp_max = max(mean_correlations + SEM);
% 
%     if temp_min < global_min
%         global_min = temp_min;
%     end
%     if temp_max > global_max
%         global_max = temp_max;
%     end
% end

% Loop through each row in cross_corr to create subplots
for i = 1:4
    % Access the data for the current subplot
    mean_correlations = cross_corr{i, 2};
    SEM = cross_corr{i, 3};
    event_name = subplot_titles{i}; % Current event name for titles
    disp(mean(mean_correlations));

    % Create the time vector for the plot, assuming the lags are centered at 0 and evenly spaced
    time_vector = linspace(-30, 60, length(mean_correlations)); % Time vector from -30 to 60 seconds

    % Create subplot
    subplot(2, 2, i);
    hold on;

    % Plot mean with a blue line
    plot(time_vector, -mean_correlations, 'b', 'LineWidth', 1.5); %I added a '-' here to invert, but feel free to change it.

    % Add shaded error bar (SE)
    shadedErrorBar(time_vector, -mean_correlations, -SEM);

    % Add vertical dashed line at x=0
    %y_limits = ylim([global_min global_max]);  % This should correctly set the y-limits before plotting the line
   % plot([0 0], y_limits, '--', 'Color', [0.8 0.8 0.8]);
    plot([0 0], '--', 'Color', [0.8 0.8 0.8]);

    % Formatting the subplot
    xlabel('Time (s)');
    ylabel('R');
    title(event_name);
    grid on;
    hold off;

    % Set the y-axis limits to the global min and max after all plot commands
   % ylim('limits', [global_min global_max]);

end