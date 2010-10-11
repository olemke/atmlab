function data = common_read_collocation_cpr_mhs(file)

% common_read_collocation_cpr_mhs Read CPR/MHS collocation file
%
% Read a CPR/MHS collocation file and return things in the common format.
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
[data, attr] = loadncvar(gunzipped{1}, {'FIRST', 'B_LAT', 'B_LONG', 'B_TIME'});
delete(gunzipped{1});
data.info = cell2struct(...
    cellfun(@(v) v{2}, attr, 'UniformOutput', false), ...
    cellfun(@(v) v{1}, attr, 'UniformOutput', false), ...
    2);
data.version = ['colloc:' data.info.software_version ':' ...
    data.info.primary_version ':' data.info.secondary_version ':' ...
    data.info.date];

rows = data.FIRST;
data.lat = data.B_LAT(rows);
data.lon = data.B_LONG(rows);

[y, mo, d, h, mi, s] = unixsecs2date(double(data.B_TIME(rows)));
data.epoch = uint32(unique(date2unixsecs(y, mo, d)));
assert(isscalar(data.epoch), 'atmlab:common_read_collocation_cpr_mhs', ...
    'Data in %s appears to contain measurement from more than one day', ...
    file);
data.time = compensate_wraparound(3600*h + 60*mi + s);
data.file = file;

data = rmfield(data, {'FIRST', 'B_LAT', 'B_LONG', 'B_TIME'});