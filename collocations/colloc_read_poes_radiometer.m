function data = colloc_read_poes_radiometer(file)

% colloc_read_poes_radiometer Read POES data for collocating
%
% This file reads data from a POES l1b radiometer file and rearranges the
% fields to the format that collocate_granule and colloc_process_* use to
% respectively collocate or acquire information. The result is a structure
% that has at least 'time', 'lat' and 'lon'.
%
% Note: colloc_config has several aliases for this, including read_amsua,
% read_amsub, read_mhs and read_hirs.
%
% FORMAT
%
%   data = colloc_read_poes_radiometer(file)
%
% IN
%
%   file    string  Path to l1b file
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

% shift dimensions so that it's [row col (channel)]

data.lat = shiftdim(data.lat, 1);
data.lon = shiftdim(data.lon, 1);
data.tb = shiftdim(data.tb, 2);

% add filename and version

data.path = file;
data.version = '0'; % dunno