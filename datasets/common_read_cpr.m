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
pseudo_fields = {'Cloud_Types'}; % pseudo fields that are not in the original data but are built
% on fields from the existing data fields

try 
    S = cloudsat_read_zipped(file, all_fields(~ismember(all_fields,pseudo_fields)));
catch ME
    if strcmp(ME.identifier,'atmlab:exec_system_cmd:shell')
       error('atmlab:invalid_data','problem executing system command:\n%s',ME.message)
    end
end    
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

% ---------
% pseudo fields (if any)
% ---------

if any(ismember(pseudo_fields,extra_fields))
    for P = pseudo_fields(:)'
        S = dealWithPseudoFields(S,P{1},file);
    end
end

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

function S = dealWithPseudoFields(S,field,file)
%% dealWithPseudoFields
%
% List of hand-made fields that can be composed already here (e.g. to save
% memory and storage space). The fields the pseudo fields required are
% further assumed to be frivolous and therefore removed afterwards, unless these
% fields were already read before this function.
%
% Cloud Types
% A condensed version of cloud scenario where the only single cloud types
% per profile are retrieved, i.e. if there are multiple cloudtypes in the
% same column, the cloudtype is called mixed Cloud Types = No cloud (0),
% Ci(1), As (2), Ac (3), St (4), Sc (5), Cu (6), Ns (7), DC (8), mixed (9).
% The flag definitions are given in Tab 5. of the version 5 CLDCLASS
% documentation


% --------------
% read dependent fields
% ---------------
switch field
    case 'Cloud_Types'
        tmp = cloudsat_read_zipped(file, {'cloud_scenario'});
end

% --------------
% Do operations
% --------------
switch field
    case 'Cloud_Types'
        
        % preallocate
        x.cloudy = false(size(tmp.cloud_scenario));
        x.Ci = x.cloudy; x.As = x.cloudy; x.Ac = x.cloudy;
        x.St = x.cloudy; x.Sc = x.cloudy; x.Cu = x.cloudy;
        x.Ns = x.cloudy; x.DC = x.cloudy;
        
        % -----------------------
        % extract clouds
        % -----------------------
        CS = sum(2.^(1:4)); %scenario mask
        Nprof = size(tmp.cloud_scenario,1);
        for i = 1:Nprof
            determined = bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),2^0)==2^0;
            x.cloudy(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)>0;
            x.Ci(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2;
            x.As(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^2;
            x.Ac(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^1+2^2;
            x.St(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^3;
            x.Sc(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^1+2^3;
            x.Cu(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^2+2^3;
            x.Ns(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^1+2^2+2^3;
            x.DC(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^4;
            
        end
        

        % -------------------------
        % Make logical true if all
        % clouds in profile are the same type
        % ------------------------
        
        cloudfree = ~any(x.cloudy,2);
        cloudTypes = {'Ci','As','Ac','St','Sc','Cu','Ns','DC'};
        for i = 1:length(cloudTypes)
            F = cloudTypes{i};
            % in profile: sum(cloudtype) = sum(cloudy vertical bins)
            singleType.(F) = sum(x.(F),2)==sum(x.cloudy,2);
            singleType.(F)(cloudfree) = false;
        end
        
        % mixed clouds is where the profile is not cloudfree nor does it contain only one cloud type (=9)
        S.Cloud_Types = (length(cloudTypes)+1)*ones(size(singleType.Ci),'int8'); 
        for i = 1:length(cloudTypes)
            F = cloudTypes{i};
            S.Cloud_Types(singleType.(F)) = i;
        end
        S.Cloud_Types(cloudfree) = 0;

end



end