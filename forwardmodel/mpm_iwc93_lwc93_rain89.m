% MPM_IWC93_LWC93_RAIN89   Complex refractivity for IWC, LWC and rain.
%
%    Returns the complex refractivity following MPM93 for ice water,
%    liquid water and rain. 
%
% FORMAT   [nr,alpha] = mpm_iwc93_lwc93_rain89(iwc,lwc,rain,v,t)
%
% OUT      nr     Real part of refractivity.
%          alpha  Absorption [1/m]
% IN       iwc    Ice water content [g/m3]
%          lwc    Liquid water content [g/m3]
%          rain   Rain rate [mm/h]    
%          v      Frequency [Hz]
%          t      Temperature [K]

% HISTORY: 2003-03-07  Created by Patrick Eriksson


function [nr,alpha] = mpm_iwc93_lwc93_rain89(iwc,lwc,rain,v,t)


theta = 300 / t;

ni    = 0;
nr    = 0;

%=== Ice water
%
if iwc < 0
  error('Negativ IWC is not allowed.');
elseif iwc > 1
  error('IWC > 1 g/m3 is not allowed.');
elseif iwc > 0
  a   = ( theta - 0.171 ) * exp( 17.0 - 22.1*theta );
  b   = ( (0.223/(1-0.993/theta))^2 + 6.33/theta - 1.31 ) * 1e-5;
  ep  = 3.15;
  epp = a/v + b*v;
  ni  = 1.5 * iwc / 0.916 * ( 3*epp / ( (ep+2)^2 + epp^2 ) ); 
end

