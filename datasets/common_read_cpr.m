function S = common_read_cpr(file, varargin)

% COMMON_READ_CPR reads cloudsat data
%
% Read CloudSat data and output the data in the format common to all
% common_read_<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
%
%
% FORMAT
%
%   S = common_read_cpr(file,varargin)
%
% IN
%
%   file    string      Path to zipped CPR file
%   extra   cell array (optional) extra fields.
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat

% $Id$
% Gerrit Holl

core_fields = {'Longitude'; 'Latitude'; 'UTC_start'; 'Profile_time'; 'product_version'};
extra_fields = optargs(varargin, {{}});
all_fields = [core_fields(:); extra_fields(:)];

S = read_cloudsat_hdf(file, all_fields);

% rename some fields
S.lon = double(S.Longitude);
S.lat = double(S.Latitude);
% construct time axis with same dimensions. Must convert to double because
% otherwise unixsecstodate will give the wrong time.
S.time = double( S.UTC_start + S.Profile_time);

% get epoch
D = datasets;
info = D.cpr.find_info_from_granule(file);
date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
S.epoch = round(date2unixsecs(date.year, date.month, date.day));

S.path = file;
S.version = S.product_version;

% remove redundant fields
S = rmfield(S,core_fields);

% convert 1-D fields into column vectors. This is required for processing.
flds = fieldnames(S);
for i = 1:length(flds)
    fld = flds{i};
    if isvector(S.(fld))
        S.(fld) = S.(fld)(:);
    end
end

S = MaskInvalidGeoTimedataWithNaN(S);

end

