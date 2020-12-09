% POS2G   Earth's gravitational constant
%
%    Returns g as a function of latitude and altitude.
%
%    Apparent gravity is considered, i.e. g includes effect of the
%    centrifugal force.
%
% FORMAT   g = pos2g( lat [, z] )
%        
% OUT   g     Gravitational constant
% IN    lat   Latitude(s).
% OPT   z     Altitude(s). Default 0 m.

% 2006-12-06   Created by Patrick Eriksson.


function g = pos2g( lat, z )
  
if any( lat<-90 )  |  any( lat>90 )
  error( 'Only latitudes inside [-90,90] are allowed.' );
end

if nargin < 2
  z = 0;
elseif any( z<-1e3 )  |  any( z>1000e3 )
  error( 'Only altitudes inside [-1,1000] km are allowed.' );  
end
  

lat = constants('DEG2RAD') * lat;

 
% Expression based on https://en.wikipedia.org/wiki/Gravity_of_Earth
%
g = 9.780327 * ( 1 + 0.0053024*sin(lat).^2 - 0.0000058*sin(2*lat).^2) - ...
                                                                   3.086e-6*z;

% Move to apparent gravity, i.e. include effect of the centrifugal force. See:
% A first course in Atmospheric Thermodynamics by G. Petty (page 89)
% As well as https://glossary.ametsoc.org/wiki/Apparent_gravity
%
g = g - ((7.29e-5)^2*6378e3)*cos(lat).^2