% GEOCENTRICPOSLOS2CART   converts from spherical coordinate 
%                         and line of sight (LOS) direction 
%                         to a cartesian position and LOS direction   
%
% See CART2GEOCENTRIC for a defintion of the geocentric 
% coordinate system. The local LOS angles are defined following 
% the EAST-NORTH-UP system:
%         za    aa
%         90    0   points towards north
%         90    90  points towards east
%         0     aa  points up
% 
% FORMAT  [x,y,z,dx,dy,dz]=geocentricposlos2cart(r,lat,lon,za,az) 
%
% OUT     x    Coordinate in x dimension
%         y    Coordinate in y dimension
%         z    Coordinate in z dimension
%         dx   LOS component in x dimension
%         dy   LOS component in y dimension
%         dz   LOS 
%
% IN      r    Radius 
%         lat  Latitude
%         lon  Longitude
%         za   zenith angle
%         aa   azimuth angle

% History: created by Bengt Rydberg 2011-10-31
function [x,y,z,dx,dy,dz]=geocentricposlos2cart(r,lat,lon,za,aa)

[x, y, z] = geocentric2cart(r, lat, lon);


% For lat = +- 90 the azimuth angle gives the longitude along which the
% LOS goes
%
latrad = deg2rad(lat);
lonrad = deg2rad(lon);
zarad  = deg2rad(za);
aarad  = deg2rad(aa);

if abs( lat ) > 89.9999
  %  
  dz = sign( lat ).* cos( zarad );
  dy = sin(zarad).* sin( aarad );
  dx = sin(zarad).* cos( aarad );

else
  %
  coslat = cos( latrad );
  sinlat = sin( latrad );
  coslon = cos( lonrad );
  sinlon = sin( lonrad );
  cosza  = cos( zarad );
  sinza  = sin( zarad );
  cosaa  = cos( aarad );
  sinaa  = sin( aarad );
  %
  dr     = cosza;
  dlat   = sinza .* cosaa;            % r-terms cancel out below
  dlon   = sinza .* sinaa / coslat; 
  %
  dx = coslat.*coslon.*dr - sinlat.*coslon.*dlat - coslat.*sinlon.*dlon;
  dz =         sinlat.*dr +         coslat.*dlat;
  dy = coslat.*sinlon.*dr - sinlat.*sinlon.*dlat + coslat.*coslon.*dlon;
end


