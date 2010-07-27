function [M1, c1, M2, c2] = collocation_read_dual(...
    sat11, sensor11, sat12, sensor12, ...
    sat21, sensor21, sat22, sensor22, ...
    startdate, enddate, ...
    cols1, cols2, limits1)

% collocation_read_dual Read collocations from two sources
%
% Note! Function is in alpha and will likely change significantly!
%
% Read collocation from more two source, where the first source describes
% the row numbers to be read from the second source.
%
% TODO: limits on second source
%
% FORMAT
%
% (to be documented)
%
% IN
%
% (to be documented)
%
% OUT
%
% (to be documented)
%
% Example:
%
% [M1, c1, M2, c2] = collocation_read_dual(...
%       'noaa18', 'collocation_cpr_poes', 'noaa18', 'avhrr', ...
%       'cloudsat', 'cpr', 'noaa18', 'mhs', ...
%       [2008 1 10], [2008 1 15], ...
%       {{'CPR_POES_START', 'CPR_POES_LINENO', 'AVHRR_LAT', 'AVHRR_LONG'}, ...
%       {}, ...
%       {'NO', 'MEAN', 'SD'}}, ...
%       {{'B_LAT', 'B_LONG', 'B_TIME'}, ...
%       {}, ...
%       {'NO', 'MEAN', 'SD'}}, ...
%       struct('AVHRR_LAT', [-20 20], 'AVHRR_LONG', [-30 30]));
%
% $Id$

[M1, c1] = collocation_read(sat11, sensor11, sat12, sensor12, ...
    startdate, enddate, cols1, limits1);

%M2_all = nan*zeros(size(M1, 1), 6);
N = 0;
[starttimes, firsts] = unique(M1(:, c1.CPR_POES_START), 'first');
[~, lasts] = unique(M1(:, c1.CPR_POES_START), 'last');
for i = 1:length(starttimes)
    starttime = starttimes(i);
    first = firsts(i);
    last = lasts(i);
    rows = M1(first:last, c1.CPR_POES_LINENO);
    [year month day] = unixsecs2date(starttime);
    [M2, c2] = collocation_read(sat21, sensor21, sat22, sensor22, ...
        [year month day], [year month day], ...
        cols2);
    % pre-allocate only here, so that we know the width
    M2 = M2(rows, :);
    if i==1
        M2_all = nan*zeros(size(M1, 1), size(M2, 2));
    end
    M2_all(N+1:N+size(M2, 1), :) = M2;
    N = N + size(M2, 1);
end
M2 = M2_all;