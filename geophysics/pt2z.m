% PT2Z   Hydrostatic altitudes
%
%    Calculates altitudes fulfilling hydrostatic equilibrium, based on
%    vertical profiles of pressure, temperature and water vapour. Pressure
%    and altitude of a reference point must be specified.
%
%    Molecular weights and gravitational constants are hard coded and 
%    function is only valid for Earth.
%
% FORMAT   z = pt2z( p, t, h2o, p0, z0 [,lat] )
%        
% OUT   z     Altitudes [m].
% IN    p     Column vector of pressures [Pa].
%       t     Column vector of temperatures [K].
%       h2o   Water vapour [VMR]. Vector or a scalar, e.g. 0. 
%       p0    Pressure of reference point [Pa].
%       z0    Altitude of reference point [m].
%       lat   Latitude. Default is 45.

% 2005-05-11   Created by Patrick Eriksson.


function z = pt2z(p,t,h2o,p0,z0,lat)
%
if nargin < 6, lat = 45; end
                                                                            %&%
rqre_nargin( 5, nargin );                                                   %&%
rqre_datatype( p, @istensor1 );                                             %&%
rqre_datatype( t, @istensor1 );                                             %&%
rqre_datatype( h2o, @istensor1 );                                           %&%
rqre_datatype( p0, @istensor0 );                                            %&%
rqre_datatype( z0, @istensor0 );                                            %&%
rqre_datatype( lat, @istensor0 );                                           %&%
np = length( p );
if length(t) ~= np                                                          %&%
  error('The length of *p* and *t* must be identical.');                    %&%
end                                                                         %&%
if ~( length(h2o) == np  |  length(h2o) == 1 )                              %&%
  error('The length of *h2o* must be 1 or match *p*.');                     %&%
end                                                                         %&%
if p0 > p(1)  |  p0 < p(np)                                                 %&%
  error('Reference point (p0) can not be outside range of *p*.');           %&%
end                                                                         %&%


%= Expand *h2o* if necessary
%
if  length(h2o) == 1
  h2o = repmat( h2o, np, 1 );
end


%= Make rough estimate of *z*
%
z = p2z_simple( p );
z = shift2refpoint( p, z, p0, z0 );


%= Set Earth radius and g at z=0
%
re = wgs84( 2, lat );
g0 = lat2g0( lat );


for iter = 1:2

  g = z2g( re, g0, z );

  for i = 1 : (np-1)
      
	gp  = ( g(i) + g(i+1) ) / 2;
  
	%-- Calculate weight mixing ratio for water assuming constant average
	%   molecular weight of the air
	r  = (18/28.96) * (h2o(i)+h2o(i+1)) / 2;
  
	%--  The virtual temperature (no liquid water)
	tv = (1+0.61*r) * (t(i)+t(i+1)) / 2;
  
	%-- The change in vertical altitude from i to i+1 
	dz = 287.053 * (tv/gp) * log( p(i)/p(i+1) );
	z(i+1) = z(i) + dz;
      
  end
  
  %-- Match the altitude of the reference point
  z = shift2refpoint( p, z, p0, z0 );

end


return
%----------------------------------------------------------------------------

function z = shift2refpoint( p, z, p0, z0 )
  %
  z = z - ( interpp( p, z, p0 ) - z0 );
  %
return


function g = z2g(r_geoid,g0,z)
  %
  g = g0 * (r_geoid./(r_geoid+z)).^2;
  %
return


function g0 = lat2g0(lat)
  %
  x  = abs( lat );
  g0 = 9.780327 * ( 1 + 5.3024e-3*sind(x).^2 + 5.8e-6*sind(2*x).^2 );
  %
return

