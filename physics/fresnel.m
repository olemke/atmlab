% FRESNEL   Fresnel formulas for surface reflection
%
%    The amplitude reflection coefficients for a flat surface are
%    calculated. Note that these are the coefficients for the
%    amplitude of the wave. The power reflection coefficients are
%    obtained as
%
%       r = abs(R)^2
%    
%    The refractive index can be complex. The refractive index and 
%    the dielectric constant, epsilon, are releated as
%
%      n = sqrt(epsilon)
%
% FORMAT   [Rv,Rh,theta2] = fresnel(n1,n2,theta1)
%        
% OUT   Rv       Reflection coefficient for vertical polarisation.
%       Rh       Reflection coefficient for horisontal polarisation.
%       theta2   Angle for transmitted part.
% IN    n1       Refractive index for medium of incoming radiation.
%       n2       Refractive index for reflecting medium.
%       theta1   Angle between surface normal and incoming radiation.

% 2004-04-30   Created by Patrick Eriksson.


function [Rv,Rh,theta2] = fresnel(n1,n2,theta1)

DEG2RAD = constants('DEG2RAD');

theta1	  = DEG2RAD * theta1;
theta2    = asin( real(n1) * sin(theta1) / real(n2) );

costheta1 = cos( theta1 );
costheta2 = cos( theta2 );

Rv = (n2*costheta1-n1*costheta2)./(n2*costheta1+n1*costheta2);
Rh = (n1*costheta1-n2*costheta2)./(n1*costheta1+n2*costheta2);

theta2 = theta2 / DEG2RAD;