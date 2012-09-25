function stat_vectors = running_stats(x, y, binsize_xunit, stat_handles)
% running_stats Calculate running statistics
%
% FORMAT
%
%   stats = running_stat(x, y, binsize, stat_handles)
%
% IN
%
%   x [vector]
%       independent quantity, must be constantly spaced
%
%   y [vector]
%       quantity to calculate statistics for
%
%   winsize [scalar]
%       size of window.
%       if positive, interpreted as same unit as x
%       if negative but >-1, interpreted as fraction (negative is just a
%       trick here to pass a flag)
%
%   stat_handles [cell array of function handles]
%       functions to apply to each running window
%       Note that each function MUST accept a dimension as its second
%       argument, such as median(X, 2)!
%
% OUT
%
%   stat_vectors [cell array of vectors]
%       Output of all handles in stat_handles for each running window.
%       Padded with nans at begin and end where sliding stats are
%       undefined.
%
% See also: smooth, medfilt1, movingstd, filter
%
% Note: smooth is in the curve-fitting toolbox, medfilt1 is in the signal
% processing toolbox.
% * in the curve fitting toolbox, otherwise see
%   http://stackoverflow.com/a/1516168/974555
% ^ from File Exchange

% $Id$

% convert binsize [x-unit] to binsize [n-index]

% some input checks

rqre_same_size(x, y);

% verify that x-unit is constantly spaced
% error otherwise

df = diff(x);
spacing_xunit = unique(df);
if length(spacing_xunit)>1
    error(['atmlab:' mfilename ':notunique'], ...
        ['Error in calculation of running statistics: ' ...
        'spacing in independent quantity not constant']);
end

N = round(binsize_xunit/spacing_xunit);
L = length(x);

% pre-allocate
stat_vectors = cell(size(stat_handles));
for i = 1:length(stat_handles)
    stat_vectors{i} = nan(size(x));
end

% Yes: idea from
% http://www.mathworks.com/matlabcentral/fileexchange/29029-summarizes-data-using-a-sliding-window-without-loops/content/movingstat.m

% re-arrange data so there are columns for each window (needs memory)
data_arranged = y(repmat(0:N-1,L-N+1,1)+cumsum(ones(L-N+1,N)));
if iseven(N)
    ran = (N/2):(L-N/2);
else
    ran = (ceil(N/2)):(L-floor(N/2));
end

% TODO: do in chunks similar to medfilt1
for j = 1:length(stat_handles)
    stat_vectors{j}(ran) = stat_handles{j}(data_arranged, 2);
end

% this is the slow version:
% for i = (binsize_n/2+1):(length(x)-binsize_n/2)
%     slice = (i-(binsize_n/2)):(i+(binsize_n/2));
%     segment = y(slice);
%     for j = 1:length(stat_handles)
%         stat_vectors{j}(i) = stat_handles{j}(segment);
%     end
% end


end
