function raw = fpqc_load_tdt_streams(cfg)
%FPQC_LOAD_TDT_STREAMS Load raw 405/465 data from TDT.
%
% Required:
%   cfg.tdt_dir
%   cfg.chan_465
%   cfg.chan_405
%
% Optional:
%   cfg.analysis_interval_sec = [start end]

if exist('TDTbin2mat', 'file') ~= 2
    error('TDTbin2mat not found. Add the TDT MATLAB SDK to the path.');
end

fp_data = TDTbin2mat(cfg.tdt_dir);

x465 = double(fp_data.streams.(cfg.chan_465).data(:));
x405 = double(fp_data.streams.(cfg.chan_405).data(:));
fs = double(fp_data.streams.(cfg.chan_465).fs);

n = min(numel(x465), numel(x405));
x465 = x465(1:n);
x405 = x405(1:n);
t = (0:n-1)' ./ fs;

if isfield(cfg, 'analysis_interval_sec') && ~isempty(cfg.analysis_interval_sec)
    idx = t >= cfg.analysis_interval_sec(1) & t <= cfg.analysis_interval_sec(2);
    t = t(idx);
    x465 = x465(idx);
    x405 = x405(idx);
    t = t - t(1);
end

raw = struct();
raw.t = t;
raw.fs = fs;
raw.signal_465 = x465;
raw.signal_405 = x405;
raw.chan_465 = cfg.chan_465;
raw.chan_405 = cfg.chan_405;
raw.tdt_dir = cfg.tdt_dir;
end
