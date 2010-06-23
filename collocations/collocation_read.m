function [M, cols_out] = collocation_read(sat1, sensor1, sat2, sensor2, ...
    start_date, end_date, cols_in, limits)

% collocation_read Read collocations for indicated period
%
% This m-file reads all the collocations for the indicated period, between
% start_date and end_date, for the indicated collocations type (like
% collocations between CloudSat and MHS or between MHS and MHS).
%
% FORMAT
%
%   [M, cols] = collocation_read(...
%       sat1, sensor1, sat2, sensor2, ...
%       start_date, end_date, cols_in, limits)
%
% IN
%
%   sat1        string          primary satellite
%   sensor1     string          sensor on satellite; passed on to reader
%                               function which can still return data from
%                               other sensors; for example,
%                               cloudsat/cpr+noaa18/mhs can also return
%                               data from amsua or hirs.
%   sat2        string          secondary satellite
%   sensor2     string          sensor on satellite
%   start_date  3x1 array       Starting date for which to read collocations
%   end_date    3x1 array       Ending date for which to read collocations
%   cols_in     cell matrix     Column names. This is passed on to the
%                               reader function.
%   limits      structure       Describes acceptable ranges for the
%                               different columns requested. Data outside
%                               this ranges will not be returned.
%
% OUT
%
%   M           NxM matrix  Matrix containing collected info
%   cols        structure   Structure describing the names of the columns
%
% For examples, see atmlab/collocations/README
%
% $Id$

%% prepare configuration things

getpath = colloc_config(['filename_' sensor1 '_' sensor2]);
cols = colloc_config(['cols_' sensor1 '_' sensor2]);

%% convert column names to numbers

if iscellstr(cols_in)
    cols_in = {cols_in};
end
[colno, name_struct] = colloc_colname2no(sensor1, sensor2, cols_in);

%% convert limits structure to matrix as wanted by restrain_collocations

if exist('limits', 'var')
    C = cellfun(@(c) ...
            [name_struct.(c)' ...
             repmat(limits.(c), [size(name_struct.(c), 2) 1])], ...
            fieldnames(limits), 'UniformOutput', false);
    limmat = vertcat(C{:});
end

%% pre-allocate at least one row

M = zeros(0, sum(cellfun(@length, colno)));
% make sure it all has length 3 (child will know to ignore empty ones)
paths = {[], [], []};
for i = length(colno)+1:3
    colno{i} = [];
end

%% loop through all the dates

dates = daterange(start_date, end_date);
for i = 1:size(dates, 1)
    date = dates(i, :);
    %% read collocations for date
    
    [paths{1:length(cols_in)}] = getpath(date(1), date(2), date(3), sat1, sat2);
    try
        collocations_day = read_collocs_data_mean(...
            paths{1:3}, cols, colno);
    catch ME
        switch (ME.identifier)
            case 'MATLAB:load:couldNotReadFile'
                logtext(colloc_config('stderr'), 'Problem for %04d-%02d-%02d: %s\n', ...
                    date(1), date(2), date(3), ME.message);
                continue
            otherwise
                ME.rethrow();
        end
    end
    if isempty(collocations_day)
        logtext(colloc_config('stdout'), 'no collocations\n');
        continue
    end

    %% apply limitations
    if exist('limits', 'var')
        lim = collocation_restrain(collocations_day, limmat);
        logtext(colloc_config('stdout'), ...
            '%d -> %d collocations\n', size(collocations_day, 1), sum(lim));
        collocations_day = collocations_day(lim, :);
    end
    
    L = size(M, 1);
    N = size(collocations_day, 1);
    M((L+1):(L+N), :) = collocations_day;
end

cols_out = name_struct;