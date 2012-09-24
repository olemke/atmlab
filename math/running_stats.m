function stat_vectors = running_stats(x, y, binsize_xunit, stat_handles)
% running_stats Calculate running statistics
%
% *** WARNING ***********************************************************
% *                                                                     *
% * This function is very slow. Only use if your data are small or      *
% * there is no efficient way. Most statistics, such as mean,           *
% * standard devation and quantile calculation, have more efficient     *
% * specialised ways to calculate running statistics!                   *
% *                                                                     *
% ***********************************************************************
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
%       size of window, same unit as x
%
%   stat_handles [cell array of function handles]
%       functions to apply to each running window
%
% OUT
%
%   stat_vectors [cell array of vectors]
%       Output of all handles in stat_handles for each running window.
%       Padded with nans at begin and end where sliding stats are
%       undefined.
%
% *** WARNING ***********************************************************
% *                                                                     *
% * This function is very slow. Only use if your data are small or      *
% * there is no efficient way. Most statistics, such as mean,           *
% * standard devation and quantile calculation, have more efficient     *
% * specialised ways to calculate running statistics!                   *
% *                                                                     *
% ***********************************************************************
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

binsize_n = round(binsize_xunit/spacing_xunit);

% pre-allocate
stat_vectors = cell(size(stat_handles));
for i = 1:length(size(stat_handles))
    stat_vectors{i} = nan(size(x));
end

% FIXME: can this be done in a faster way?
for i = (binsize_n/2+1):(length(x)-binsize_n/2)
    slice = (i-(binsize_n/2)):(i+(binsize_n/2));
    segment = y(slice);
    for j = 1:length(stat_handles)
        stat_vectors{j}(i) = stat_handles{j}(segment);
    end
end


end
