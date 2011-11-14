function [rc,cc] = radii2sphere(lats,lons,r)
  
% Check input                                                          %&%
rqre_datatype( lats, @isvector );                                      %&%
rqre_datatype( lons, @isvector );                                      %&%
rqre_datatype( r, @ismatrix );                                         %&%
if length(lats) ~= 2 | diff(lats) == 0                                 %&%
 error( '*lats* must be a vector with 2 different latitudes.' );       %&%
end                                                                    %&%
if length(lons) ~= 2 | diff(lons) == 0                                 %&%
 error( '*lons* must be a vector with 2 different longitudes.' );      %&%
end                                                                    %&%
if any(size(r) ~= 2 )                                                  %&%
 error( 'The argument *r* must be a square matrix of size 2.' );       %&%
end                                                                    %&%


% Cartesian coordinates for the four points
[x1,y1,z1] = geocentric2cart( r(1,1), lats(1), lons(1) );
[x2,y2,z2] = geocentric2cart( r(2,1), lats(2), lons(1) );
[x3,y3,z3] = geocentric2cart( r(1,2), lats(1), lons(2) );
[x4,y4,z4] = geocentric2cart( r(2,2), lats(2), lons(2) );


% Matrix with vectors defining the plane through points 1, 2 and 3
%
A = [ x2-x1 x3-x1; y2-y1 y3-y1; z2-z1 z3-z1 ];

% Is point 4 in the same plane?
%
p4 = [x4-x1;y4-y1;z4-z1];
a = A \ p4;
%
if max( abs( A*a-p4 ) ) < 1e-6
  inplane = true;
else
  inplane = false;
end  
 

if inplane
  
  % Average radius
  rc = mean( [ sqrt(x1^2+y1^2+z1^2), sqrt(x2^2+y2^2+z2^2), ...
               sqrt(x3^2+y3^2+z3^2), sqrt(x4^2+y4^2+z4^2) ] );

  % Cartesian coordinates for middle point
  dv = A * (a/2);
  pm = [x1;y1;z1] + dv;
  pm = mean( [x1 y1 z1;x2 y2 z2;x3 y3 z3;x4 y4 z4] )';
  
  %[rt,latt,lont] = cart2geocentric( pm(1), pm(2), pm(3) )
  
  % Find normalised vector for plane normal
  nv = cross( A(:,1), A(:,2) );
  nv = nv / norm(nv);

  % Find the length from middle point to cc
  l = sqrt( rc^2 - sum(dv.^2) );
  
  % Cartersian point for middle point
  cc = pm + l*nv;
  
  
  % Check
  %constants('EARTH_RADIUS')*([ norm(cc-[x1;y1;z1]) norm(cc-[x2;y2;z2]) ...
  %                             norm(cc-[x3;y3;z3]) norm(cc-[x4;y4;z4])]-rc)
  
else
  rc = NaN;
  cc = NaN;
end


