function M = find_granules_by_date(year, month, day, sat, sensor)

% find_granules_by_date Find all granule start times for date/sat/sensor
%
% This function finds all granule start times for the indicated
% date and satellite
%
% FORMAT
%
%   M = find_granules_by_date(year, month, day, sat)
%
% OUT
%
%   M     N x m matrix     where each row corresponds to one granule and is
%                          a datevec.
%
% IN
%
%  year     (numeric)  Year for which to find the times.
%  month    (numeric)  Month for which to find the times.
%  day      (numeric)  Day for which to find the times.
%  sat      string     Describing the satellite.
%  sensor   string     Describing the sensor.
%
% For POES satellites (NOAA-15 – NOAA-19 and MetOp-A), AMSU, MHS, HIRS and
% AVHRR have the same granule times.
%
% $Id$

% TODO: add code to locate collocation files here

basedir = colloc_config([sensor '_basedir']);
yeardir = colloc_config([sensor '_yeardir']);
yeardir = strrep(yeardir, '$YEAR', num2str(year));
yeardir = strrep(yeardir, '$SAT', sat);
matchy = colloc_config([sensor '_regexp']);

datadir = fullfile(basedir, yeardir, num2str(month, '%02d'), num2str(day, '%02d'));

files = dir(datadir);
nfiles = length(files);
M = zeros(nfiles, 5);
for i = 1:nfiles
    fname = files(i).name;
    nam = regexp(fname, matchy, 'names');
    if ~isempty(nam)
        M(i, :) = [year month day str2double(nam.hour) str2double(nam.minute)];
    end
end
% remove lines with zeroes
M(M(:, 1)==0, :) = [];
