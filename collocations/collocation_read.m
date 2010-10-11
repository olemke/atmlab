function [M, cols_out] = collocation_read(sat1, sensor1, sat2, sensor2, ...
    start_date, end_date, cols_in, limits, filters)

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
%       start_date, end_date, cols_in[, limits[, filters]])
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
%   cols_in     cell array      Column names. This is passed on to the
%                               reader function.
%   limits      structure       Describes acceptable ranges for the
%                               different columns requested. Data outside
%                               these ranges will not be returned. 
%   filters     cell array      Cell array of cell arrays. Each member of
%                               the cell array is {@filter, {COL1, ...,
%                               COLN}, {'foo', 'bar', ..., 'baz'}}.
%                               The filter is called according to
%                               filter(M(COL1, :), ..., M(COLN, :), 'foo',
%                               'bar', ..., 'baz') and shall return logical
%                               true wherever the filter is passed. See
%                               examples on website (see below).
%
% OUT
%
%   M           NxM matrix  Matrix containing collected info
%   cols        structure   Structure describing the names of the columns
%
% For examples, see <a href="http://www.sat.ltu.se/docs/datasets/collocations/collocations_atmlab.php">online help on the satpage</a>
%
% $Id$

%% prepare configuration things

no = number_sats_in_dataset(['collocation_' sensor1 '_' sensor2]);

cols = colloc_constants(['cols_' sensor1 '_' sensor2]);

if ~exist('filters', 'var')
    filters = {};
end

%% check legacy format
if iscell(cols_in{1})
    warning('atmlab:collocation_read', ...
        ['fields should be {''a'', ''b'', ''c'', ''d'', ...}, ' ...
         'not {{''a'', ''b'', ...}, {''c'', ''d'', ...}}']);
     cols_in = [cols_in{:}];
end

%% ALWAYS get rid of doubles
% FIXME: at some point in the future, this should be redundant
filters = [filters ...
    {{@colloc_select_good_lines, cols.overlap.filter_double{1}, {sat1, sensor1}}, ...
     {@colloc_select_good_lines, cols.overlap.filter_double{2}, {sat2, sensor2}}}];
% but only where filter_double has a value
filters(cellfun(@(c) isempty(c{2}), filters)) = [];
 
% make sure the fields are asked for
for c = horzcat(cols.overlap.filter_double{:})
    % cannot use union here, because it wants a cellstr :(
    if ~any(cellfun(@(d) isequal(c, d), cols_in))
        cols_in = [cols_in c]; %#ok<AGROW>
    end
end

%% get name_struct

n = 1; i = 1;
while i <= length(cols_in)
    if i<length(cols_in) && isnumeric(cols_in{i+1})
        dn = length(cols_in{i+1});
        di = 2;
    else
        dn = 1;
        di = 1;
    end
    name_struct.(cols_in{i}) = n:(n+dn-1);
    n = n + dn;
    i = i + di;
end
ncols = n-1;

%% convert limits structure to matrix as wanted by restrain_collocations

if exist('limits', 'var')
    limmat = limstruct2limmat(limits, name_struct);
else
    limmat = zeros(0, 3);
end

% for the filters, convert column names to column numbers, using the
% earlier obtained name_struct
if ~isempty(filters)
    for i = 1:length(filters)
        filters{i}{2} = cellfun(@(s) name_struct.(s)', filters{i}{2}, 'UniformOutput', false);
    end
end

%% pre-allocate at least zero rows

M = zeros(0, ncols);

%% loop through all the dates

dates = daterange(start_date, end_date);
for i = 1:size(dates, 1)
    date = dates(i, :);
    %% read collocations for date
    switch no
        case 1
            s = sat2;
        case 2
            s = {sat1, sat2};
    end
    path = find_datafile_by_date(date, s, ...
        ['collocation_' sensor1 '_' sensor2]);
    
    try
        collocations_day = read_collocs_data_mean(path, cols_in, cols);

    catch ME
        switch (ME.identifier)
            case {'MATLAB:load:couldNotReadFile', 'MATLAB:nonExistentField', ...
                    'MATLAB:gunzip:invalidFilename'}
                logtext(atmlab('ERR'), 'Problem for %04d-%02d-%02d: %s\n', ...
                    date(1), date(2), date(3), ME.message);
                continue
            otherwise
                ME.rethrow();
        end
    end
    if isempty(collocations_day)
        logtext(atmlab('OUT'), 'no collocations\n');
        continue
    end
    
    %% apply limitations
    lim = collocation_restrain(collocations_day, limmat, filters);
    collocations_day = collocations_day(lim, :);
    
    %% add to total
    L = size(M, 1);
    N = size(collocations_day, 1);
    M((L+1):(L+N), :) = collocations_day;
end

cols_out = name_struct;
