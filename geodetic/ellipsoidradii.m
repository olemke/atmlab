% ELLIPSOIDRADII   Different radii of a reference ellipsoid
%
%    Both the actual ellipsoid radius and curvature radius can be obtained
%    by this function. If *azimuth* is specified, the curvature radius is
%    returned. Otherwise the radius of ellipsoid is returned.  
%
%    The calculation expressions are taken from radiigeo.pdf, found in the
%    same folder as this function.
%
%    Please note that geoDETIC latitudes are used.
%
% FORMAT   r = ellipsoidradii( ellipsoid, lat_gd, [azimuth] )
%    
% OUT   r          Radii. See above.
% IN    ellipsoid  Model ellipsoid as returned by *ellipsoidmodels*.
%       lat_gd     Geodetic latitudes.
% OPT   azimuth    Azimuthal angle (angle from NS plane). If given curvature
%                  radii are returned, see above

% 2011-11-14   Created by Patrick Eriksson.


function r = ellipsoidradii(ellipsoid,lat_gd,azimuth)

% Check input                                                          %&%
rqre_datatype( ellipsoid, @isvector );                                 %&%
if length(ellipsoid) ~= 2                                              %&%
 error( 'The argument *ellipsoid* must be a vector of length 2' );     %&%
end                                                                    %&%
rqre_in_range( ellipsoid(2), 0, 1, 'element 2 of ellipsoid' );         %&%
rqre_datatype( lat_gd, @isnumeric );                                   %&%
rqre_in_range( lat_gd, -90, 90 );                                      %&%


% Spherical case (all radii the same)
if ellipsoid(2) == 0
  %
  r = repmat( ellipsoid(1), size(lat_gd) );

% The actual radius  
elseif nargin < 3
  %
  e2   = ellipsoid(2)^2;
  sin2 = sind(lat_gd).^2;
  %
  r = ellipsoid(1) * sqrt((1-e2).^2*sin2+cosd(lat_gd).^2) ./ sqrt(1-e2*sin2);

% Curvature radius  
else
  %
  e2    = ellipsoid(2)^2;
  sin2  = sind(lat_gd).^2;
  aterm = 1-e2*sin2;
  %
  rn = 1 ./ sqrt(aterm);
  rm = (1-e2) * (rn ./ aterm );
  %
  r = ellipsoid(1) ./ ( cosd(azimuth)^2./rm + sind(azimuth)^2./rn );

end