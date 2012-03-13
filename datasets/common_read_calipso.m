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

% Do some hard-coded special operations for some fields, since atleast I
% WANT ONLY ONE COLUMN INTEGRATED VALUE for the entire column.
layeredFields = {'Ice_Water_Path'};
Fns = fieldnames(S);
if ~all(~ismember(Fns,layeredFields))
    suchFields = Fns(ismember(Fns,layeredFields));
    for F = suchFields
        S = columnIntergrateColumns(S,F{1});
    end
end

%% RENAME some fields

% get epoch. 
% 
info =  structfun(@str2double,find_info_from_granule('calipso', file));
S.epoch = round(date2unixsecs(info(1), info(2), info(3)));

% See information below header to make sense of this
yymmdd = str2double(sprintf('%2.0f%02.0f%02.0f',info(1)-2000,info(2),info(3)));
S.time = (S.Profile_UTC_Time(:,2)-yymmdd) * (24*3600);

% I will only use the midway value for the core
% 

S.lon = double(S.Longitude(:,2));
S.lat = double(S.Latitude(:,2));
S.version = 'version 3 (hardcoded)';
S = rmfield(S,core_fields);

% add filename
S.path = file;



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
    [~,test] = exec_system_cmd(sprintf('gunzip -c %s > %s',file,filename),1,true);
    
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

function S = columnIntergrateColumns(S,field)
%% columnIntergrateColumns
%
% Purpose: Special function to add the column itergrated values (not
% volumemetric) together into value per profile. 
%
% Note: The field ExtinctionQC_532 should be manditory or is at least
% highly recommended if looking at products based on the extinction such as
% IWP is
%

switch field
    case 'Ice_Water_Path'
        if isfield(S,'ExtinctionQC_532')
            S.(field)(S.ExtinctionQC_532~=0)=NaN;
        else
            warning(['atmlab:' mfilename ':Recomendation'],...
                'Not including field ExtinctionQC_532 is not recommended by the Calipso people')
        end
        % I'm assuming here that -9999 means cloud free?
        S.(field)(S.(field)<0)= 0;
        % Do the sum here
        S.(field) = nansum(S.(field),2);   
    otherwise
end


end


