function [data,lat,lon] = binning_fast(in,lonspace)
%% BINNING_FAST bins ungridded data onto a grid 
%
% Purpose:
% Bins ungridded data to a cell grid using d = in.gridsize. Each bin will contain a
% vector of values for that bin.
%
% The structure elements lat,lon,data must be the same size, and the function
% will preserve the variable types.
%
% In:
%       
%       1)  in (mandatory):
%               structure containing 
%               i)   data
%               ii)  lat
%               iii) lon
%               iv)  gridsize
%               v)   region (optional)
%                    region = [blcorner,trcorner] (lt1,ln1,lt2,ln2)
%       
%          If region is given, the function will only bin the data within the
%          given region. Particularily useful if you have high resolution data
%          in a region. The default grid domain is assumed to be global
%          otherwise.
%
%       2)  lonspace (optional):
%           indicates the longitude format
%           lonspace = 360 for lon=0:360,
%           lonspace = 180 for lon=-180:180
%           lonspace = 0 do nothing (default)
%
%           If flag is not given, the function automatically picks a format
%           which depends on if there is a longitude value larger than 180 (lon>180)
%           or not. This may be important if your input data does not cover both
%           hemispheres.
%
% Out:
%                   1) data ( cell )
%                   2) lat  ( vector )
%                   3) lon  ( vector )
%
% 2010-05-26 Salomon Eliasson

d = in.gridsize;
if nargin==1, lonspace=0;end

[in,lat,lon] = outputlatlons(in,d,lonspace);

in = regionchop(in);    

%% assign index value
lonindex = floor( (in.lon - (min(lon)-d/2)) /d ) + 1;
latindex = floor( (in.lat - (min(lat)-d/2)) /d ) + 1;                                         
% make sure lonindex and latindex don't exceed maximum
lonindex(lonindex>length(lon))=length(lon);
latindex(latindex>length(lat))=length(lat);

indata = in.data(:);
%% GET COUNTS
data = cell(length(lat), length(lon));
counts = zeros (size(data), class(indata));
for i = 1:length(indata)                                                        
    ilon = lonindex(i);
    ilat = latindex(i);
    counts(ilat, ilon) = counts(ilat, ilon) + 1;
end

%% PREALLOCATE DATA
for i = 1:size(counts,1)                                                        
    for j = 1:size(counts,2)
        data{i, j} = zeros (counts(i, j), 1, class(indata));
    end
end

%% LOOP DATA
for i = 1:length(indata)                                                        
    ilon = lonindex(i);
    ilat = latindex(i);
    data{ilat, ilon}(counts(ilat, ilon)) = indata(i);
    counts(ilat, ilon) = counts(ilat, ilon) - 1;
end


%% Subfunctions
% ||
% VV

function in = regionchop(in)                                                    %% regionchop
% Get rid of all data outside of region

lt1 = in.lat > in.region(1);
ln1 = in.lon > in.region(2);
lt2 = in.lat < in.region(3);
ln2 = in.lon < in.region(4);

index = ln1 & ln2 & lt1 & lt2;

in.lat = in.lat(index);
in.lon = in.lon(index);
in.data = in.data(index);

function [in,lat,lon] = outputlatlons(in,d,lonspace)                            %% outputlatlons %%
%% fix the latlons
% Sets up lat lon and adjusts in.lon to the requested (if requested)
% longitude regime (0:360 or -180:180)
%

testmore = in.lon>180; %logical for any lons > 180
testless = in.lon<0; %logical for any lons < 0

if lonspace==360
    in.lon(testless) = in.lon(testless)+360;
    in.f360=true;
elseif lonspace==180
    in.lon(testmore) = in.lon(testmore)-360;
    in.f360=false;
elseif lonspace==0
    in.f360 = any(testmore(:));
else error('lonspace must be 180, 360 or 0 (default (do nothing))')
end

if in.f360 && ~isfield(in,'region')
    in.region = [-90 0 90 360]; 
elseif ~in.f360 && ~isfield(in,'region')
    in.region = [-90 -180 90 180]; 
end
    
lon = in.region(2)+0.5*d:d:in.region(4)-0.5*d;
lat = in.region(1)+0.5*d:d:in.region(3)-0.5*d;