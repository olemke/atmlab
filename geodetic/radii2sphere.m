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

% Average radius
rm = mean( r(:) );

% Matrix with vectors defining the plane through points 1, 2 and 3
%
A = [ x2-x1 x3-x1; y2-y1 y3-y1; z2-z1 z3-z1 ];

% Is point 4 in the same plane?
%
p4 = [ x4-x1; y4-y1; z4-z1 ];
a = A \ p4;
%
if max( abs( A*a-p4 ) ) < 1e-6*rm   % Fine tune this value !!!
  inplane = true;
else
  inplane = false;
end  
 

if inplane
  
  error( 'The case when the four points are inside a plane not yet handled.' );
  
  % Find normalised vector for plane normal, going towards origo
  nv = cross( A(:,1), A(:,2) );
  nv = nv / norm(nv);


  % Cartesian coordinates for middle point
  pm = mean( [x1 y1 z1;x2 y2 z2;x3 y3 z3;x4 y4 z4] )';
  
[rt,latt,lont] = cart2geocentric( pm(1), pm(2), pm(3) );

  % Half distance between point 1 and 4
  l = 0.5 * norm(p4);
    
  % Use this to set cc (the distance is rc*cos(b), where sin(b)=l/rc)
  cc = pm + rc*cos(asin(l/rc))*nv; 

  
  [xm,ym,zm] = geocentric2cart( rc, mean(lats), mean(lons) );
  pm         = [xm,ym,zm]';
  cc = pm + rc*nv; 
  
  
  % Check
  constants('EARTH_RADIUS')*([ norm(cc-[x1;y1;z1]) norm(cc-[x2;y2;z2]) ...
                               norm(cc-[x3;y3;z3]) norm(cc-[x4;y4;z4])]-rc)
  
