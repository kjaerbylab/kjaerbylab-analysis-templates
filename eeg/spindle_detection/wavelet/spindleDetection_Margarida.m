function [spindle, param] = spindleDetection_Margarida(inputSignal, sampRate, varargin)
% v2
% Detect sleep spindles from one or more EEG channels using wavelet power
%
% -------------------------------------------------------------------------
% IMPORTANT CONTEXT / DATA ASSUMPTIONS
% -------------------------------------------------------------------------
% This detector is prepared for EEG sleep recordings where:
%
%   1) The signal is EEG sampled at a high sampling rate and then
%      internally resampled to targetFs, by default 200 Hz
%
%   2) Spindles are expected during NREM sleep and are detected in the
%      9-16 Hz range, with the main wavelet power estimated from 10-14 Hz
%
%   3) If a sleep-state mask is provided, it must already be expanded to the
%      target sampling rate. For example:
%
%          - 1 s scoring, targetFs = 200 Hz:
%                stateMask = repelem(NREM_epochs, 200);
%
%          - 2 s scoring, targetFs = 200 Hz:
%                stateMask = repelem(NREM_epochs, 400);
%
%      The detector does not know whether the scoring was 1 s, 2 s, or 5 s
%      It only expects one logical value per EEG sample after resampling
%
%   4) Thresholds are adaptive and estimated per channel/session.
%      This makes detection robust across animals, but it also means that
%      spindle counts are relative to each recording's own power distribution.
%      If comparing genotypes or conditions, it is recommended to also inspect
%      spindle amplitude, density, duration, central frequency, and threshold
%      values
%
%   5) For multi-channel data, spindle is returned as one cell per channel.
%      The param.thrL/thrH/thrM fields correspond to the last processed
%      channel only. This is kept intentionally to preserve the original
%      function behavior
%
% -------------------------------------------------------------------------
% Algorithm
% -------------------------------------------------------------------------
%   1) Detrends and resamples the signal to a fixed sampling rate
%   2) Estimates spindle-band power using b-spline wavelet transform
%   3) Detects candidate events using adaptive thresholds
%   4) Validates each event by duration, cycle count, spectral content,
%      and optional overlap with a provided state mask
%
% -------------------------------------------------------------------------
% Inputs
% -------------------------------------------------------------------------
%   inputSignal : samples x channels matrix, or a single vector
%   sampRate    : original sampling rate (Hz)
%
% -------------------------------------------------------------------------
% Name-value options
% -------------------------------------------------------------------------
%   'targetFs'    : resampling rate used internally
%                   default: 200 Hz
%
%   'stateMask'   : logical vector at targetFs.
%                   If provided:
%                     - thresholds are estimated only from masked samples
%                     - detected events must overlap sufficiently with mask
%
%   'minMaskFrac' : minimum fraction of event inside stateMask
%                   default: 0.8
%
%   'thrF'        : threshold multipliers [low high max]
%                   default: [1 3 20]
%
% -------------------------------------------------------------------------
% Outputs
% -------------------------------------------------------------------------
%   spindle : cell array, one entry per channel. Each entry contains a
%             struct array with one element per detected spindle.
%
%   param   : parameter struct used by the detector.
%             For multi-channel data, thrL/thrH/thrM correspond to the
%             last processed channel.

