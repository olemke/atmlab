% ELLIPSOID_INTERSECTION   Finds intersection between LOS and an ellipsoid
%
%    If no intersection is found, a negative value is returned.
%
% FORMAT  l = ellipsoid_intersection(ellipsoid,x,y,z,dx,dy,dz)
%
% OUT   l   Distance to intersection
% IN    ellipsoid  See *ellipsoidmodels(:
%       x   ECEF coordinate of observation point(s)
%       y   ECEF coordinate of observation point(s)
%       z   ECEF coordinate of observation point(s)
%       dx  Component of unit vector representing LOS
%       dy  Component of unit vector representing LOS
%       dz  Component of unit vector representing LOS

% 2020-09-26   Patrick Eriksson

function l = ellipsoid_intersection(ellipsoid,x,y,z,dx,dy,dz)

% Spherical case
if ellipsoid(2) == 0
  % Based on r_crossing_3d in ARTS
  p  = x .* dx + y .* dy + z .* dz;
  pp = p .* p;
  q  = x .* x + y .* y + z .* z - ellipsoid(1).^2;
  l  = repmat( -1, size(p) );
  ii = find( q <= pp );
  sq = sqrt(pp(ii) - q(ii));
  for i = 1 : length(ii)
    j = ii(i);
    if -p(j) > sq(i)
      l(j) = -p(j) - sq(i);
    else
      l(j) = -p(j) + sq(i);
    end
  end
  
% Ellipsoid case
else
  % Based on https://medium.com/@stephenhartzell/satellite-line-of-sight-intersection-with-earth-d786b4a6a9b6
  a = ellipsoid(1);
  b = ellipsoid(1);
  c = ellipsoid(1)*sqrt(1-ellipsoid(2)*ellipsoid(2));

  a2  = a*a;
  b2  = b*b;
  c2  = c*c;
  x2  = x.^2;
  y2  = y.^2;
  z2  = z.^2;
  dx2 = dx.^2;
  dy2 = dy.^2;
  dz2 = dz.^2;

  rad = a2.*b2.*dz2 + a2.*c2.*dy2 - a2.*dy2.*z2 + 2.*a2.*dy.*dz.*y.*z - ...
        a2.*dz2.*y2 + b2.*c2.*dx2 - b2.*dx2.*z2 + 2.*b2.*dx.*dz.*x.*z - ...
        b2.*dz2.*x2 - c2.*dx2.*y2 + 2.*c2.*dx.*dy.*x.*y - c2.*dy2.*x2;

  l     = repmat( -1, size(rad) );
  ii    = find( rad >= 0 );

  val   = -a2.*b2.*dz(ii).*z(ii) - a2.*c2.*dy(ii).*y(ii) - ...
           b2.*c2.*dx(ii).*x(ii);
  mag   = a2.*b2.*dz2(ii) + a2.*c2.*dy2(ii) + b2.*c2.*dx2(ii);
  l(ii) = (val - a.*b.*c.*sqrt(rad(ii))) ./ mag;
end

