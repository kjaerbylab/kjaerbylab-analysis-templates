%% example to remember what comes first!! keep A as a reference
% Ask user if they want to see the cross-correlation example
answer = questdlg('Do you want to see the cross-correlation example to understand time lag?', ...
    'Cross-Correlation Example', ...
    'Yes', 'No', 'Yes');  % Default to 'Yes'
% Handle response
if strcmp(answer, 'Yes')
    % Prompt the user to input the time shift they want (in seconds)
    prompt = {'Enter the time shift of the B signal (in seconds):'};
    dlgtitle = 'Time Shift Input';
    dims = [1 35];  % Dimensions of the input box (1 row, 35 columns)
    definput = {'1'};  % Default value of 1 second
    answer_shift = inputdlg(prompt, dlgtitle, dims, definput);  % Input dialog
    % Convert the input time shift from string to a number
    time_shift = str2double(answer_shift{1});
    % Define time vector
    t = 0:0.1:10;  % Time vector (0.1s intervals)
    % Signal A (Reference) - Flat line with a single spike
    A = zeros(size(t));   % Flat line (all zeros)
    A(t >= 4 & t <= 4.2) = 1;  % Single spike between 4s and 4.2s
    % Signal B (Shifted version of A) - Same spike but shifted by 'time_shift' seconds
    B = zeros(size(t));   % Flat line (all zeros)
    B(t >= (4 + time_shift) & t <= (4.2 + time_shift)) = 1;  % Spike shifted by 'time_shift' seconds
    % Plot Signal A and Signal B
    figure;
    plot(t, A, 'b', 'LineWidth', 1.5, 'DisplayName', 'Signal A (Reference)');
    hold on;
    plot(t, B, 'r', 'LineWidth', 1.5, 'DisplayName', 'Signal B (Shifted)');
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(['Signal A (Reference) and Signal B (Shifted by ', num2str(time_shift), ' seconds)']);
    legend('show');
    grid on;
    hold off;
    % Compute cross-correlation between A and B
    [cross_corr, lags] = xcorr(A, B, 'unbiased');  % Cross-correlation of A and B
    % Convert lags to seconds (assuming sampling frequency of 10 Hz)
    signal_fs = 10;  % Sampling frequency (Hz)
    time_lags = lags / signal_fs;  % Convert lags to seconds
    % Plot cross-correlation
    figure;
    plot(time_lags, cross_corr);
    xlabel('Time Lag (s)');
    ylabel('Cross-Correlation');
    title('Cross-Correlation between Signal A and Signal B');
    grid on;
else
    % If 'No' is selected, skip the example
    disp('Skipping the cross-correlation example.');
    return;  % Skip the rest of the code
end