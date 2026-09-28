function idx = nearest_idx(vec, val)
% idx = nearest_idx(vec, val)
% Returns the index of the element in vec that is closest to val.
%
% vec : numeric vector
% val : scalar number
% idx : index of closest element in vec

    [~, idx] = min(abs(vec - val));
end