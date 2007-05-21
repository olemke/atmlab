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
% IN    p     Vector of pressures [Pa].
%       t     Vector of temperatures [K].
%       h2o   Vater vapour [VMR]. Can be a scalar, e.g. 0. 
%       p0    Pressure of reference point [Pa].
%       z0    Altitude of reference point [m].
%       lat   Latitude. Default is 45.

% 2005-05-11   Created by Patrick Eriksson.


function z = pt2z(p,t,h2o,p0,z0,lat)


%= Check input
%
min_nargin( 5, nargin );
%
rqre_datatype( 'vector', p );
rqre_datatype( 'vector', t );
rqre_datatype( 'vector', h2o );
rqre_scalar( 'p0', p0, 0 );
rqre_scalar( 'z0', z0 );
if nargin > 5
  rqre_scalar( 'lat', lat, -90, 90 );
end
%
np = length( p );
%
if length(t) ~= np
  error('The length of *p* and *t* must be identical.');
end 
%
if ~( length(h2o) == np  |  length(h2o) == 1 )
  error('The length of *h2o* must be 1 or match *p*.');
end 
%
if p0 > p(1)  |  p0 < p(np)
  error('Reference point (p0) can not be outside range of *p*.');
end



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
if ~exist('lat','var')
  lat = 45;
end
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
  A = [
   0 9.78039
   5 9.78078
  10 9.78195
  15 9.78384
  20 9.78641
  25 9.78960
  30 9.79329
  35 9.79737
  40 9.80171 
  45 9.80621
  50 9.81071
  55 9.81507
  60 9.81918
  65 9.82288
  70 9.82608
  75 9.82868
  80 9.83059
  85 9.83178
  90 9.83217
  ];
  %
  g0 = interp1( A(:,1), A(:,2), abs(lat) );
  %
return

