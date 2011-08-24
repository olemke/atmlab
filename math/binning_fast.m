function [data,lat,lon] = binning_fast(in,lonspace)
%% BINNING_FAST bins ungridded data onto a grid
%
% Purpose:
% Bins ungridded data to a cell grid using d = in.gridsize. Each bin will contain a
% vector of values for that bin.
%
% The structure elements lat,lon,data must be the same size, and the function
% will preserve the variable class.
%
% IN
%   in       struct containing:
%               MANDITORY:
%                   data         [data matrix]     of any class. size(data,1)
%                                                  must be the same length
%                                                  as lat lon, but data may
%                                                  have 2 dimensions or more, e.g.
%                                                  lvls, seasons, etc.
%                   lat          [lat vector]      of any class
%                   lon          [lon vector]      of any class
%
%                 either:
%                   gridsize     [%f] or [%f %f]   scalar for square
%                                                       scaling. 2 values
%                                                       if you want to have
%                                                       separate lat,lon
%                                                       resolutions
%
%
%
%                             or
%                  newlat        [lat vector]      bin into new lat grid
%                  newlon        [lat vector]      bin into new lon grid
%
%              OPTIONAL
%                  region        [blcorner,trcorner] (lt1,ln1,lt2,ln2)
%
%
%          If region is given, the function will only bin the data within the
%          given region. Particularily useful if you have high resolution data
%          in a region. The default grid domain is assumed to be global
%          otherwise.
%
%  lonspace    %f     Optional to indicate the longitude format
%                     lonspace = 360 for lon=0:360,
%                     lonspace = 180 for lon=-180:180
%                     lonspace = 0 do nothing (default)
%
%           If lonspace is not given, the function automatically picks a format
%           which depends on if there is a longitude value larger than 180 (lon>180)
%           or not. This may be important if your input data does not cover both
%           hemispheres.
%
% Out:
%                   1) data ( cell )
%                   2) lat  ( vector )
%                   3) lon  ( vector )
%
% USAGE: [data,lat,lon] = binning_fast(in,lonspace) %lonspace is optional
%
% NOTE:
%       1) Including newlon and newlat causes the function to ignore: in.gridsize
%                                                                    in.region
%                                                                    lonspace
%
%       2) A useful function to get statistics (e.g numel, mean, sum, etc) on
%       the binned data is binned_statistics.
%
%
% Created by Oliver Lemke and Salomon Eliasson
% $Id$

in = check_input(in);

if nargin==1, lonspace=0;end
[in,lat,lon] = outputlatlons(in,lonspace);

% data might be 2D or more e.g. levels,etc
sz = size(in.data);
in.data = in.data(:,:); %collapse data

in = regionchop(in);

% setup new GRIDSIZE
d(1) = lat(2)-lat(1);
d(2) = lon(2)-lon(1);

%% assign index value
latindex = floor( (in.lat - (min(lat)-d(1)/2)) /d(1) ) + 1;
lonindex = floor( (in.lon - (min(lon)-d(2)/2)) /d(2) ) + 1;

% make sure lonindex and latindex don't exceed maximum
latindex(latindex>length(lat))=length(lat);
lonindex(lonindex>length(lon))=length(lon);
indata = in.data;

%% GET COUNTS
data = cell(length(lat), length(lon));
counts = zeros (size(data), class(indata));
for i = 1:size(indata,1)
    ilat = latindex(i);
    ilon = lonindex(i);
    counts(ilat, ilon) = counts(ilat, ilon) + 1;
end

%% PREALLOCATE DATA
for i = 1:size(counts,1)
    for j = 1:size(counts,2)
        data{i, j} = zeros ([counts(i, j), sz(2:end)], class(indata));
    end
end

%% LOOP DATA
for i = 1:size(indata,1)
    ilat = latindex(i);
    ilon = lonindex(i);
    data{ilat, ilon}(counts(ilat, ilon),:) = indata(i,:);
    counts(ilat, ilon) = counts(ilat, ilon) - 1;
end

%% Subfunctions
% ||
% VV

function in = check_input(in)

errId = 'atmlab:binning_fast:badInput';
assert(all(isfield(in,{'lat','lon','data'})),...
    errId,'''lat'',''lon'',''data'' are required input fields')

assert(isfield(in,'gridsize') || (all(isfield(in,{'newlon','newlat'}))),...
    errId,'Either field ''gridsize'' or fields ''newlat'' and ''newlon'' are required' )

if isequal(numel(in.data),numel(in.lat),numel(in.lon))
    in.data = in.data(:); in.lat = in.lat(:); in.lon = in.lon(:);
end

assert(isequal(size(in.data,1),size(in.lat,1),size(in.lon,1)),...
    errId,'data,lat,lon must all be the same size')

if isfield(in,'newlon')
    str = 'fields ''newlat'' and ''newlon''';
    assert(max(diff(in.newlat))-min(diff(in.newlat))<1e-4 && ...
        max(diff(in.newlon))-min(diff(in.newlon))<1e-4,...
        errId,'vectors in %s must be monotonously spaced',str)
    
    if isfield(in,'gridsize')
        warning(errId,'%s cancel ''gridsize''',str)
    elseif isfield(in,'region')
        warning(errId,'%s cancel ''region''',str)
    end
end

function in = regionchop(in)
% Get rid of all data outside of region

lt1 = in.lat > in.region(1);
ln1 = in.lon > in.region(2);
lt2 = in.lat < in.region(3);
ln2 = in.lon < in.region(4);

index = ln1 & ln2 & lt1 & lt2;

in.lat = in.lat(index);
in.lon = in.lon(index);
in.data = in.data(index,:);

function [in,lat,lon] = outputlatlons(in,lonspace)
%% fix the latlons
% Sets up lat lon and adjusts in.lon to the requested (if requested)
% longitude regime (0:360 or -180:180)
%
errId = 'atmlab:binning_fast:badInput';

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
else
    error(errId,...
        'lonspace must be 180, 360 or 0 (default (do nothing))')
end

if in.f360 && ~isfield(in,'region')
    in.region = [-90 0 90 360];
elseif ~in.f360 && ~isfield(in,'region')
    in.region = [-90 -180 90 180];
end

if isfield(in,'newlon')
    lat = in.newlat;
    lon = in.newlon;
    if lonspace~=0
        warning(errId,'fields ''newlat'' and ''newlon'' make lonspace irrelevant')
    end
    return
end

d = in.gridsize;
assert(numel(d)<=2,errId,'''gridsize'' should contain 1 or 2 values')

if isscalar(d), d = [d,d]; end
lat = in.region(1)+0.5*d(1):d(1):in.region(3)-0.5*d(1);
lon = in.region(2)+0.5*d(2):d(2):in.region(4)-0.5*d(2);