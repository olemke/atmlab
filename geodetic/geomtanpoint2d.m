% GEOMTANPOINT2D   2D Geometrical tangent point
%
%    Calculates the 2D geometrical tangent point for arbitrary reference
%    ellipsiod. That is, a spherical planet is not assumed. The tangent
%    point is thus defined as the point closest to the ellipsoid (not as the
%    ppoint with za=90).
%   
%    Geocentric coordinates are used for both sensor and tangent point
%    positions. Following ARTS, 2D latitudes are not limited to [-90,90] and
%    this function keeps track on the actual 2D latitude (in contrast to
%    *geomtanpoint*).
% 
%    The algorithm used for non-spherical cases is derived by Nick Lloyd at
%    University of Saskatchewan, Canada (nick.lloyd@usask.ca), and is part of
%    the operational code for both OSIRIS and SMR on-board- the Odin
%    satellite. His 3D code is here adopted to 2D.
% 
% FORMAT  [rt,latt,lont] = geomtanpoint( ellipsoid, r, lat, lon, za, aa )
%
% OUT   rt         Radius of tangent point.
%       latt       Latitude of tangent point.
% IN    ellipsoid  Model ellipsoid as returned by *ellipsoidmodels*.
%       r          Radius of sensor position.
%       lat        Latitude of sensor position.
%       za         Zenith angle of sensor line-of-sight.

% 2012-02-13 Created by Patrick Eriksson

function [rt,latt] = geomtanpoint2d( ellipsoid, r, lat, za )

  
% Check input                                                          %&%
rqre_datatype( ellipsoid, @isvector );                                 %&%
if length(ellipsoid) ~= 2                                              %&%
 error( 'The argument *ellipsoid* must be a vector of length 2' );     %&%
end                                                                    %&%
rqre_in_range( ellipsoid(2), 0, 1, 'element 2 of ellipsoid' );         %&%
rqre_datatype( r, @istensor0 );                                        %&%
rqre_datatype( lat, @istensor0 );                                      %&%
rqre_datatype( za, @istensor0 );                                       %&%

  
%- Spherical planet
%
if ellipsoid(2) < 1e-7

  rt = r * sind( abs(za) );
  if za > 0
    latt = lat + za - 90;
  else
    latt = lat + za + 90;  
  end
  
  
%- Ellipsoidal planet
%
else
  
  % Equatorial and polar radii squared:
  a2 = ellipsoid(1)^2;
  b2 = a2 * ( 1 - ellipsoid(2)^2 ); 

  % Code from geocentricposlos2cart adopted to 2D
  %
  coslat = cosd( lat );
  sinlat = sind( lat );
  cosza  = cosd( za );
  sinza  = sind( za );
  %
  x    = r * coslat; 
  z    = r * sinlat;  
  %
  dr   = cosza;
  dlat = sinza;
  %
  dx = coslat*dr - sinlat*dlat;
  dz = sinlat*dr + coslat.*dlat;
   
  % For testing:
  %[x2,y2,z2,dx2,dy2,dz2] = geocentricposlos2cart( r, lat, 0, za, 0 );
  %  keyboard

  X = [x,0,z]';
  
  xunit = [dx,0,dz]';
  
  zunit = cross( xunit, X );
  zunit = zunit / norm(zunit);
 	
  yunit = cross( zunit, xunit );
  yunit = yunit / norm(yunit);
  
  w11 = xunit(1);
  w12 = yunit(1);
  w31 = xunit(3);
  w32 = yunit(3);
  yr  = dot( X, yunit );
  xr  = dot( X, xunit );

  A = w11*w11/a2 + w31*w31/b2;
  B = 2.0*(w11*w12/a2 + w31*w32/b2);
  C = w12*w12/a2 + w32*w32/b2;
 	
  if B == 0.0
    x = 0.0;
  else 
    K = -2.0*A/B;
    factor = 1.0/(A+(B+C*K)*K);
    x = sqrt(factor);
    y = K*x;
  end 
 	
  dist1 = (xr-x)*(xr-x) + yr*yr;
  dist2 = (xr+x)*(xr+x) + yr*yr;
 	
  if dist1 > dist2
    x = -x;
  end
  
  xn = w11*x + w12*yr;
  zn = w31*x + w32*yr
  
end


  
