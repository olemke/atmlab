function S = colloc_read_cpr(file)

% colloc_read_cpr Read CloudSat CPR data for collocating
%
% This file reads data from a CloudSat CPR file and rearranges the fields to
% the format that collocate_granule and colloc_process_* use to respectively
% collocate or acquire information. The result is a structure that has at
% least 'time', 'lat' and 'lon'.
%
% Compare: colloc_read_poes_radiometer
%
% FORMAT
%
%   data = colloc_read_cpr(file)
%
% IN
%
%   file    string  Path to zipped CPR file
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
% $Id$

S = cloudsat_read_zipped(file, ...
    {'Longitude', 'Latitude', 'UTC_start', 'Profile_time', ...
     'RO_ice_water_path', 'RO_ice_water_path_uncertainty', ...
     'IO_RO_ice_water_path', 'IO_RO_ice_water_path_uncertainty', ...
     'product_version'});
% construct time axis with same dimensions
S.time = S.UTC_start + S.Profile_time;

% rename some fields

S.lon = S.Longitude;
S.lat = S.Latitude;
S.version = S.product_version;

% add filename

S.path = file;

% remove redundant fields
S = rmfield(S, {'Longitude', 'Latitude', 'UTC_start', 'Profile_time', 'product_version'});
