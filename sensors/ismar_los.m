% ISMAR_LOS   Calculates zenith and azimuth angles from ISMAR data
%
% Calculates zenith and azimuth angles of ISMAR 
% for nominal nadir measurements taking into account
% of the platform yaw, pitch, and roll and instrument 
% mounting angles.
% That is, this calculation is independent of the
% actual scan angle.
%
% These angles can be used to fill sensor_los when doing 
% 3D calculations and using the met-mm system.
%
% FORMAT   [za,aa] = ismar_los(I,ind)
%
% OUT   za    Zenith angles
%       aa    Azimuth angles
% IN    I     Structure with ISMAR measurement data
%       ind   Index of data to be used

% 2015-08-10  Created by Bengt Rydberg

function [za,aa] = ismar_los(I,ind)
  

yaw   = I.platform_orientation( ind );
pitch = I.platform_pitch_angle( ind ) - 3;  % take into account of a 3 degree 
roll  = I.platform_roll_angle( ind );       % mounting angle of the sensor



n       = length(yaw);
[za,aa] = deal( zeros( n, 1 ) );


for i = 1 : n
  % calculate the zenith and azimuth angle of the sensor from yaw, pitch, and roll angle
  % of the platform. That is, the actual zenith and azimuth angle for a nominal
  % nadir measurements
  %
  % yaw pitch and roll rotations are used from http://planning.cs.uiuc.edu/node102.html:
  % rotate a downward pointing vector in order to calculate the zenith and azimuth angle
  % of the platform 

  Y = [ cosd(yaw(i))  -sind(yaw(i))  0; ...
        sind(yaw(i))   cosd(yaw(i))  0; ...
           0              0          1 ];
  P = [ cosd(pitch(i))   0  sind(pitch(i)); ...
           0             1     0          ; ...
       -sind(pitch(i))   0  cosd(pitch(i)) ];
  R = [ 1    0               0         ; ...
        0  cosd(roll(i))  -sind(roll(i)); ...
        0  sind(roll(i))   cosd(roll(i)) ]; 

  [r1] = Y*P*R*[0 0 -1]';

  % calculate zenith angle
  za(i) = acosd( r1'*[0 0 1]'  );
  
  % caclulate the azimuth angle
  [dum,dum,aa(i)] = cart2geocentric( r1(1), r1(2), r1(3) );

end
  
