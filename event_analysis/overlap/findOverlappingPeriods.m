function [overlap1, overlap2] = findOverlappingPeriods(periods1, periods2)
% FINDOVERLAPPINGPERIODS Check which periods in two sets overlap with any period in the other set.
%
% INPUTS:
%   periods1 - Nx2 matrix of [onset, offset] pairs (first set)
%   periods2 - Mx2 matrix of [onset, offset] pairs (second set)
%   Units can be samples or time, as long as consistent across both inputs.
%
% OUTPUTS:
%   overlap1 - Nx1 logical vector: true if periods1(i,:) overlaps any period in periods2
%   overlap2 - Mx1 logical vector: true if periods2(j,:) overlaps any period in periods1
%
% OVERLAP CONDITION:
%   Two periods [a_on, a_off] and [b_on, b_off] overlap if:
%       a_on < b_off  AND  b_on < a_off
%   This correctly handles all cases: containment, partial overlap,
%   and identical periods. Edge-touching (a_off == b_on) is NOT counted as overlap.

% --- Input validation ---
assert(size(periods1, 2) == 2, 'periods1 must be an Nx2 matrix of [onset, offset] pairs.');
assert(size(periods2, 2) == 2, 'periods2 must be an Mx2 matrix of [onset, offset] pairs.');
assert(all(periods1(:,1) < periods1(:,2)), 'All onsets in periods1 must be strictly less than their offsets.');
assert(all(periods2(:,1) < periods2(:,2)), 'All onsets in periods2 must be strictly less than their offsets.');

% --- Broadcast comparison across all pairs ---
% on1/off1: (N x 1), on2/off2: (1 x M) -> overlaps: (N x M) logical matrix
on1  = periods1(:, 1);      % N x 1
off1 = periods1(:, 2);      % N x 1
on2  = periods2(:, 1)';     % 1 x M
off2 = periods2(:, 2)';     % 1 x M

% Two periods overlap iff one starts before the other ends (in both directions)
overlaps = (on1 < off2) & (on2 < off1);    % N x M logical matrix

% Collapse: any overlap with the other set
overlap1 = any(overlaps, 2);   % N x 1
overlap2 = any(overlaps, 1)';  % M x 1

end