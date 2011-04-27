function in = resample_geodata(in,field,newgrid)
% RESAMPLE_GEODATA regrid the data to a new gridsize or fitting to new lat lons
%
% PURPOSE:  To resample the data according a given gridsize or lat/lon
%           vectors. The data is regridded using matlabs INTERPOLATION
%           functions if the grid resolution should be FINER and the data
%           is RESAMPLED using area wieghting averages using a local plane
%           assumption if the grid resolution should be COARSER.
%
%
% NOTE:     - Interpolation is linear only up to now.
%           - When dealing with very coarse resolution the local plane
%             assumption will cause some errors, the remedy is area weighting
%             also depending on latitude. This is not there yet but can easily
%             implemented.
%           - The input grid must be equidegree (homoginous spacing)
%
% Data may have several dimensions.
% 
% IN:
%
%   in          struct      contains: lat,lon,field1,etc (maybe more fields to regrid)
%
%   field       %s          {'field1',etc}; The field/s  you want to regrid
%
%   newgrid     %f, or [%f %f], {[newlat],[newlon]}
%
%              a) Either make a sqaure grid using a scalar %f. e.g 1deg -> 2deg
%              b) or a 2 element vector [%f %f] means [latstep, lonstep]
%              e.g. 1*1 -> 1.25*2.75
%              c) or {[newlat],[newlon]} if you want to match to a predefined
%              lat lon grid. 
%              newgrid may be provided in the structure (in.newgrid) for convience
% 
% OUT:         struct       Original structure 'in' with lat, lon, and specified fields
%                           replaced with their regridded versions
%
% METHOD   The function will do the following:
% 
% 1) Makes sure that your data is organised (lat,lon,etc,etc).
% 2) Makes sure the lat and lon are in acending order.
% 3) Regrid the data according to specified input 'newgrid'
% 4) If a region is specified, it'll remove all data outside the region
%    and output the latlons of the smaller region
% 
%
% NOTE:   If you use new grid = [latstep, lonstep], both have to be higher or lower
%         than the relsolution of the input data!! FIXME (I could fix this easily)
%
%         Important:  (does not apply is you provide new lat lons in regrid{} ) 
%                   It is assumed that the grid values are centered!! 
%                   for the interpolation/resampling it is always assumed 
%                   that the whole world is in the data.
%                   (regionize truncates to the specified regions in the next step)
%             
% 
% USAGE:         in = regrid_dataset(in,field,newgrid) 
%         e.g.   in = regrid_dataset(struct('data1',d1,'data2',d2'lat',lt,'lon'),{'data1','data2'},5)
%
%                The above will regrid fields 'data1' and 'data2' to a 5 deg grid
%                and the output lat lons will correspod to the newgrid
%
% Created by Salomon Eliasson (contact me if the function needs tweeking)
% $Id: regrid_dataset.m 6417 2011-04-21 06:44:37Z seliasson $

%% Check input
BI = 'Salomon:resample_geodata:badInput';
assert(nargin>=2,BI,'Read help for usage')
if nargin ~= 3
    assert(isfield(in,'newgrid'),BI,'Read help for usage')
    newgrid = in.newgrid;
end
if ~iscell(field), field={field}; end
assert(isstruct(in) && ischar(field{1}) && (isnumeric(newgrid) || iscell(newgrid)),...
      BI,'Usage:  in = regrid_dataset(in,field,newgrid)')

%check fieldnames in struct
field = field(ismember(field,fieldnames(in)));
assert(~isempty(field),BI,'Nothing to work on. read help');
assert(~any(~isfield(in,{'lat','lon'})),BI,'"lat,lon" are required')
assert(~isequal([size(in.(field{1}),1),size(in.(field{1}),2)],size(in.lat),size(in.lon)),...
    BI,'function only works on regular grids')

%check equidegree grid
cond1 = max(diff(in.lat))-min(diff(in.lat)) < 0.1; %deg 
cond2 = max(diff(in.lon))-min(diff(in.lon)) < 0.1; %deg 
assert(cond1 && cond2, BI,...
    'The input grid must be equidegree (homoginous spacing)')

% preserve information on original longitudes. Internally I want the
% longitudes to be in 180:180 format
flag360 = ( max(in.lon)>180 && ~iscell(newgrid) ) || ...
    ( iscell(newgrid) && max(newgrid{2}>180) );


