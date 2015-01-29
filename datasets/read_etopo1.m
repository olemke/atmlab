% READ_ETOPO1  reads etopo1 digital elevation model
%               data into G-format data
%
%
% ETOPO1 is a 1 arc-minute global relief model of Earth's 
% surface that integrates land topography and ocean bathymetry. 
% It was built from numerous global and regional data sets.
% http://www.ngdc.noaa.gov/mgg/global/global.html
%
% The horizontal coordinate system is decimal degrees of
% latitude and longitude referenced to World Geodetic System 84 (WGS84).
% The vertical units represent elevation in meters above mean sea level.
% 
% This function is used together with the atmlab function
% "LAND_SEA_MASK". Ocean data points are masked out with -9999. 
%
% The actual data files are found within the atmlab-data svn package.
%
% FORMAT
%
%         [G] = read_etopo1(lat_limits, lon_limits)
%
% OUT
%         G             etopo1 data on gformat structure
%                       ( all data at full resolution
%                         within the desired limits)
%
% IN
%        lat_limits     latitude limits (vector)
%        lon_limits     longitude limits (vector) (-180 to 180)
%

% HISTORY: Created by Bengt Rydberg 2015-01-29

function [G]=read_etopo1(lat_limits,lon_limits)


strictAssert = atmlab('STRICT_ASSERT');

if strictAssert;

  rqre_datatype( lat_limits, @isvector );
  rqre_datatype( lon_limits, @isvector );
  if length(lon_limits)~=2;
    error('lon_limits must be a vector of length 2')
  end
  if length(lat_limits)~=2;
    error('lat_limits must be a vector of length 2')
  end
  if any(lon_limits<-180) | any(lon_limits>180);
    error('lon_limits must be inside -180 to 180')
  end
  if any(lat_limits<-90) | any(lat_limits>90);
    error('lat_limits must be inside -90 to 90')
  end
  if lon_limits(1)>lon_limits(2);
    error('lon_limits(2) must be greater than lon_limits(2)')
  end
  if lat_limits(1)>lat_limits(2);
    error('lat_limits(2) must be greater than lat_limits(2)')
  end

end

%path to data file
demfile = fullfile(atmlab('ATMLAB_DATA_PATH'),...
         'dem_data/etopo1/ETOPO1_Ice_g_gmt4.grd');

G          = gf_empty(2);

e_lat = ncread(demfile,'y');
e_lon = ncread(demfile,'x');

i_ind = find( e_lat >= lat_limits(1)-1 &  e_lat<= lat_limits(2)+1 );
j_ind = find( e_lon >= lon_limits(1)-1 &  e_lon<= lon_limits(2)+1 );

e_lat = e_lat(i_ind);
e_lon = e_lon(j_ind);

start = [j_ind(1) i_ind(1)];
count = [length(j_ind) length(i_ind)];
G.DATA = ncread( demfile, 'z', start, count)'; 

[lat,lon,M] = land_sea_mask( '1min' );
if lon_limits(1)<0;
  % shift data
  ind  = find(lon>180);
  
  temp = M(:,ind); 
  M(:, length(ind)+1:end) = M(:, 1:ind(1)-1);
  M(:, 1:length(ind)) = temp;
  
  temp = lon(ind);
  lon(length(ind)+1:end) = lon(1:ind(1)-1);
  lon(1:length(ind)) = temp-360;  

end

i_ind  = find( lat >= lat_limits(1) &  lat<= lat_limits(2) );
j_ind  = find( lon >= lon_limits(1) &  lon<= lon_limits(2) );
M      = M(i_ind,j_ind); 
G.DATA = gridinterp( {e_lat,e_lon}, G.DATA, {lat(i_ind),lon(j_ind)} );
ind    = find(M==255);
G.DATA(ind) = -9999;


G.TYPE       = 'surfdata';
G.NAME       = 'ETOPO1 dem data';
G.SOURCE     = demfile;
G.DATA_NAME  = 'Surface elevation';
G.DATA_UNIT  = 'm';
G.GRID1      = vec2col(lat(i_ind));
G.GRID1_NAME = 'Latitude';
G.GRID1_UNIT = 'deg';
G.GRID2      = vec2col(lon(j_ind));
G.GRID2_NAME = 'Longitude';
G.GRID2_UNIT = 'deg';



if 0;
  i=10;
  pcolor(G.GRID2(1:i:end),G.GRID1(1:i:end),G.DATA(1:i:end,1:i:end))
  shading flat
  hold on
  load coast
  c1=plot(long,lat,'k')
  set(c1,'linewidth',2)
  colorbar
  caxis([-200 max(G.DATA(:))])
end
