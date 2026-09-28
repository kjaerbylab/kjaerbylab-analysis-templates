function trough_samples = spindle_trough_detect(filtered_signal, spindle_onoff, troughType)
% FIND_SPINDLE_TROUGHS
% Inputs:
%   filtered_signal : vector, bandpass-filtered EEG/LFP
%   spindle_onoff   : n x 2 matrix of [onset, offset] samples
%   troughType      : 'lowest' (default), 'first', or 'last'
%                      - 'lowest': global minimum within the spindle (original behavior)
%                      - 'first' : first local minimum within the spindle
%                      - 'last'  : last local minimum within the spindle
% Output:
%   trough_samples  : n x 1 vector of sample indices of the minimum per spindle

if nargin < 3 || isempty(troughType)
    troughType = 'lowest';
end

n_spindles     = size(spindle_onoff, 1);
trough_samples = nan(n_spindles, 1);

for i = 1:n_spindles
    on  = spindle_onoff(i, 1);
    off = spindle_onoff(i, 2);
    segment = filtered_signal(on:off);

    switch troughType
        case 'lowest'
            [~, idx] = min(segment);

        case 'first'
            local_min_idx = find(islocalmin(segment), 1, 'first');
            if isempty(local_min_idx)
                % fallback to global min if no local minimum found
                [~, idx] = min(segment);
            else
                idx = local_min_idx;
            end

        case 'last'
            local_min_idx = find(islocalmin(segment), 1, 'last');
            if isempty(local_min_idx)
                % fallback to global min if no local minimum found
                [~, idx] = min(segment);
            else
                idx = local_min_idx;
            end

        otherwise
            error('Invalid troughType: must be ''lowest'', ''first'', or ''last''.');
    end

    trough_samples(i) = on + idx - 1;  % convert to index in full signal
end
end


% function trough_samples = spindle_trough_detect(filtered_signal, spindle_onoff)
% % FIND_SPINDLE_TROUGHS
% % Inputs:
% %   filtered_signal : vector, bandpass-filtered EEG/LFP
% %   spindle_onoff   : n x 2 matrix of [onset, offset] samples
% % Output:
% %   trough_samples  : n x 1 vector of sample indices of the minimum per spindle
% 
% n_spindles     = size(spindle_onoff, 1);
% trough_samples = nan(n_spindles, 1);
% 
% for i = 1:n_spindles
%     on  = spindle_onoff(i, 1);
%     off = spindle_onoff(i, 2);
% 
%     segment      = filtered_signal(on:off);
%     [~, idx]     = min(segment);
%     trough_samples(i) = on + idx - 1;  % convert to index in full signal
% end
% 
% end