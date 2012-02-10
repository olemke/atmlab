% PATHPOINT2SENSORPOSLOS   Match sensor pos/los with a geometrical LOS point
%
%   Calculates sensor position and line-of-sight (LOS) based on a point
%   along a pure geometrical (no refraction) propagation path, and the
%   sensor altitude (given as the radius, from goid center). Both a position
%   and a LOS for the propagation path point must be given.
%
%   Positions and LOS are given following the ARTS coordinate systems.
%  
%   Positions have dimensions (r), (r,lat) and (r,lat,lon) for 1D/2D/3D.
%   
%   A LOS is given as (za) for 1D and 2D, and (za,aa) for 3D, where za is
%   zenith angle, and aa is azimuth angle. A negative za for 2D means a LOS
%   towards lower latitudes.
%
% FORMAT   [spos,slos] = pathpoint2sensorposlos(dim,ppos,plos,r_sensor)
%        
% OUT   spos       Sensor position.
%       slos       Sensor line-of-sight.
% IN    dim        Atmospheric dimensionality
%       ppos       Point on propagation path.
%       plos       Line-of-sight at *ppos*.
%       r_sensor   Radius for sensor position.

% 2007-05-16   Created by Patrick Eriksson.


function [spos,slos] = pathpoint2sensorposlos(dim,ppos,plos,r_sensor)
                                                                         %&%
                                                                         %&%
%- Check input                                                           %&%
%                                                                        %&%
rqre_alltypes( dim, {@istensor0,@iswhole} );                             %&%
rqre_in_range( dim, 1, 3 );                                              %&%
rqre_datatype( ppos, @isvector );                                        %&%
rqre_datatype( plos, @isvector );                                        %&%
rqre_datatype( r_sensor, @istensor0 );                                   %&%
rqre_in_range( r_sensor, 0 );                                            %&%
%                                                                        %&%
if length(ppos) ~= dim                                                   %&%
  error('Length of *ppos* must be equal to *dim*.' );                    %&%
end                                                                      %&%
%                                                                        %&%
if  ~( (dim<=2 & length(plos)==1)  | (dim==3 & length(plos)==2) )        %&%
  error('Length of *plos* does not match *dim*.' );                      %&%
end                                                                      %&%
%                                                                        %&%
if abs(plos(1)) < 90                                                     %&%
  error( 'The function accepts only zenith angles > 90 degrees.' );      %&%
end                                                                      %&%


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
[x,y,z,dx,dy,dz] = geocentricposlos2cart( pos(1), pos(2), pos(3), ...
                                          los(1), los(2) );
%
[spos(1),spos(2),spos(3),slos(1),slos(2)] = ...
                   cartposlos2geocentric( x-l*dx, y-l*dy, z-l*dz, dx, dy, dz );


%--- dim < 3 specific stuff
%
if dim == 1
  %
  spos = spos(1);
  slos = slos(1);

elseif dim == 2
  %
  spos = spos(1:2);
  slos = slos(1);
  
  % Handle special case of negative zenith angle for 2D
  if spos(2) > ppos(2)
    slos = -slos;
  end
end