else
 %rotate the two points p1 and p2 to the 0 longitude plane
 %these points are at the same longitude
 [x1b,y1b,z1b]=geocentric2cart(r(1,1),lats(1),0);
 [x2b,y2b,z2b]=geocentric2cart(r(2,1),lats(2),0);
 %find the intersection point in this plane
 [y]=circle_intersect([x1b z1b],[x2b z2b],...
                                 (r(1,1)+r(2,1))/2 ,(r(1,1)+r(2,1))/2);
 %find the vector pointing from the intersection point
 %towards point p1 
 [r12,lat12,lon12]=cart2geocentric(x1b-y(1,1),0,z1b-y(1,2));

 %the angle between the point P1, circle center, and P2
 dp1=[x1b-y(1,1),0,z1b-y(1,2)];
 dp2=[x2b-y(1,1),0,z2b-y(1,2)];
 rad2deg=constants('RAD2DEG');
 theta=acos(dp1/norm(dp1)*dp2'/norm(dp2))*rad2deg;
 %rotate the vector pointing from the intersection point
 %by some fraction of theta
  [x12,y12,z12]=geocentric2cart(r12,lat12+theta/4,lon12);
 %calcluate the new position
 [r12,lat12,lon12]=cart2geocentric(y(1,1)+x12,y12,z12+y(1,2));
 %rotate back to the correct longitude plane 
 [x12,y12,z12]=geocentric2cart(r12,lat12,lons(1));
 %find the sphere center and radius 
 [x0,y0,z0,rc]=fourpoints2sphere(x12,y12,z12,x2,y2,z2,x3,y3,z3,x4,y4,z4);

  cc = [x0,y0,z0];

end


%fourpoints2sphere given four points in the three-dimensional
%                  space the function returns the origin and radius
%                  of a sphere that intersects with the four points.
%                  
%                  Ref: http://paulbourke.net/geometry/spherefrom4/
% 
% FORMAT [x0,y0,z0,r]=fourpoints2sphere(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4)
% 
% OUT   
%       x0    cartesian coordinate of the origin of the sphere
%       y0    cartesian coordinate of the origin of the sphere
%       z0    cartesian coordinate of the origin of the sphere
%       r0    radius of the sphere
%
% IN    
%       x1    cartesian coordinate of point 1
%                       -||-
%       z4    cartesian coordinate of point 4
%

%History: created by Bengt Rydberg 2011-11-08

function [x0,y0,z0,r]=fourpoints2sphere(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4)

M11=det([x1 y1 z1 1;...
         x2 y2 z2 1;...
         x3 y3 z3 1;...
         x4 y4 z4 1]);

M12=det([x1^2+y1^2+z1^2 y1 z1 1;...
         x2^2+y2^2+z2^2 y2 z2 1;...
         x3^2+y3^2+z3^2 y3 z3 1;...
         x4^2+y4^2+z4^2 y4 z4 1]);

M13=det([x1^2+y1^2+z1^2 x1 z1 1;...
         x2^2+y2^2+z2^2 x2 z2 1;...
         x3^2+y3^2+z3^2 x3 z3 1;...
         x4^2+y4^2+z4^2 x4 z4 1]);

M14=det([x1^2+y1^2+z1^2 x1 y1 1;...
         x2^2+y2^2+z2^2 x2 y2 1;...
         x3^2+y3^2+z3^2 x3 y3 1;...
         x4^2+y4^2+z4^2 x4 y4 1]);

M15=det([x1^2+y1^2+z1^2 x1 y1 z1;...
         x2^2+y2^2+z2^2 x2 y2 z2;...
         x3^2+y3^2+z3^2 x3 y3 z3;...
         x4^2+y4^2+z4^2 x4 y4 z4]);


x0=0.5*M12/M11;
y0=-0.5*M13/M11;
z0=0.5*M14/M11;
r=sqrt(x0^2+y0^2+z0^2-M15/M11);


%returns intersection points of two circles
%
% Format [y]=circle_intersect(P1,P2,r1,r2);
%
%        IN   P1 coordinates(x,y) of the circle 1 center
%             P2 coordinates(x,y) of the circle 2 center
%             r1 radius of circle 1
%             r2 radius of circle 2
%        OUT  y coordinates of the intersection points
%             y(1,:) are closest to origin (x=0,y=0) 
function [y]=circle_intersect(P1,P2,R1,R2);

Pv=P1-P2;
d=sqrt(Pv*Pv');

if d>(R1+R2)
 %no solutions (the circles are separate.)
 y=nan;
elseif d<abs(R1-R2)
 %no solutions (one circle is contained within the other.)
 y=nan;
elseif d==0 & R1==R2
 %infinite number of solutions (circles are coincident)
 y=inf;
else

 a=(R1^2-R2^2+d^2)/(2*d);
 h=sqrt(R1^2-a^2);
 P3=P1+a*(P2-P1)/d;
 x4a=P3(1)+h*(P2(2)-P1(2))/d;
 x4b=P3(1)-h*(P2(2)-P1(2))/d;
 y4a=P3(2)-h*(P2(1)-P1(1))/d;
 y4b=P3(2)+h*(P2(1)-P1(1))/d;

 P4a=[x4a,y4a];
 P4b=[x4b,y4b];
 
 d4a=sqrt(P4a*P4a');
 d4b=sqrt(P4b*P4b');
  
 if d4a==d4b
  %only one intersection
  y=[P4a;P4b];
 elseif d4a>d4b
  y=[P4b;P4a]; 
 else
  y=[P4a;P4b]; 
 end
end

return

% Old code:


  % Cartesian coordinates for middle point
  dv = A * (a/2);
  pm = [x1;y1;z1] + dv;
  pm = mean( [x1 y1 z1;x2 y2 z2;x3 y3 z3;x4 y4 z4] )';
  
  [rt,latt,lont] = cart2geocentric( pm(1), pm(2), pm(3) );
  

  % Find the length from middle point to cc
  l = sqrt( rc^2 - sum(dv.^2) );
  
  % Cartersian point for middle point
  cc = pm + l*nv;
  
