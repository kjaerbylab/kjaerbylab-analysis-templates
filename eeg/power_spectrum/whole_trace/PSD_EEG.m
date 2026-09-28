function [prism_freq, prism_psd] = PSD_EEG(full_trace, fs, plot_flag)
% PSD_EEG Compute EEG power spectral density and optionally plot it
% 
%   [prism_freq, prism_psd] = PSD_EEG(full_trace, fs, plot_flag)
%
%   Inputs:
%     full_trace : EEG signal vector
%     fs         : Sampling frequency in Hz
%     plot_flag  : Logical flag (true/false). If true, plot the PSD.
%
%   Outputs:
%     prism_freq : Frequencies up to 45 Hz
%     prism_psd  : PSD values in dB/Hz for frequencies up to 45 Hz

    % Bandpass filter between 0.5 and 100 Hz
    [b, a] = butter(2, [0.5 100] / (fs / 2), 'bandpass');
    full_trace = filtfilt(b, a, full_trace);

    % Welch method parameters
    pw_window = blackmanharris(2*fs);
    noverlap = fs; 
    nfft = 2*fs;

    % Compute PSD
    [pxx, f] = pwelch(full_trace, pw_window, noverlap, nfft, fs);
    logpxx = 10 * log10(pxx);

    % Limit to <45 Hz
    prism_freq = f(f < 45);
    prism_psd = logpxx(f < 45);

    % Plot if requested
    if nargin < 3
        plot_flag = true; % Default to true if not provided
    end

    if plot_flag
        figure;
        plot(prism_freq, prism_psd, 'LineWidth', 1.5);
        xlabel('Frequency (Hz)');
        ylabel('Power/Frequency (dB/Hz)');
        title('Power Spectral Density');
        grid on;
    end

end