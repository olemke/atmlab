function [M, paths] = find_granules_by_date(year, month, day, sat, sensor, ...
    with_yesterday)

% find_granules_by_date Find all granule start times for date/sat/sensor
%
% This function finds all granule start times for granules with any coverage
% for the the indicated for the indicated satellite/sensor pair. This
% includes the last granule of the date before, unless this is explicitly
% prohibited. Note that the last granule of the date before may or may not
% actually contain information for the day requested. Also notethat there may
% also be more than one granule on the date before containing information
% for the day requested. This is not currently taken into account.
%
% FORMAT
%
%   [M, paths] = find_granules_by_date(year, month, day, sat, sensor, with_yesterday)
%
% OUT
%
%   M     N x m matrix     where each row corresponds to one granule and is
%                          a datevec.
%   paths cell strings     Cell array of strings, corresponding full paths
%
% IN
%
%  year             (numeric)  Year for which to find the times.
%  month            (numeric)  Month for which to find the times.
%  day              (numeric)  Day for which to find the times.
%  sat              string     Describing the satellite.
%  sensor           string     Describing the sensor.
%  with_yesterday   bool       Include last of yesterday (defaults to true)
%
% For POES satellites (NOAA-15 – NOAA-19 and MetOp-A), AMSU, MHS, HIRS and
% AVHRR have the same granule times.
% 
% The supported sensors are those that have a _basedir defined in
% colloc_config. As of 5 October 2010, those are:
%
%
% cpr amsua amsub mhs hirs mspps avhrr hirscs collocation_cpr_poes collocation_poes_poes collocation_cpr_avhrr collocation_hirscs_poes collocation_collocation_cpr_poes_avhrr
%
% Satellite is only required for those sensors existing on multiple
% satellites (where _yeardir in colloc_config contains $SAT). This is
% currently (5 October 2010) true for:
%
% amsua amsub mhs hirs mspps avhrr
%
% $Id$

if ~exist('with_yesterday', 'var')
    with_yesterday = true;
end

% verify basedir is defined and exists

try
    basedir = colloc_config([sensor '_basedir']);
catch ME
    switch ME.identifier
        case 'atmlab:prstnt_struct:undefined'
            error('atmlab:find_granules_by_date', ...
                'No basedir defined for %s, please define basedir_%s.', ...
                sensor, sensor);
        otherwise
            ME.rethrow();
    end
end
assert(exist(basedir, 'dir')~=0, 'atmlab:find_granules_by_date', ...
        ['Configured data directory for %s is %s, ' ...
         'but this does not exist or is not a directory. ' ...
         'Please define basedir_%s correctly.'], ...
         sensor, basedir, sensor);

yeardir = colloc_config([sensor '_yeardir']);
yeardir = strrep(yeardir, '$YEAR', num2str(year));
yeardir = strrep(yeardir, '$SAT', sat);
if isempty(yeardir) % assume only one (see note in README)
    M = [year month day 0 0];
    return;
end
try
    matchy = colloc_config([sensor '_regexp']);
catch ME
    switch ME.identifier
        case 'atmlab:prstnt_struct:undefined'
            % give up without regexp
            M = [year month day 0 0];
            return
        otherwise
            ME.rethrow();
    end
end

datadir = fullfile(basedir, yeardir, num2str(month, '%02d'), num2str(day, '%02d'));

files = dir(datadir);
nfiles = length(files);
M = zeros(nfiles, 5);
for i = 1:nfiles
    fname = files(i).name;
    nam = regexp(fname, matchy, 'names');
    if ~isempty(nam)      
        M(i, 1:3) = [year month day];
        if isfield(nam, 'hour')
            M(i, 4) = str2double(nam.hour);
        end
        if isfield(nam, 'minute')
            M(i, 5) = str2double(nam.minute);
        end
    end
end
% all paths
paths = cellfun(@(f) fullfile(datadir, f), {files.name}, 'UniformOutput', false);
% remove lines with zeroes (those are not granules)
nogran = M(:, 1)==0;
M(nogran, :) = [];
paths(nogran) = [];
% sort
M = sortrows(M);
% add yesterday
if with_yesterday
    yesterday = datevec(datenum([year month day])-1);
    [M_yesterday, paths_yesterday] = find_granules_by_date(...
        yesterday(1), yesterday(2), yesterday(3), sat, sensor, false);
    if ~isempty(M_yesterday) % maybe today is genesis/big bang/epoch/birth/1970-01-01
        M = [M_yesterday(end, :); M];
        paths = [paths_yesterday(end) paths];
    end
end
