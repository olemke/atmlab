function [S,attr] = common_read_mspps(file, varargin)

% common_read_mspps Read mspps data in the common format
%
% This file reads data from a mspps file and rearranges the fields to
% the common format.
%
%
% IN
%
%   file    string      Path to hdf-file
%   extra   cell array (optional) extra fields.
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%                   fields  and what ever extra fields you wanted
%
%   attr    struct  empty
%
% FORMAT
%
%   [S,attr] = common_read_mspps(file, varargin)
%
% $Id$

%% INFORMATION
% Time : (TAI93) Number of seconds and fractions since 0000 Jan. 1, 1993

core_fields = {'Latitude','Longitude','Time'};
extra_fields = optargs(varargin, {{}});
all_fields = [core_fields(:); extra_fields(:)];

% read both ascending and descending files. Get the attributes incase
% wanted
if nargout == 2
    disp('There are no attributes associated with MSPPS data')
    attr = [];
end

for F = all_fields'
    try
    S.(F{1}) = hdfread(file,F{1});
    catch ME
        if any(strcmp(ME.identifier,{'MATLAB:imagesci:hdfquickinfo:invalidFile'}))
            error('atmlab:invalid_data','%s:%s found in %s hdfread call',...
                ME.identifier,ME.message,mfilename)
        else
            error(ME.identifier,Me.message)
        end
    end
end

%% RENAME some fields

% get epoch. 
% 
info =  find_info_from_granule('mspps', file);
thisday = date2unixsecs(str2double(info.year), str2double(info.month), str2double(info.day));
S.epoch = round(thisday);

% See information below header to make sense of this
S.time = S.Time{1}(:)-( thisday-date2unixsecs(1993,1,1) );
% I will only use the midway value for the core
% 

S.lon = double(S.Longitude);
S.lat = double(S.Latitude);
S.version = 'unknown';
S = rmfield(S,core_fields);

% add filename
S.path = file;

end
