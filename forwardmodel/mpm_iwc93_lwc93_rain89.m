% MPM_IWC93_LWC93_RAIN89   Complex refractivity for IWC, LWC and rain.
%
%    Returns the complex refractivity following MPM93 for ice water,
%    liquid water and rain. 
%
% FORMAT   [nr,alpha] = mpm_iwc93_lwc93_rain89(iwc,lwc,rain,v,t)
%
% OUT      nr     Real part of refractivity [-] (a value just above 1).
%          alpha  Absorption [1/m]
% IN       iwc    Ice water content [g/m3]
%          lwc    Liquid water content [g/m3]
%          rain   Rain rate [mm/h]    
%          v      Frequency [Hz]
%          t      Temperature [K]

% HISTORY: 2003-03-07  Created by Patrick Eriksson


function [nr,alpha] = mpm_iwc93_lwc93_rain89(iwc,lwc,rain,v,t)


%=== Local variables
%
theta = 300 / t;
v_ghz = v/1e9;


nr  = 1;
nc  = 0;



%=== Ice water
%
if iwc < 0
  error('Negativ IWC is not allowed.');
elseif iwc > 10
  error('IWC > 10 g/m3 is not allowed.');
elseif iwc > 0
  a   = ( theta - 0.1871 ) * exp( 17.0 - 22.1*theta );
  b   = ( (0.223/(1-0.993/theta))^2 + 6.33/theta - 1.31 ) * 1e-5;
  ep  = 3.15;
  epp = a/v_ghz + b*v_ghz;
  nc  = nc + 1.5 * iwc / 0.916 * ( 3*epp / ( (ep+2)^2 + epp^2 ) ); 
end



%=== Liquid water
%
if lwc < 0
  error('Negativ LWC is not allowed.');
elseif lwc > 5
  error('LWC > 5 g/m3 is not allowed.');
elseif lwc > 0
  g1  = 20.20 - 146*(theta-1) + 316*(theta-1)^2;
  g2  = 39.8 * g1;
  e0  = 77.66 + 103.3*(theta-1);
  e1  = 0.0671 * e0;
  e2  = 3.52;
  tmp = v_ghz*v_ghz + g1*g1;
  a   = (e0-e1)/tmp;
  b   = (e1-e2)/tmp;
  ep  = e0 - v_ghz*v_ghz * ( a + b );
  epp = v_ghz * ( g1*a + g2*b );
  nc  = nc + 1.5 * lwc * ( 3*epp / ( (ep+2)^2 + epp^2 ) ); 
end



%=== Rain
%
if rain < 0
  error('Negativ rain rate is not allowed.');
elseif rain > 5
  error('Rain rate > 25 mm/h is not allowed.');
elseif rain > 0
  %
end



%=== Convert to absorption per meter [1/m]
%
%alpha = 4 * pi * v * nc/1e6 / constants('SPEED_OF_LIGHT');
alpha = 0.182 * v_ghz * nc;