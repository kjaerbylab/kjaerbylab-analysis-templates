function [data_rs, fs_new] = resample_to_fs(data, fs_in, fs_new)
% RESAMPLE_TO_FS  Resample signal(s) to a specified sampling rate with
% antialias protection and automatic skip if already at target rate.
%
%   [data_rs, fs_new] = resample_to_fs(data, fs_in, fs_new)
%
% Inputs
%   data   - [nCh x nSamples] numeric array (each row = one signal)
%   fs_in  - Original sampling rate in Hz (scalar)
%   fs_new - Desired sampling rate in Hz (scalar)
%
% Outputs
%   data_rs - Resampled data at fs_new Hz (same nCh)
%   fs_new  - Output sampling rate (echoed for convenience)
%
% Notes
% - All arguments are in samples (not seconds).
% - Automatically skips resampling if fs_in == fs_new.

% ------------------------------------------------------------
if nargin < 3
    error('Usage: [data_rs, fs_new] = resample_to_fs(data, fs_in, fs_new)');
end

[nCh, nSamp] = size(data);

% If already at target rate, skip resampling
if abs(fs_in - fs_new) < 1e-6
    data_rs = data;
    return;
end

% Estimate target length
est_len = round(nSamp * fs_new / fs_in);

% Compute rational resampling ratio (safe tolerance)
[p, q] = rat(fs_new / fs_in, 1e-6);

% Preallocate with NaNs, then correct after
data_rs = nan(nCh, est_len, 'like', data);

for ch = 1:nCh
    sig = double(data(ch,:));

    % Light 1% Tukey taper to minimize filter edge effects
    taper = tukeywin(length(sig), 0.01)';
    sig = sig .* taper;

    % Perform resampling
    sig_rs = resample(sig, p, q);

    % Adjust length (pad or trim) to match est_len
    nOut = length(sig_rs);
    if nOut > est_len
        sig_rs = sig_rs(1:est_len);
    elseif nOut < est_len
        sig_rs = [sig_rs, zeros(1, est_len - nOut)];
    end

    data_rs(ch,:) = sig_rs;
end
end
