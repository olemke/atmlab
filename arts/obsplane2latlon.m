function ang = obsplane2latlon(r0,lat0,lon0,za,aa,lat,lon)


%= Input
%
min_nargin( 6, nargin );
%
if nargin < 7
  lon = [];
end
%
if isempty( lat )  &  isempty( lon )
  error('Both *lat* and *lon* can not be empty.');
end
if ~isempty( lat )  &  ~isempty( lon )
  error('Either *lat* and *lon* must be empty.');
end


%= Convert to cartesian coordinates
%
[x0,y0,z0,dx,dy,dz] = poslos2cart( r0, lat0, lon0, za, aa );


DEG2RAD = constants( 'DEG2RAD' );
RAD2DEG = constants( 'RAD2DEG' );


%= Find longitude
%
if isempty( lon )



%= Find latitude
%
else

  lonrad = DEG2RAD * lon;
  coslon = cos( lonrad );
  tanlon = tan( lonrad );

  t = ( z0 - tanlon*x0 ) / ( tanlon*dx - dz );

  if t < 0 
    error('No intersection with given longitude is possible.');
  end

  ang = RAD2DEG * atan( coslon * ( y0+dy*t) / (x0+dx*t) );


end
