function [epoc_diff_prepost, epoc_pre, epoc_post] = prepostdiff(event_epocs, epoc_fs, time_before, preTrigger_start, preTrigger_end, postTrigger_start, postTrigger_end, varargin)

%PREPOSTDIFF_AUC
% Input arguments:
%   event_epocs: is a matrix, where columns represent the number of epocs (=1 in case of a single mean epoc trace) and rows represent the number of samples (i.e. epoc seconds*fs).
%   epoc_fs: sampling frequency of the trace(s) in event_epocs.
%   time_before: is the number of seconds before time zero in epoc traces
%   preTrigger_start:  is the start time (s) for the pre-event baseline AUC calculation.
%   preTrigger_end: is the end time (s) for the pre-event baseline AUC calculation (set to =0 if pre baseline should end at time of epoc event).
%   postTrigger_start: is the start time (s) for the post-event AUC calculation (set to =0 if post level should start at time of epoc event).
%   postTrigger_end: is the end time (s) for the post-event  AUC calculation.
%   pre_method: is the function handle used for pre level calculation (is @mean by default)
%   post_method: is the function handle used for post level calculation (is @mean by default)
%
% Output arguments:
%   EMG_diff_prepost: a vector of changes in AUC across the epoc event (post-pre). If event_epocs holds a single mean epoc trace, this output will be a single number.
%   EMG_pre: a vector of AUC pre the epoc event.
%   EMG_post: a vector of AUC post the epoc event.
%
% Note: to use AUC as methods use @trapz, and divide the outputs by sampling frequency to normalize to timeline

p = inputParser;

default_pre_method = @mean; % default function handle for pre method
default_post_method = @mean; % default function handle for post method

addRequired(p,'event_epocs',@isnumeric);
addRequired(p,'epoc_fs',@isnumeric);
addRequired(p,'time_before',@isnumeric);
addRequired(p,'preTrigger_start',@isnumeric);
addRequired(p,'preTrigger_end',@isnumeric);
addRequired(p,'postTrigger_start',@isnumeric);
addRequired(p,'postTrigger_end',@isnumeric);

addParameter(p, 'pre_method', default_pre_method, @(x) isa(x, 'function_handle'));
addParameter(p, 'post_method', default_post_method, @(x) isa(x, 'function_handle'));

parse(p, event_epocs, epoc_fs, time_before, preTrigger_start, preTrigger_end, postTrigger_start, postTrigger_end, varargin{:});

pre_method = p.Results.pre_method;
post_method = p.Results.post_method;

epoc_diff_prepost = NaN(size(event_epocs,2),1);
epoc_pre = NaN(size(event_epocs,2),1);
epoc_post = NaN(size(event_epocs,2),1);

for epoc_i = 1:size(event_epocs,2)
    trace_epoc_i = event_epocs(:,epoc_i);
    
    pre_data = trace_epoc_i(round((time_before-preTrigger_start)*epoc_fs):round((time_before-preTrigger_end)*epoc_fs));
    epoc_baseline_pre_i = feval(pre_method, pre_data);
    post_data = trace_epoc_i(round((time_before+postTrigger_start)*epoc_fs):round((time_before+postTrigger_end)*epoc_fs));
    epoc_baseline_post_i = feval(post_method, post_data);
    
    epoc_diff_prepost_i = epoc_baseline_post_i-epoc_baseline_pre_i;
    
    epoc_pre(epoc_i,1) = epoc_baseline_pre_i;
    epoc_post(epoc_i,1) = epoc_baseline_post_i;
    epoc_diff_prepost(epoc_i,1) = epoc_diff_prepost_i;
end