function [M, c] = collocation_read_dual(...
    sat1, sensor1, sat2, sensor2, ...
    startdate, enddate, ...
    cols1, cols2, limits1, limits2, ...
    filter1, filter2)

% collocation_read_dual Read collocations from two sources
%
% Note! Function is in alpha and will likely change significantly!
% Currently hardcoded for CPR-collocations/AVHRR, this will likely change!
%
% Read collocation from two sources, where the first source describes
% the row numbers to be read from the second source.
%
% FORMAT
%
% [M, c] = collocation_read_dual(...
%   sat1, sensor1, sat2, sensor2, ...
%   startdate, enddate, ...
%   cols1, cols2, limits1, limits2)
%
% IN
%
%       sat1        string      primary satellite
%       sensor1     string      primary pseudosensor, such as
%                               'collocation_cpr_poes'
%       sat2        string      secondary satellite
%       sensor2     string      secondary sensor
%       startdate   3x1 array   datevec for first date
%       enddate     3x1 array   datevec for last date (inclusive)
%       cols1       cell array  Column names from sat1/sensor1
%       cols2       cell array  Column names for sat2/sensor2
%       limits1     structure   Limits to values for sat1/sensor1
%       limits2     structure   Limits to values for sat2/sensor2
%       filter1     cell array  Filters as for collocation_read
%       filter2     cell array  Filters as for collocation_read
%
% OUT
%
%       M           Nxp matrix  Matrix containing N collocations with p
%                   columns
%       c           structure   c1: column names for sat1/sensor1
%                               c2: column names for sat2/sensor2
%
% Example reading the mean values, number of pixels-in-MHS and SD for AVHRR
% 4 and 5, as well as the MHS lat, long, column and time-since-CPR (for the
% first CPR pixel in the MHS), MHS channel 5, the number of CPR-in-MHS and
% the mean CPR-in-MHS, limiting this to at least 10 AVHRR-in-MHS, 10
% CPR-in-MHS, within 40 degrees of the equator, MHS columns 40–50,
% unflagged MHS, nonzero IWP and at most 5 minutes between MHS and the
% first CPR in MHS.
%
% >> [M, c] = collocation_read_dual(...
%       'noaa18', 'collocation_cpr_poes', 'noaa18', 'avhrr', ...
%       [2008 1 1], [2008 1 31], ...
%       {{}, {}, {'NO', 4:5, 'MEAN', 4:5, 'SD', 4:5}}, ...
%       {{'B_LAT', 'B_LONG', 'B_C', 'B_INT'}, {'MHS', 5}, {'NO', 'MEAN'}}, ...
%       struct('NO', [10 inf]), ...
%       struct('B_LAT', [-40 40], 'B_C', [40 50], 'MHS', [0 400], ...
%       'NO', [10 inf], 'MEAN', [eps inf], 'B_INT', [-300 300]), ...
%       {}, {}); % no filters
% (debugging output omitted)
% >> whos M
%   Name         Size             Bytes  Class     Attributes
% 
%   M         1164x15            139680  double              
% 
% >> c.c1
% 
% ans = 
% 
%      CPR_POES_START: 1
%     CPR_POES_LINENO: 2
%                  NO: [3 4]
%                MEAN: [5 6]
%                  SD: [7 8]
% 
% >> c.c2
% 
% ans = 
% 
%      B_LAT: 9
%     B_LONG: 10
%        B_C: 11
%      B_INT: 12
%        MHS: 13
%         NO: 14
%       MEAN: 15
%
% See also collocation_read
%
% $Id$

% make sure CPR_POES_START and CPR_POES_LINENO are in cols1

error('atmlab:collocation_read_dual', 'This function is currently not working!');

if ~any(strcmp(cols1{1}, 'CPR_POES_START'))
    cols1{1} = [cols1{1} 'CPR_POES_START'];
end

if ~any(strcmp(cols1{1}, 'CPR_POES_LINENO'))
    cols1{1} = [cols1{1} 'CPR_POES_LINENO'];
end

[M1, c1] = collocation_read(sat1, sensor1, sat2, sensor2, ...
    startdate, enddate, cols1, limits1, filter1);

links = colloc_config('links');
[~, name_struct] = colloc_colname2no(links.(sensor1).sensor1, links.(sensor1).sensor2, cols2);
limmat = limstruct2limmat(limits2, name_struct);

% for the filters@filter2, convert column names to column numbers, using the
% earlier obtained name_struct
if ~isempty(filter2)
    for i = 1:length(filter2)
        filter2{i}{2} = cellfun(@(s) name_struct.(s)', filter2{i}{2}, 'UniformOutput', false);
    end
end

M1_rows = true(size(M1, 1), 1);

N = 0;
[starttimes, firsts] = unique(M1(:, c1.CPR_POES_START), 'first');
[~, lasts] = unique(M1(:, c1.CPR_POES_START), 'last');
for i = 1:length(starttimes)
    starttime = starttimes(i);
    first = firsts(i);
    last = lasts(i);
    rows = M1(first:last, c1.CPR_POES_LINENO);
    [year month day] = unixsecs2date(starttime);
    [M2, c2] = collocation_read(...
        links.(sensor1).sat1, links.(sensor1).sensor1, ...
        sat1, links.(sensor1).sensor2, ...
        [year month day], [year month day], ...
        cols2);
    M2 = M2(rows, :);
    lim = collocation_restrain(M2, limmat, filter2);
    M1_rows(first:last) = lim;
    M2 = M2(lim, :);
    
    % pre-allocate only here, so that we know the width
    if i==1
        M2_all = nan*zeros(size(M1, 1), size(M2, 2));
    end
    M2_all(N+1:N+size(M2, 1), :) = M2;
    N = N + size(M2, 1);
end
M2_all(isnan(M2_all(:, 1)), :) = []; % get rid of superfluous rows 
M2 = M2_all;

% correct column-numbers for subsequent concatenation
c2 = structfun(@(v) v+size(M1, 2), c2, 'UniformOutput', false);
c.c1 = c1;
c.c2 = c2;
M = [M1(M1_rows, :) M2];
