function [spos,slos] = pathpoint2sensorposlos(dim,ppos,plos,r_sensor)
  

%- Check input
%
rqre_scalar( 'input variable *dim*', dim, 1, 3 );
rqre_datatype( 'vector', 'input variable *ppos*' )
rqre_datatype( 'vector', 'input variable *plos*' )
rqre_scalar( 'input variable *r_sensor*', r_sensor, 0 );
%
if length(ppos) ~= dim
  error('Length of *ppos* must be equal to *dim*.' );
end
%
if  ~((dim<=2 | length(plos)==1)  | (length(plos)==2)) 
  error('Length of *plos* does not match *dim*.' );
end
%
if plos(1) < 90
  error( 'The function accepts only zenith angles > 90 degrees.' );
end


%- Make calculations always in 3D
%
pos                 = zeros(1,3);
pos(1:dim)          = ppos;
%
los                 = zeros(1,2);
los(1:length(plos)) = plos;


%- Length from path point to sensor radius (by law of cosines)
%
deg2rad = constants( 'DEG2RAD' );
a       = pos(1)*cos(deg2rad*los(1));
l       = a + sqrt( a*a + r_sensor*r_sensor - pos(1)*pos(1) );


%- Position and LOS of sensor
%
spos = zeros(1,3);
slos = zeros(1,2);
%
[x,y,z,dx,dy,dz] = arts_poslos2cart( pos(1), pos(2), pos(3), los(1), los(2) );
%
[spos(1),spos(2),spos(3),slos(1),slos(2)] = ...
                     arts_cart2poslos( x+l*dx, y+l*dy, z+l*dz, -dx, -dy, -dz );


