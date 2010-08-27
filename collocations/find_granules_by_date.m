function M = find_granules_by_date(year, month, day, sat, sensor, ...
    with_yesterday)

% find_granules_by_date Find all granule start times for date/sat/sensor
%
% This function finds all granule start times for granules with any coverage
% for the the indicated for the indicated satellite/sensor pair. This
% includes the last granule of the date before, unless this is explicitly
% prohibited.
%
% FORMAT
%
%   M = find_granules_by_date(year, month, day, sat, sensor, with_yesterday)
%
% OUT
%
%   M     N x m matrix     where each row corresponds to one granule and is
%                          a datevec.
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
% $Id$

if ~exist('with_yesterday', 'var')
    with_yesterday = true;
end

% TODO: add code to locate collocation files here

basedir = colloc_config([sensor '_basedir']);
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
% add yesterday
if with_yesterday
    yesterday = datevec(datenum([year month day])-1);
    M_yesterday = find_granules_by_date(yesterday(1), yesterday(2), yesterday(3), ...
        sat, sensor, false);
    if ~isempty(M_yesterday) % maybe today is genesis/big bang/epoch/birth/1970-01-01
        M = [M_yesterday(end, :); M];
    end
end
% remove lines with zeroes
M(M(:, 1)==0, :) = [];
% sort
M = sortrows(M);