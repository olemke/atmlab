function [M, c] = collocation_read_dual(...
    sat1, sensor1, sat2, sensor2, ...
    startdate, enddate, ...
    cols1, cols2, limits1, limits2)

% collocation_read_dual Read collocations from two sources
%
% Note! Function is in alpha and will likely change significantly!
%
% Read collocation from more two source, where the first source describes
% the row numbers to be read from the second source.
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
% [M, c] = collocation_read_dual(...
%       'noaa18', 'collocation_cpr_poes', 'noaa18', 'avhrr', ...
%       [2008 1 10], [2008 1 15], ...
%       {{'AVHRR_LAT', 'AVHRR_LONG'}, ...
%       {}, ...
%       {'NO', 'MEAN', 'SD'}}, ...
%       {{'B_LAT', 'B_LONG', 'B_TIME'}, ...
%       {}, ...
%       {'NO', 'MEAN', 'CV'}}, ...
%       struct('AVHRR_LAT', [-20 20], 'AVHRR_LONG', [-30 30]), ...
%       struct('CV', [0 1]));
%
% $Id$

% make sure CPR_POES_START and CPR_POES_LINENO are in cols1

if ~any(strcmp(cols1{1}, 'CPR_POES_START'))
    cols1{1} = [cols1{1} 'CPR_POES_START'];
end

if ~any(strcmp(cols1{1}, 'CPR_POES_LINENO'))
    cols1{1} = [cols1{1} 'CPR_POES_LINENO'];
end

[M1, c1] = collocation_read(sat1, sensor1, sat2, sensor2, ...
    startdate, enddate, cols1, limits1);

links = colloc_config('links');
[~, name_struct] = colloc_colname2no(links.(sensor1).sensor1, links.(sensor1).sensor2, cols2);
limmat = limstruct2limmat(limits2, name_struct);
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
    lim = collocation_restrain(M2, limmat);
    logtext(colloc_config('stdout'), ...
        '%d -> %d collocations\n', length(rows), sum(lim));
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
