function [S,attr] = common_read_calipso(file, varargin)

% common_read_calipso Read CALIPSO data in the common format
%
% This file reads data from a CALIPSO file and rearranges the fields to
% the common format.
%
%
% IN
%
%   file    string      Path to gzipped file
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
%   attr    struct  With associated attributes
%
% FORMAT
%
%   [S,attr] = common_read_calipso(file, varargin)
%
% $Id$

%% INFORMATION
%
% Latitude:      Three values are reported: the footprint latitude for the
%                first pulse included in the 15 shot average; the footprint
%                latitude for the final pulse; and the footprint latitude
%                at the temporal midpoint (i.e., at the 8th of 15
%                consecutive laser shots).
%
% Longitude:     -||-
%
% Profile_UTC_Time :  Time expressed in Coordinated Universal Time (UTC),
%                     and formatted as 'yymmdd.ffffffff', where 'yy'
%                     represents the last two digits of year, 'mm' and 'dd'
%                     represent month and day, respectively, and 'ffffffff'
%                     is the fractional part of the day. For the 5 km
%                     layerproducts, three values are reported: the time
%                     for the first pulse included in the 15 shot average;
%                     the time for the final pulse; and the time at the
%                     temporal midpoint (i.e., at the 8th of 15 consecutive
%                     laser shots).
%
% ExtinctionQC_532: 0 is recommended for proper retrievals
%
% Ice_Water_Path: has 10 values. pressumably allowing for up to 10 clouds
%
core_fields = {'Latitude','Longitude','Profile_UTC_Time'};
extra_fields = optargs(varargin, {{}});
all_fields = [core_fields(:); extra_fields(:)];

% read both ascending and descending files. Get the attributes incase
% wanted
if nargout == 2
    [S,attr] = gunzip_and_read_calipso(file,all_fields);
else
    S = gunzip_and_read_calipso(file,all_fields);
end

%% RENAME some fields

% get epoch. 
% 
x = datasets_config('calipso');
info =  x.find_info_from_granule(file);
s2d = @str2double;

% See information below header to make sense of this
yymmdd = s2d(sprintf('%2.0f%02.0f%02.0f',s2d(info.year)-2000,s2d(info.month),s2d(info.day)));

% I will only use the midway value for the core
% 
S.lon = double(S.Longitude(:,2));
S.lat = double(S.Latitude(:,2));
S.time = (S.Profile_UTC_Time(:,2)-yymmdd) * (24*3600);
S.epoch = round(date2unixsecs(s2d(info.year), s2d(info.month), s2d(info.day)));
S.path = file;
S.version = '051 (hardcoded)';

S = rmfield(S,core_fields);

end
%%%%%%%%%%%%%
% SUBFUNCTION

function [S,attr] = gunzip_and_read_calipso(file,all_fields)


% make TEMPDIR & cleanup after I'm done.
if strcmp(file(end-2:end),'.gz')
    tmpdir = create_tmpfolder();
    cleanupObject = onCleanup(@() delete_tmpfolder(tmpdir));
    
    [~,tmpfile] = fileparts(file);
    filename = fullfile(tmpdir,tmpfile);
    [~,test] = exec_system_cmd(sprintf('gunzip -c %s > %s',file,filename),false,true);
    
    if logical(test)
        error(['atmlab:' mfilename ':file'],'error gunzipping\n%s',file)
    end
elseif strcmp(file(end-3:end),'.hdf')
    filename = file;
end
% read the data. This also scales the data automatically!
for F = all_fields'
    if nargout==2
        info = hdfinfo(filename,'hdf');
        index = ismember({info.SDS.Name},F{1});
        attr.(F{1}) = info.SDS(index).Attributes;
    end
    S.(F{1})  = hdfread(filename,F{1});
end

end