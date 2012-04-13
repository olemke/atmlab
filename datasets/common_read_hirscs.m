function data = common_read_hirscs(file)

% common_read_hirscs Read HIRSCS data in the common format (see README)
%
% This file reads data from a HIRSCS radiometer file and rearranges the
% fields to the common format. See README.
%
% FORMAT
%
%   data = common_read_hirscs(file)
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
    newfile = tempname(atmlab('WORK_AREA'));
    exec_system_cmd(['gunzip -c ' file '>' newfile]); % 3x faster than ML gunzip
    file = newfile;
%    filenames = gunzip(file, '/tmp');
%    file = filenames{1};
end

ncid = netcdf.open(file, 'NC_NOWRITE');

if isgzipped % remove gunzipped file
    delete(file);
end

[~, nvars] = netcdf.inq(ncid);
for i = 0:nvars-1
    nm = netcdf.inqVar(ncid, i);
    data.(nm) = netcdf.getVar(ncid, i, 'double');
end
netcdf.close(ncid);

% wrap longitudes

data.lon = wrapTo180(data.lon);

% rotate bt, lc

data.bt = data.bt.';
data.lc = data.lc.';

% compensate time wrapping around

data.time = compensate_wraparound(data.time);

% get rid of doubles. FIXME: use scanline numbers

[~, I] = unique([data.time data.lat data.lon], 'rows');
allfields = fieldnames(data);
for i = 1:length(allfields);
    field = allfields{i};
    data.(field) = data.(field)(I, :);
end
