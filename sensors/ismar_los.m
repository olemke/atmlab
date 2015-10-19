% ISMAR_LOS   Calculates zenith and azimuth angles mased on "ISMAR data"
%
% Calculates ARTS zenith and azimuth angles corresponding to ISMAR or MARSS
% L1B data.
%
% The default is to calculate the angles for each view. The obtained zenith
% angles should then match the L1b field sensor_view_angle (besides
% difference in reference direction).
%
% By setting *do_met_mm* to true, the returned za and aa values are instead
% the values expected by the MetMM system.
%
% In both cases, the output can be used to fill sensor_los when doing 3D
% calculations:
%
%   sensor_los = [za,aa];
%
% FORMAT   [za,aa] = ismar_los(I,ind,[instrument,do_metmm])
%
% OUT   za           Zenith angles
%       aa           Azimuth angles
% IN    I            Structure with ISMAR measurement data
%       ind          Index of data to be used
% OPT   instrument   Name of instrument, 'ISMAR' or 'MARSS'. 
%                    Default is 'ISMAR'.
%       do_metmm     Flag to trigger angles matching definitions of ARTS'
%                    MetMM system. Default is false.

% 2015-08-10  Created by Bengt Rydberg
% 2015-10-19  PE, some definition issues sorted out, and extended to cover 
%             non MetMM case

function [za,aa] = ismar_los(I,ind,varargin)
%
[instrument,do_metmm] = optargs( varargin, { 'ismar', false } );


% Mounting pitch angle
switch upper(instrument)
 case 'MARSS'
  pitch0 = 3;   
 case 'ISMAR'
  pitch0 = -3;
 otherwise
  error( 'Not recognised choice for *instrument*.' );
end


yaw   = I.platform_orientation( ind );
pitch = I.platform_pitch_angle( ind ) + pitch0;
roll  = I.platform_roll_angle( ind );       

n       = length(yaw);
[za,aa] = deal( zeros( n, 1 ) );


% Pitch and roll are reversed in the expressions used below
%
pitch = -pitch;
roll  = -roll;


for i = 1 : n
  
  % Create a vector for nominal direction
  if do_metmm
    vnom = [0 0 -1];
  else
    za_famm = I.angle(ind(i));
    if za_famm <= 180
      [x,y,z,dx,dy,dz]=geocentricposlos2cart( 1, 0, 0, za_famm, 0 );
    else
      [x,y,z,dx,dy,dz]=geocentricposlos2cart( 1, 0, 0, 360-za_famm, 180 );      
    end
    % Differences in corrdinate system makes that x and z are swapped
    vnom = [ dz, 0 , dx ];
  end

  % yaw/pitch/roll rotations are taken from http://planning.cs.uiuc.edu/node102.html:
  Y = [ cosd(yaw(i))  -sind(yaw(i))  0; ...
        sind(yaw(i))   cosd(yaw(i))  0; ...
           0              0          1 ];
  P = [ cosd(pitch(i))   0  sind(pitch(i)); ...
           0             1     0          ; ...
       -sind(pitch(i))   0  cosd(pitch(i)) ];
  R = [ 1    0               0         ; ...
        0  cosd(roll(i))  -sind(roll(i)); ...
        0  sind(roll(i))   cosd(roll(i)) ]; 

  %r1 = Y*P*R*vnom';   % This is the correct order according to we page above.
  r1 = Y*R*P*vnom';   % This gives perfect match with L1b data

  % calculate zenith angle
  za(i) = acosd( r1'*[0 0 1]'  );
  
  % calculate the azimuth angle
  if ~do_metmm
    [dum,dum,aa(i)] = cart2geocentric( r1(1), r1(2), r1(3) );
  end
end

% For MetMM, the reference direction is always taken as the anti-flight direction!
if do_metmm
  aa = shift_longitudes( yaw+180, -180, 180 );
end
