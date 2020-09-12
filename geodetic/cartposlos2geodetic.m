% CARTPOSLOS2GEODETIC converts from cartesian coordinates to geodetic POS/LOS
%
% See Contents for a defintion of the cartesian ECEF coordinate system. 
% The local LOS angles are defined as in ARTS:
%         za    aa
%         90    0   points towards north
%         90    90  points towards east
%         0     aa  points up
% Here up means local zenith, i.e. the reference ellipsoid normal.
% 
% FORMAT  [h,lat,lon,za,aa] = cartposlos2geodetic(x,y,z,dx,dy,dz[,ellipsoid])
%
% OUT     h    Altitude
%         lat  Latitude
%         lon  Longitude
%         za   zenith angle
%         aa   azimuth angle
% IN      x    Coordinate in x dimension
%         y    Coordinate in y dimension
%         z    Coordinate in z dimension
%         dx   LOS component in x dimension
%         dy   LOS component in y dimension
%         dz   LOS component in z dimension
% OPT     ellipsoid a vector with the form [semimajor axis; eccentricity]
%                  specifying the ellipsoid. Default is WGS84.

% 2020-09-12, Patrick Eriksson


function [h,lat,lon,za,aa] = cartposlos2geodetic(x,y,z,dx,dy,dz,ellipsoid)

if nargin<6
  %WGS84 reference ellipsoid
  ellipsoid = ellipsoidmodels( 'WGS84' );
end 

[h,lat,lon] = cart2geodetic( x, y, z, ellipsoid );

sinlat = sind(lat);
coslat = cosd(lat);
sinlon = sind(lon);
coslon = cosd(lon);

% See https://en.wikipedia.org/wiki/Geographic_coordinate_conversion#From_ECEF_to_ENU
de =         -sinlon.*dx +         coslon.*dy;  
dn = -sinlat.*coslon.*dx - sinlat.*sinlon.*dy + coslat.*dz;  
du =  coslat.*coslon.*dx + coslat.*sinlon.*dy + sinlat.*dz;  

[za,aa] = enu2zaaa( de, dn, du );