% -------------------------------------------------------------------------
% Parse options
% -------------------------------------------------------------------------
p = inputParser;
p.addParameter('targetFs', 200, @(x)isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('stateMask', [], @(x)islogical(x) || isempty(x));
p.addParameter('minMaskFrac', 0.8, @(x)isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
p.addParameter('thrF', [1 3 20], @(x)isnumeric(x) && numel(x) == 3);
p.parse(varargin{:});
opt = p.Results;

% -------------------------------------------------------------------------
% Default detector settings
% -------------------------------------------------------------------------
param.freq     = [9 10 14 16];   % [lowEdge lowCWT highCWT highEdge] in Hz
param.thrF     = opt.thrF;       % threshold multipliers [low high max]
param.minDur   = 0.4;            % minimum spindle duration (s)
param.maxDur   = 2.0;            % maximum spindle duration (s)
param.minCycle = 5;              % minimum number of positive peaks
param.maxCycle = 30;             % maximum number of positive peaks

% -------------------------------------------------------------------------
% Basic preprocessing
% -------------------------------------------------------------------------
% Force column-major orientation for single-channel row vectors
% This assumes inputSignal is either:
%   - samples x channels
%   - or a single-channel row vector
if size(inputSignal, 2) > size(inputSignal, 1)
    inputSignal = inputSignal';
end

inputSignal = detrend(double(inputSignal));

% Resample signal to the target sampling rate used by the detector
% All later timing, mask alignment and spindle indices are in this targetFs
if sampRate ~= opt.targetFs
    inputSignal = resample(inputSignal, opt.targetFs, sampRate);
end
sampRate = opt.targetFs;

% -------------------------------------------------------------------------
% Validate and align optional state mask
% -------------------------------------------------------------------------
stateMask = opt.stateMask;

if ~isempty(stateMask)
    stateMask = stateMask(:);
    nSamples = size(inputSignal, 1);

    % IMPORTANT:
    % The mask must already be expanded to targetFs
    % This trimming is only a safety step to avoid indexing errors
    % If trimming happens, it usually means that the scoring vector and EEG
    % length were not perfectly aligned
    if length(stateMask) ~= nSamples
        warning(['stateMask length (%d) does not match resampled EEG length (%d). ' ...
                 'Both will be trimmed to the shortest length. Check scoring epoch length.'], ...
                 length(stateMask), nSamples);

        nKeep = min(length(stateMask), nSamples);
        stateMask   = stateMask(1:nKeep);
        inputSignal = inputSignal(1:nKeep, :);
    end
end

% -------------------------------------------------------------------------
% Prepare output container
% -------------------------------------------------------------------------
nCh = size(inputSignal, 2);
spindle = cell(nCh, 1);

emptySpindle = struct( ...
    'start',     {}, ...
    'end',       {}, ...
    'length',    {}, ...
    'centFreq',  {}, ...
    'negPeak',   {}, ...
    'posPeak',   {}, ...
    'peak2peak', {}, ...
    'noCycle',   {}, ...
    'symmetry',  {}, ...
    'start_s',   {}, ...
    'end_s',     {} );

% -------------------------------------------------------------------------
% Run spindle detection channel by channel
% -------------------------------------------------------------------------
for iCh = 1:nCh

    chanSignal = inputSignal(:, iCh);
    sp = emptySpindle;

    % ---------------------------------------------------------------------
    % Estimate spindle-band wavelet power
    % ---------------------------------------------------------------------
    % This detector uses a frequency B-spline wavelet
    % Main spindle-band power is estimated from 10 to 14 Hz, while later
    % validation uses the broader 9-16 Hz filtered signal
    waveName    = 'fbsp2-1-2';
    wavCentFreq = centfrq(waveName);
    freqCent    = param.freq(2):0.5:param.freq(3);   % 10:0.5:14 Hz
    scales      = wavCentFreq ./ (freqCent ./ sampRate);

    cwtCoef  = cwt(chanSignal, scales, waveName);
    cwtPower = abs(cwtCoef).^2;

    % Weight by frequency to compensate partly for 1/f-like EEG power bias
    cwtPower = freqCent * cwtPower;

    % Smooth power trace over ~200 ms
    % Note: this keeps the original behavior. The Hann window is not
    % normalized here, so absolute power depends on the window length
    % Because thresholds are estimated from the same smoothed signal, this
    % should not affect within-recording detection, but it matters if raw
    % cwtPower values are compared across settings
    smoothWin = max(1, round(sampRate / 5));
    cwtPower  = conv(cwtPower, hann(smoothWin), 'same');

    % ---------------------------------------------------------------------
    % Bandpass filter for cycle counting and waveform measurements
    % ---------------------------------------------------------------------
    % This is used only for waveform/cycle validation, not for the initial
    % wavelet-power detection
    filtOrder = round(3 * (sampRate / param.freq(1)));
    b = fir1(filtOrder, [param.freq(1), param.freq(4)] ./ (sampRate / 2));
    filtData = filtfilt(b, 1, chanSignal);

    % ---------------------------------------------------------------------
    % Estimate adaptive thresholds
    % ---------------------------------------------------------------------
    if isempty(stateMask)
        cwtPowerForThr = cwtPower;
    else
        % If a state mask is supplied, thresholds are estimated only from
        % masked samples, typically NREM samples
        cwtPowerForThr = cwtPower(stateMask);
    end

    % ---------------------------------------------------------------------
    % Safer outlier removal before threshold estimation
    % ---------------------------------------------------------------------
    % 
    %   Remove only extreme values above median + 10*SD.
    %   This keeps the threshold distribution centered around the real
    %   signal instead of comparing positive power values only to SD
    cwtPowerForThr = cwtPowerForThr(:);
    cwtPowerForThr = cwtPowerForThr(~isnan(cwtPowerForThr));

    if isempty(cwtPowerForThr)
        warning('No valid samples available for threshold estimation in channel %d.', iCh);
        spindle{iCh} = sp;
        continue
    end

    medThr = nanmedian(cwtPowerForThr);
    sdThr  = nanstd(cwtPowerForThr);

    cwtPowerForThr = cwtPowerForThr(cwtPowerForThr < medThr + 10 * sdThr);

    if isempty(cwtPowerForThr)
        warning('All threshold samples removed as outliers in channel %d.', iCh);
        spindle{iCh} = sp;
        continue
    end

    param.thrL = nanmean(cwtPowerForThr) + param.thrF(1) * nanstd(cwtPowerForThr);
    param.thrH = nanmean(cwtPowerForThr) + param.thrF(2) * nanstd(cwtPowerForThr);
    param.thrM = nanmean(cwtPowerForThr) + param.thrF(3) * nanstd(cwtPowerForThr);

    % ---------------------------------------------------------------------
    % Detect candidate events from high-threshold crossings
    % ---------------------------------------------------------------------
    startIdx = find(diff(sign(cwtPower - param.thrH)) ==  2);
    endIdx   = find(diff(sign(cwtPower - param.thrH)) == -2);

    if isempty(startIdx) || isempty(endIdx)
        spindle{iCh} = sp;
        continue
    end

    % Ensure events are properly paired
    if endIdx(1) < startIdx(1)
        endIdx(1) = [];
    end

    if length(startIdx) > length(endIdx)
        startIdx(end) = [];
    end

    % Refine each candidate using the lower threshold
    % This expands the high-threshold event to the surrounding low-threshold
    % boundaries
    validPairs   = false(size(startIdx));
    refinedStart = nan(size(startIdx));
    refinedEnd   = nan(size(endIdx));

    for iEvt = 1:length(startIdx)

        % Last sample below low threshold before crossing above thrH.
        s = find((cwtPower(1:startIdx(iEvt)) - param.thrL) < 0, 1, 'last');

        % First sample below low threshold after crossing below thrH.
        eLocal = find((cwtPower(endIdx(iEvt):end) - param.thrL) < 0, 1, 'first');

        if ~isempty(s) && ~isempty(eLocal)
            e = endIdx(iEvt) + eLocal - 1;
            refinedStart(iEvt) = s;
            refinedEnd(iEvt)   = e;
            validPairs(iEvt)   = true;
        end
    end

    startIdx = refinedStart(validPairs);
    endIdx   = refinedEnd(validPairs);

    if isempty(startIdx)
        spindle{iCh} = sp;
        continue
    end

    eventDur = (endIdx - startIdx) ./ sampRate;

    % ---------------------------------------------------------------------
    % Validate each candidate event
    % ---------------------------------------------------------------------
    nSp = 0;

    for iEvt = 1:length(startIdx)

        s = startIdx(iEvt);
        e = endIdx(iEvt);

        % Require sufficient overlap with the requested state mask
        % This is useful when detecting spindles only during NREM
        % The default requires 80% of the spindle event to fall inside mask
        if ~isempty(stateMask)
            fracInsideMask = mean(stateMask(s:e));
            if fracInsideMask < opt.minMaskFrac
                continue
            end
        end

        % Duration criterion
        % Default range: 0.4-2.0 s
        if eventDur(iEvt) < param.minDur || eventDur(iEvt) > param.maxDur
            continue
        end

        % Count positive and negative peaks in the spindle-band filtered signal.
        % Very noisy EEG can lead to over-counting of small peaks
        segmentFilt = filtData(s:e);

        [peakPos, locPos] = findpeaks(segmentFilt);
        [peakNeg, ~]      = findpeaks(-segmentFilt);

        nCycles = length(peakPos);

        if nCycles < param.minCycle || nCycles > param.maxCycle
            continue
        end

        % Reject unusually large events
        % This helps remove artifacts or very high-amplitude non-spindle events
        if nanmax(cwtPower(s:e)) > param.thrM
            continue
        end

        % -----------------------------------------------------------------
        % Estimate central frequency with Welch PSD
        % -----------------------------------------------------------------
        % Add padding for middle events so the estimate is less edge-biased
        if iEvt == 1 || iEvt == length(startIdx)
            segSpin = chanSignal(s:e);
        else
            pad = floor(sampRate / 4);
            segSpin = chanSignal(max(1, s - pad):min(length(chanSignal), e + pad));
        end

        [pxx, f] = pwelch(segSpin, hann(length(segSpin)), 0, 2 * sampRate, sampRate);
        pxx = f .* pxx;

        idxSpinBand = (f >= param.freq(1) & f <= param.freq(4));
        [~, idxMax] = max(pxx(idxSpinBand));
        fSpin = f(idxSpinBand);
        centFreq = fSpin(idxMax);

        % -----------------------------------------------------------------
        % Ensure the event is spindle-dominant compared with adjacent bands
        % -----------------------------------------------------------------
        % This rejects events where nearby lower or higher frequencies dominate
        % over the spindle band.
        fMargin = [6:0.5:8.5, 16.5:0.5:20];

        [~, locMargin] = ismembertol(fMargin, f, 1e-6);
        locMargin = locMargin(locMargin > 0);

        pxxMargin = pxx(locMargin);
        pxxSpin   = pxx(f > param.freq(1) & f < param.freq(4));

        if max(pxxSpin) < max(pxxMargin)
            continue
        end

        % -----------------------------------------------------------------
        % Store spindle features
        % -----------------------------------------------------------------
        [~, idxPeakPos] = max(peakPos);

        nSp = nSp + 1;

        sp(nSp).start     = s;
        sp(nSp).end       = e;
        sp(nSp).length    = eventDur(iEvt);
        sp(nSp).centFreq  = centFreq;
        sp(nSp).negPeak   = -max(peakNeg);
        sp(nSp).posPeak   = max(peakPos);
        sp(nSp).peak2peak = max(peakPos) + max(peakNeg);
        sp(nSp).noCycle   = nCycles;
        sp(nSp).symmetry  = locPos(idxPeakPos) / (sampRate * eventDur(iEvt));

        % Timing is reported in seconds after resampling.
        % Kept as s/sampRate to preserve original behavior.
        % Note: in MATLAB sample 1 technically corresponds to time 0,
        % so exact sample-time conversion would be (s-1)/sampRate.
        sp(nSp).start_s   = s / sampRate;
        sp(nSp).end_s     = e / sampRate;
    end

    spindle{iCh} = sp;
end

end