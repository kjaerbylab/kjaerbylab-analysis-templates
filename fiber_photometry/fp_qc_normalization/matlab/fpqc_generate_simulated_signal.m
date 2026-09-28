function raw = fpqc_generate_simulated_signal(varargin)
%FPQC_GENERATE_SIMULATED_SIGNAL Generate synthetic 405/465 photometry data.
%
% raw = fpqc_generate_simulated_signal('durationSec', 3600, 'fs', 20)
%
% The signal contains:
%   - exponential bleaching
%   - shared motion artifacts
%   - 405/control channel
%   - 465/sensor channel
%   - REM-like ACh peaks
%   - one slow artifact bump
%   - noise
%
% This is for demo/QC testing only.

p = inputParser;
addParameter(p, 'durationSec', 3600, @isnumeric);
addParameter(p, 'fs', 20, @isnumeric);
addParameter(p, 'seed', 7, @isnumeric);
parse(p, varargin{:});

durationSec = p.Results.durationSec;
fs = p.Results.fs;
rng(p.Results.seed);

t = (0:1/fs:durationSec)';
n = numel(t);

% Shared bleaching/drift
bleachFast = 0.25 * exp(-t/250);
bleachSlow = 0.45 * exp(-t/2500);
baseline = 1.8 + bleachFast + bleachSlow;

% Shared motion artifacts
motion = zeros(n,1);
artifactTimes = [450 900 1450 2100 2800 3300];
for k = 1:numel(artifactTimes)
    motion = motion + 0.05 * exp(-0.5*((t-artifactTimes(k))/8).^2) .* sign(randn);
end

% Slow artifact bump that is not true ACh
slowBump = 0.10 * exp(-0.5*((t-2300)/250).^2);

% Simulated ACh REM-like events
eventTimes = [650 1250 1800 2600 3150];
ach = zeros(n,1);
for k = 1:numel(eventTimes)
    ach = ach + 0.12 * exp(-0.5*((t-eventTimes(k))/30).^2);
end

% Control and signal
noise405 = 0.015 * randn(n,1);
noise465 = 0.018 * randn(n,1);

signal_405 = baseline + 0.9*motion + noise405;
signal_465 = 1.3*baseline + 0.9*motion + slowBump + ach + noise465 + 0.03;

raw = struct();
raw.t = t;
raw.fs = fs;
raw.signal_405 = signal_405;
raw.signal_465 = signal_465;
raw.true_ach = ach;
raw.true_slow_artifact = slowBump;
raw.eventTimes = eventTimes;
raw.description = 'Synthetic FP data: bleaching + motion + ACh-like events + slow artifact bump.';
raw.chan_405 = 'sim405';
raw.chan_465 = 'sim465';
end