%% Loop over fields in which to regrid
t.lon=in.lon; t.lat=in.lat;
for F = field
    in.lon=t.lon;in.lat=t.lat;
    % SANITIZE the lat lons
    [in.(F{1}),in.lat,in.lon] = homogenize_datalatlon(in.(F{1}),in.lat,in.lon);
    % do the REGRIDDING
    in = regriddata(in,F{1},newgrid,flag360);
    % apply REGIONS to data
    if any(isfield(in,{'region','corners'}))
        in = regionize(in,F{1});
    end
    % CHANGE longitudes back to 0:360, if that's how they came in
    if flag360
        in.lon = in.lon+(in.lon < 0)*360;
        [in.lon,lnindex] = sort(in.lon);
        in.(F{1}) = in.(F{1})(:,lnindex,:,:);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUNFUNCTIONS bellow here
%
function in = regriddata(in,field,newgrid,flag360)
% regriddata core function (wrapper to regrid via interpolate or averaging)

if iscell(newgrid) % match to given lat lons
    % internally use the -180:180 scheme
    newlat = newgrid{1};
    if flag360
        newlon = sort( newgrid{2}-(newgrid{2} > 180)*360 );
        
    else newlon = newgrid{2};
    end
else               % just regrid
    g=newgrid;
    newlat = -90+g(1)/2 : g(1) : 90-g(1)/2;
    if length(g)==2
        newlon = -180+g(2)/2 : g(2) : 180-g(2)/2;
    else
        newlon = -180+g(1)/2 : g(1) : 180-g(1)/2;
    end
end

% check so that you don't extrapolate and interpolate
cond1 = length(in.lat) < length(newlat) && length(in.lon) > length(newlon);
cond2 = length(in.lat) > length(newlat) && length(in.lon) < length(newlon);

% check if old grid and newgrid fit together nicely
cond3 = mean(diff(newlat))/mean(diff(in.lat)) == ...
    floor(mean(diff(newlat))/mean(diff(in.lat))); 

assert(~(cond1 || cond2),'Salomons:resample_geodata:badInput','%s, %s, %s',...
    'If you use 2 new grid resolutions',...
    'both have to be higher or lower than the relsolution of the input data!!')

if length(in.lat) < length(newlat) || length(in.lon) < length(newlon)
    in = interpolate_grid(in,newlat,newlon,field);                         
end
if length(in.lat) > length(newlat) || length(in.lon) > length(newlon)
    if cond3
        in = coarser_grid(in,newlat,newlon,field);
    else
        in = coarser_grid_withAreaweighting(in,newlat,newlon,field);
    end
end

function in = interpolate_grid(in,lat,lon,field)
%% INTERPOLATE_GRID interpolate data to a smaller grid.
% 
% IN   in         struct          containing: lat,lon,data to interpolate
%      lat        %f vect         New latitude vector
%      lon        %f vect         New longitude vector
%      field      %s              The name of the field to interpolate
% 
% Out: in         struct          original in with the new lat,lon and data

assert(nargin==4,'Salomons:interpolate_grid:badInput','See help section')

if gmtlab('verbosity')
    fprintf('Changing grid from %dx%d to %dx%d deg by INTERPOLATION\n',...
    mean(diff(in.lat)),mean(diff(in.lon)),mean(diff(lat)),mean(diff(lon)))
end


% Expand the new lat lons so they encompass orig latlon
in = expand_latlons(in,lat,lon,field);

[X,Y] = meshgrid(in.lon,in.lat);
[XI,YI] = meshgrid(lon,lat);

%interpolate
data = zeros([length(lat),length(lon),size(in.(field),3)]);
for ii  = 1: size(in.(field),3)
    Z = in.(field)(:,:,ii);
    data(:,:,ii) = interp2(X,Y,Z,XI,YI);                                   
end

in.(field) = data;

in.lon = lon;
in.lat = lat;

function in = expand_latlons(in,lat,lon,field)
%% EXPAND_LATLONS Expand the new lat lons so they encompass orig latlon
% using the gridspace so that interp2 finds values outside the given range.
% If not, the edges will contain NaNs that shouldn't be there


in.lon=in.lon(:)';% reshape for row vector
d = in.lon(2)-in.lon(1);

% keep expanding until the new latlons are wider than the latlons to be
% interpolated into
while in.lon(1)>=lon(1)
    in.lon = [in.lon(1)-d,in.lon,in.lon(end)+d];
    in.(field) = [in.(field)(:,end,:,:),in.(field),in.(field)(:,1,:,:)];
