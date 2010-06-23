function data = colloc_read_hirscs(file)

% colloc_read_hirscs Read HIRSCS data for collocating
%
% This file reads data from a HIRSCS radiometer file and rearranges the
% fields to the format that collocate_granule and colloc_process_* use to
% respectively collocate or acquire information. The result is a structure
% that has at least 'time', 'lat' and 'lon'.
%
% FORMAT
%
%   data = colloc_read_hirscs(file)
%
% IN
%
%   file        string      Path to l1b file
%   channels    vector      vector of channels to read (defaults to 1:5)
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees
%                   lon     longitude in [-180, 180] degrees
%
% $Id$

isgzipped = strcmp(file(end-2:end), '.gz');

if isgzipped % gunzip first
    filenames = gunzip(file, '/tmp');
    file = filenames{1};
end

ncid = netcdf.open(file, 'NC_NOWRITE');

if isgzipped % remove gunzipped file
    delete(file);
end

[~, nvars] = netcdf.inq(ncid);
for i = 0:nvars-1
    nm = netcdf.inqVar(ncid, i);
    data.(nm) = netcdf.getVar(ncid, i);
end
netcdf.close(ncid);

% wrap longitudes

data.lon = wrapTo180(data.lon);

% compensate time wrapping around

data.time = compensate_wraparound(data.time);