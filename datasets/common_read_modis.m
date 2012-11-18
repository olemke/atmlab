function S = common_read_modis(file, varargin)

% COMMON_READ_MODIS reads modis data
%
% Read MODIS data and output the data in the format common to all
% common_read_<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
%
%
% IN
%
%   file    string      Path to hdf file
%   extra   cell array (optional) extra fields.
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
% FORMAT
%
%   S = common_read_modis(file, varargin)

% $Id$
% Created by Salomon Eliasson

core_fields   = {'Scan_Start_Time','Latitude','Longitude'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];
% List of hand-made fields that can be composed already here to save memory and
% storage space. I call them "pseudo fields" (e.g. modis_IWP that depends on 3
% fields in the modis file). The loop of hdfread will check if any psudeo fields
% are present. If so, it will be processed and the fields this pseudo field
% requires to be created are further assumed to be frivolous and therefore
% removed afterwards.
pseudo_fields = {'modis_IWP','Tau_ice','Re_ice'};

for F = all_fields'
    if ismember(F{1},pseudo_fields)
        continue
    end
    S.(F{1}) = hdfread(file,F{1});
end

% Geodata and time need interpolating to make them the same size as the rest of
% the data
S = interpolate_geodataTime(S);

% CONSTRUCT time axis with same dimensions

S.lat = double(S.Latitude);
S.lon = double(S.Longitude);

% get the verion directly from the filename
D = datasets;
info = D.modis_aqua_L2.find_info_from_granule(file);
date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
S.epoch = round(date2unixsecs(date.year, date.month, date.day));

if any(ismember(pseudo_fields,extra_fields))
    S = dealWithPseudoFields(S, pseudo_fields(ismember(pseudo_fields,extra_fields)),file);
end

%I need to do this after flagging, or the dimensions will be wrong.
% data starts at 1993, I need an offset. Only need one time per scan line
%(first 4 are NaN due to interpolation)
S.time = S.Scan_Start_Time(:,5) + date2unixsecs(1993) -S.epoch;

S = rmfield(S,core_fields);

S.version = info.version;
S.path = file;

S = MaskInvalidGeoTimedataWithNaN(S);

end
%%%%%%%%%%%%%
% SUBFUNCTION

function S = dealWithPseudoFields(S,fields,file)
%% dealWithPseudoFields
%
% List of hand-made fields that can be composed already here to save memory
% and storage space. Will check in the loop if this field is present. The
% fields the pseudo fields required are further assumed to be frivolous and therefore
% removed afterwards. This part is hardcoded

% READ dependent fields
% So far this function assumesa you always need cloud phase and quality
% flag
common_fields = {'Quality_Assurance_1km','Cloud_Phase_Optical_Properties'};
associatedFields = {'Cloud_Water_Path','Cloud_Effective_Radius','Cloud_Optical_Thickness'};
pseudo_fields = {'modis_IWP','Tau_ice','Re_ice'};
dependent_fields = [common_fields,associatedFields(ismember(pseudo_fields,fields))];

% remove dependent fields if they aren't already in S (see the end of this function)
rmflag = ~ismember(dependent_fields,fieldnames(S));

for D = dependent_fields
    S.(D{1}) = hdfread(file,D{1});
end

%% From here I assume the following exist  {'Quality_Assurance_1km','Cloud_Phase_Optical_Properties'};
% use dependent fields to BUILD the pseudo fields
sz = size(S.(dependent_fields{1}));

% Keeping record of the pixels that are deemed to be cloud free
clearPixel = S.Cloud_Phase_Optical_Properties==1;

% Removing all points that are not flagged as ice clouds
icePhase = S.Cloud_Phase_Optical_Properties==3;

% only KEEP retrievals that are USEFUL and CONFIDENT

% this corresponds to the 1st and 2nd bit in the 2nd byte in
% Quality_Assurance_1km (regarding cloud_water_path. I assume the
% same apply to Re and Tau that CWP is based on anyway). By doing this
% I'm also disregarding values with marginal confidence
usefull=uint8(sum(2.^[0,1]));

% bitand only works on vectors
S.Quality_Assurance_1km = permute(S.Quality_Assurance_1km,[3,1,2]);

flaggedAsGood = bitand(typecast(S.Quality_Assurance_1km(2,:),'uint8'),usefull)==usefull;
flaggedAsGood = reshape(flaggedAsGood,sz(1),sz(2));
% mask all non applicable data with NaN


% This will only work if the pseudoField is one of the 3 above
for F = fieldnames(S)'
    % mask non-ice or bad data with Nans
    if isequal(size(S.(F{1})),size(clearPixel))
        % zero that which has no clouds
        if any(strcmp(F{1},{'Cloud_Water_Path','Cloud_Effective_Radius','Cloud_Optical_Thickness'}))
            S.(F{1})(clearPixel)=0;
        end
        S.(F{1})(~(clearPixel | (icePhase & flaggedAsGood)))=NaN;
    end
end

for F = fields
    switch F{1}
        case 'modis_IWP'
            S.modis_IWP = S.Cloud_Water_Path;
        case 'Re_ice'
            S.Re_ice = S.Cloud_Effective_Radius;
        case 'Tau_ice'
            S.Tau_ice = S.Cloud_Optical_Thickness;
    end
end

% re
S=rmfield(S,dependent_fields(rmflag));

end

function S = interpolate_geodataTime(S)

% NOTE: Latitude and Longitudes must be interpolated to the right
% dimensions. This is tested to be accurate compared to the MYD03 full
% geodata to within 1e-4 degrees. The alternative is to download the MYD03
% dataset, but that is about 3TB per year.
%
% NOTE: This will destroy all data outside the bounds of the sampled data!
%
% Warning: Slight dodgyness
%
% - I am using 'linear' interpolation on a geoid.
% - When LONGITUDES contain lon < -175 & lon > 175 the satellite clearly
%   passes the  dateline. For such swaths I temporarily switch to 0:360
%   representation, interpolate, and then switch back to -180:180
%   representation.
% - The incorrect interpolation of LATITUDES if the modis passes the poles is deemed
%   small and ignored here since the sampled footprints are about 5km
%   apart. e.g. in the worst case (for this footprint resolution):
%   [89.95 89.95] is interpolated to [89.95 89.95 89.95 89.95 89.95]
%   instead of [89.95 89.98 90 89.98 89.95]
%

% Use the sampling as described in variable documentation
%Longitude:Cell_Along_Swath_Sampling = 3, 2028, 5 ;
%Longitude:Cell_Across_Swath_Sampling = 3, 1348, 5 ;


[X,Y]   = meshgrid(3:5:size(S.Scan_Start_Time,2)*5-2,3:5:size(S.Scan_Start_Time,1)*5-2);
[Xi,Yi] = meshgrid(1:1354,1:size(S.Scan_Start_Time,1)*5);

fields2DealWith = {'Latitude','Longitude','Scan_Start_Time'};

lonflag = false;
for F = fields2DealWith
    Z = S.(F{1});
    
    % dateline patch
    if strcmp(F{1},'Longitude')
        Z(Z<-180) = NaN; % get rid of fill values
        if any(Z(:)<-175 ) && any(Z(:)>175) % Fill = -999
            % CONVERT LONGITUDES to [0 360] regime if the dateline is crossed
            Z=Z+(Z < 0)*360;
            lonflag=true;
        end
    end
    
    S.(F{1}) = interp2(X,Y,Z,Xi,Yi);
    
    if strcmp(F{1},'Longitude') && lonflag
        S.(F{1}) = S.(F{1})-(S.(F{1}) > 180)*360;
    end
end

end