end

in.lat = in.lat(:)';  % reshape for row vector
d = in.lat(2)-in.lat(1);

while in.lat(1)>=lat(1)
    in.lat = [in.lat(1)-d,in.lat,in.lat(end)+d];
    in.(field) = [in.(field)(1,:,:,:);in.(field);in.(field)(end,:,:,:)];
end

function in = coarser_grid_withAreaweighting(in,lat,lon,field)
%% COARSER_GRID make a coarse grid from a finer grid 
% method: Uses area weighting for grids that don't fit nicely into each
% other and assumes local plane assumption, which is good as long as the
% grids are not too large (see help resample_data) 

assert(nargin==4,'Salomons:coarser_grid:badInput','See help resample_geodata')

gn = mean(diff(lon));
gt = mean(diff(lat));
dn = mean(diff(in.lon));
dt = mean(diff(in.lat));
if isnan(gt), gt = (in.lat(end)-in.lat(1) + dt);end %incase there's only one latitude
if isnan(gn), gn = (in.lon(end)-in.lon(1) + dn);end %incase there's only one longitude
if gmtlab('verbosity')
    fprintf('Changing grid from %dx%d to %dx%d deg by area-weighted AVERAGING\n',...
    dt,dn,gt,gn)
end
sz = size(in.(field));
data = zeros([length(lat),length(lon),sz(3:end)],class(in.(field)));
nvalid = zeros(size(data),'int16'); % keep track of points used

%treat the gridded data as ungridded
for ii = 1:length(lat)
    for jj=1:length(lon)
        % [x,y,width,height] x,y = bottom corner
        A = [lon(jj)-gn/2,lat(ii)-gt/2,gn,gt]; 
        
        ilon = in.lon >= lon(jj)-gn/2 & in.lon < lon(jj)+gn/2+dn;
        ilat = in.lat >= lat(ii)-gt/2 & in.lat < lat(ii)+gt/2+dt;
        
        [x,y] = meshgrid(in.lon(ilon)-dn/2,in.lat(ilat)-dt/2);
        
        B = [ x(:), y(:), repmat(dn,length(y(:)),1), repmat(dt,length(x(:)),1)];
                
        weights = rectint(A,B);
        d = in.(field)(ilat,ilon);
        nvalid(ii,jj) = sum(~isnan(d(:)));
        data(ii,jj)   = nansum(d(:).*weights')/sum(weights);
    end
end
in.lon         = lon;
in.lat         = lat;
in.(field)     = data;
in.nvalid_data = nvalid;

function in = coarser_grid(in,lat,lon,field)
%% coarser_grid by averaging.
% 
% Purpose: To make gridded data more sparse if the grids fit nicely into each other.
% NOTE: Biases may be introduced because I am using nanmean. The solution
%       is to also output the number of values used in the averaging for
%       each grid

assert(nargin==4,'Salomons:coarser_grid:badInput','See help resample_geodata')

gn = mean(diff(lon));
gt = mean(diff(lat));
dn = mean(diff(in.lon));
dt = mean(diff(in.lat));
if isnan(gt), gt = (in.lat(end)-in.lat(1) + dt);end %incase there's only one latitude
if isnan(gn), gn = (in.lon(end)-in.lon(1) + dn);end %incase there's only one longitude
if gmtlab('verbosity')
    fprintf('Changing grid from %dx%d to %dx%d deg by AVERAGING\n',...
    dt,dn,gt,gn)
end

sz = size(in.(field));
data = zeros([length(lat),length(lon),sz(3:end)]);
nvalid = zeros(length(lat),length(lon));

%treat the gridded data as ungridded
for ii = 1:length(lat)
    for jj=1:length(lon)
        % data with the larger newgrid is just averaged (nanmean)
        test1= in.lat>=lat(ii)-gt/2 & in.lat<lat(ii)+gt/2;
        test2= in.lon>=lon(jj)-gn/2 & in.lon<lon(jj)+gn/2;
        temp = in.(field)(test1,test2,:,:);
        nvalid(ii,jj)  = numel(temp(~isnan(temp)));
        data(ii,jj,:,:)= nanmean(temp(:));                                               
    end
end
in.(field)=data;
in.lon=lon;
in.lat=lat;
in.nvalid_data = nvalid;