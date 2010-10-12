function data = common_read_poes_radiometer(file)

% common_read_poes_radiometer Read POES data and arrange in the common format
%
% This file reads data from a POES l1b radiometer file and rearranges the
% fields to the common format. See README.
%
% FORMAT
%
%   data = common_read_poes_radiometer(file)
%
% IN
%
%   file    string  Path to l1b file. Must be FULL PATH!
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
% $Id$

data = atovs_get_l1c(file);

% convert time from milliseconds to seconds

data.time = data.time'/1000;

% compensate time wrapping around

data.time = compensate_wraparound(data.time);

% verify data integrity

assert(all(diff(data.time)>0), ...
    'atmlab:invalid_data', ...
    'POES time not monotonically increasing');

% shift dimensions so that it's [row col (channel)]

data.lat = shiftdim(data.lat, 1);
data.lon = shiftdim(data.lon, 1);
data.tb = shiftdim(data.tb, 2);

% add filename and version

data.path = file;
data.version = '0'; % dunno

% add epoch

info = find_info_from_granule('amsub', file); % amsua/amsub/mhs etc. all the same
data.epoch = round(date2unixsecs(str2double(info.year), str2double(info.month), ...
    str2double(info.day)));