function out = powerTrans_byHilbert(x, fs, band_hz, varargin)
% POWERTRANS_BYHILBERT  Stable band-pass -> Hilbert envelope -> power (+ dB)
% Gives a power trace with higher temporal resolution than from 'spectrogram'
%
% out = powerTrans_byHilbert(x, fs, [f1 f2], Name,Value, ...)
%
% Inputs
%   x         : vector (EEG), row or col
%   fs        : sampling frequency (Hz)
%   [f1 f2]   : passband in Hz (e.g., [0.5 4], [10 15], [65 80])
%
% Name-Value options (all optional)
%   'Order'         : IIR Butterworth order per pass (default 4). Use higher order for narrow bands
%   'NotchHz'       : scalar 50 or 60 to notch line noise (default [])
%   'NotchQ'        : quality factor for notch (default 30)
%   'HighpassHz'    : pre-highpass to remove drift (e.g., 0.1) (default [])
%   'SmoothSec'     : movmean window (sec) on power, 0 = none (default 0)
%   'BaselineMask'  : logical vector same length as x for baseline (default [])
%   'Eps'           : epsilon for dB calc (default 1e-20)
%
% Outputs (struct)
%   out.band        : bandpassed signal
%   out.env         : Hilbert envelope (amplitude)
%   out.power       : instantaneous power (env.^2) in units of x^2
%   out.power_dB    : 10*log10(power + eps) [dB re 1 (unit^2)]
%   out.power_dB_rel: if BaselineMask provided, dB relative to baseline median
%   out.sos         : IIR SOS coefficients for the bandpass
%   out.g           : SOS gain
%
% Notes
% - Uses SOS + filtfilt for numerical stability and zero-phase.
% - For delta/theta or narrow bands, SOS is strongly recommended.
% - If you set 'NotchHz', the notch runs BEFORE bandpass.
%
% Example:
%   out = powerTrans_byHilbert(EEG, fs, [10 15], 'Order', 4, 'NotchHz', 50, ...
%                             'SmoothSec', 0.2, 'BaselineMask', t<100);

% ---- Parse inputs
p = inputParser;
p.addParameter('Order',        4,    @(v)isnumeric(v)&&isscalar(v)&&v>0);
p.addParameter('NotchHz',      [],   @(v)isempty(v)||(isscalar(v)&&v>0));
p.addParameter('NotchQ',       30,   @(v)isnumeric(v)&&isscalar(v)&&v>0);
p.addParameter('HighpassHz',   [],   @(v)isempty(v)||(isscalar(v)&&v>=0));
p.addParameter('SmoothSec',    0,    @(v)isnumeric(v)&&isscalar(v)&&v>=0);
p.addParameter('BaselineMask', [],   @(v)islogical(v)||isempty(v));     % use this to define baseline period to get relative dB output
p.addParameter('Eps',          1e-20,@(v)isnumeric(v)&&isscalar(v)&&v>0);
p.addParameter('Performance', 'fast_movmean', @(s)ischar(s) && ismember(lower(s),{'fast_movmean','smooth_convHann'})); % convHann will give smoother traces but takes longer to run
p.parse(varargin{:});
opt = p.Results;

x = x(:);
N = numel(x);
assert(numel(band_hz)==2 && band_hz(1)>0 && band_hz(2)>band_hz(1) && band_hz(2)<fs/2, ...
    'band_hz must be [f1 f2] with 0<f1<f2<fs/2');

% ---- Optional pre-highpass (drift removal)
x_filt = x;
if ~isempty(opt.HighpassHz) && opt.HighpassHz>0
    Wc = opt.HighpassHz/(fs/2);
    [zh,ph,kh] = butter(2, Wc, 'high');     % gentle 2nd-order
    [sosh,gh]  = zp2sos(zh,ph,kh);
    x_filt     = filtfilt(sosh, gh, x_filt);
end

% ---- Optional notch (line noise) BEFORE bandpass
if ~isempty(opt.NotchHz)
    f0 = opt.NotchHz;
    wo = f0/(fs/2);
    bw = wo/opt.NotchQ;
    [bn,an] = iirnotch(wo, bw);
    x_filt  = filtfilt(bn, an, x_filt);
end

% ---- Bandpass (SOS for stability)
Wn = band_hz/(fs/2);
[z,p_,k] = butter(opt.Order, Wn, 'bandpass');
[sos,g]  = zp2sos(z,p_,k);
x_band   = filtfilt(sos, g, x_filt);

% ---- Hilbert envelope -> power
env   = abs(hilbert(x_band));
power = env.^2;

% Optional smoothing (on power)
if opt.SmoothSec > 0
    W = round(opt.SmoothSec * fs);
    switch lower(opt.Performance)
        case 'fast_movmean'
            % rectangular smoothing
            power = movmean(power, W, 'Endpoints','shrink');
        case 'smooth_convHann'
            % Hann-tapered smoothing
            hannWin = hann(W);
            hannWin = hannWin / sum(hannWin);
            power = conv(power, hannWin, 'same');
    end
end

% ---- dB (absolute) and baseline-relative dB
eps0 = opt.Eps;
power_dB = 10*log10(power + eps0);

if isempty(opt.BaselineMask)
    warning('powerTrans_byHilbert:defaultBaseline', ...
        'No BaselineMask provided — using full recording as baseline for power_dB_rel.');
    opt.BaselineMask = true(N, 1);
end

assert(numel(opt.BaselineMask)==N, 'BaselineMask must match x length');
ref = median(power(opt.BaselineMask));
power_dB_rel = 10*log10((power + eps0) / (ref + eps0));

% ---- Pack outputs
out = struct('band', x_band, ...
             'env', env, ...
             'power', power, ...
             'power_dB', power_dB, ...
             'power_dB_rel', power_dB_rel, ...
             'sos', sos, ...
             'g', g);
end
