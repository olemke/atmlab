function data = common_read_collocation_cpr_mhs(file)

% common_read_collocation_cpr_mhs Read CPR/MHS collocation file
%
% Read a CPR/MHS collocation file and return things in the common format.
% Additionally, all data from the collocation file are included.
%
% IN
%
%   file        string      path to collocations file
%
% out
%
%   data        structure   data with time, lat, lon
%
%
% $Id$


gunzipped = gunzip(file, atmlab('WORK_AREA'));
data = loadncfile(gunzipped{1});
delete(gunzipped{1});
data.info = data.global_attributes;

data.version = ['colloc:' data.info.software_version ':' ...
    data.info.primary_version ':' data.info.secondary_version ':' ...
    data.info.date];

rows = data.FIRST;
data.lat = data.B_LAT(rows);
data.lon = data.B_LONG(rows);

% use C_TIME to calculate the epoch, but return B_TIME as we're working
% with meandata here
[y, mo, d, ~, ~, ~] = unixsecs2date(double(data.C_TIME(rows)));
data.epoch = round(unique(date2unixsecs(y, mo, d)));
assert(isempty(data.epoch)||isscalar(data.epoch), 'atmlab:common_read_collocation_cpr_mhs', ...
     'Data in %s appears to contain measurement from more than one day', ...
     file);
[~, ~, ~, h, mi, s] = unixsecs2date(double(data.B_TIME(rows)));

data.time = compensate_wraparound(3600*h + 60*mi + s);
data.file = file;
