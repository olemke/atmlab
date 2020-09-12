% GEODETICPOSLOS2CART converts from geodetic POS/LOS to cartesian coordinates
%
% See Contents for a defintion of the cartesian ECEF coordinate system. 
% The local LOS angles are defined as in ARTS:
%         za    aa
%         90    0   points towards north
%         90    90  points towards east
%         0     aa  points up
% Here up means local zenith, i.e. the reference ellipsoid normal.
% 
% FORMAT  [x,y,z,dx,dy,dz] = geodeticposlos2cart(h,lat,lon,za,aa[,ellipsoid])
%
% OUT     x    Coordinate in x dimension
%         y    Coordinate in y dimension
%         z    Coordinate in z dimension
%         dx   LOS component in x dimension
%         dy   LOS component in y dimension
%         dz   LOS component in z dimension
% IN      h    Altitude
%         lat  Latitude
%         lon  Longitude
%         za   zenith angle
%         aa   azimuth angle
% OPT     ellipsoid a vector with the form [semimajor axis; eccentricity]
%                  specifying the ellipsoid. Default is WGS84.

% 2020-09-11, Patrick Eriksson


function [x,y,z,dx,dy,dz] = geodeticposlos2cart(h,lat,lon,za,aa,ellipsoid)

if nargin<6
  %WGS84 reference ellipsoid
  ellipsoid = ellipsoidmodels( 'WGS84' );
end 

rqre_in_range( lat, -90, 90 )
rqre_in_range( lon, -360, 360 )
rqre_in_range( za, 0, 180 )


deg2rad = constants( 'DEG2RAD' );


% For lat = +- 90 the azimuth angle gives the longitude along which the
% LOS goes
%
if abs( lat ) > 90-1e-8
  %
  s = sign( lat );
  r = h + ellipsoid(1)*sqrt(1-ellipsoid(2)^2);
  %
  x = 0;
  y = 0;
  z = s .* r;
  %
  dz = s .* cos( deg2rad .* za );
  dx = sin( deg2rad .* za );
  dy = dx .* sin( deg2rad .* aa );
  dx = dx .* cos( deg2rad .* aa );

else

  [x,y,z] = geodetic2cart( h, lat, lon, ellipsoid );
      
  coslat = cosd(lat);
  sinlat = sind(lat);
  coslon = cosd(lon);
  sinlon = sind(lon);

  [de,dn,du] = zaaa2enu( za, aa );  

  % See https://en.wikipedia.org/wiki/Geographic_coordinate_conversion#From_ECEF_to_ENU
  dx = -sinlon.*de - sinlat.*coslon.*dn + coslat.*coslon.*du;  
  dy =  coslon.*de - sinlat.*sinlon.*dn + coslat.*sinlon.*du;  
  dz =               coslat.*        dn + sinlat.*        du;  
  
end






