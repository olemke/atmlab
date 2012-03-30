function S = common_read_cpr(file, varargin)

% COMMON_READ_CPR read CloudSat CPR data in the common format (see README)
%
% This file reads data from a CloudSat CPR file and rearranges the fields to
% the common format.
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
%
% $Id$
% Gerrit Holl

core_fields = {'Longitude'; 'Latitude'; 'UTC_start'; 'Profile_time'; 'product_version'};
extra_fields = optargs(varargin, {{}});
all_fields = [core_fields; extra_fields];
S = cloudsat_read_zipped(file, all_fields);

% rename some fields
S.lon = double(S.Longitude(:));
S.lat = double(S.Latitude(:));
% construct time axis with same dimensions. Must convert to double because
% otherwise unixsecstodate will give the wrong time.
S.time = double( S.UTC_start + S.Profile_time);

% get epoch
x = datasets_config('cpr');
info = x.find_info_from_granule(file);
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

end