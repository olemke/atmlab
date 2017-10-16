% FM_O3_111GHZ   A very simple forward model for ozone around 110.8 GHz
%
%    This function is a simple forward model for ground-based measurements,
%    of ozone at 110.836 GHz. Doppler broadening is treated highly
%    approximate, by setting a lower allowed value for pressure width, 
%    Only the ozone transition of concern is considered.
%
% FORMAT   [tb,Kvmr,Krel,dz] = fm_o3_111ghz(z,p,t,o3,v,el,tb0)
%        
% OUT   tb      Brightness temperature spectrum.
%       Kvmr    Weighting functions [K/VMR].
%       Krel    Weighting functions [K/100%].
%       dz      Height of each atmospheric layer.
% IN    z    Vector of vertical altitudes.
%       p    Pressures at *z*.
%       t    Temperatures at *z*.
%       o3   Ozone VMR profile.
%       v    Frequency vector.
%       el   Elevation angle of measurement (90=zenith)
%       tb0  Brightness temperature of incoming radiation at the
%            top of the atmosphere.

% 2004-11-18   Created by Patrick Eriksson 


function [tb,Kvmr,Krel,dz] = fm_o3_111ghz(z,p,t,o3,v,el,tb0)

%=== Some constants
KB      = 1.380662e-23;         % Boltzmann constant [J/K]
P0      = 1.013e5;              % Std. ground pressure [Pa]
T0      = 300;                  % Std. ground temperature [K]
V0      = 110.83604e9;          % Centre frequency [Hz]
S0      = 0.3724e-16;           % Line strength [m2Hz]
GA0     = 2.37e9;               % Pressure broadening at ground level [Hz]
X       = 0.73;                 % Temperature exponent [-]
ga_min  = 75e3;                 % A lower limit, to roughly include Doppler broad.

nz = length(z);                 % Number of altitudes


%=== Init. Tb
%
tb      = repmat( tb0, length(v), 1 );
%
if nargout > 1
  K  = zeros( length(v), nz );
  dz = zeros( nz, 1 );
end


%= Ensure column vectors
%
v = vec2col( v );


%=== Loop altitudes downwards
for i = nz:-1:1

  %= Calculate the vertical distance of the present layer.
  %= The values are treated to be valid halfway to the neighbouring points
  %= Treat first and last altitude seperately
  if i == 1
    dz(i) = z(2) - z(1);
  elseif i == nz
    dz(i) = z(nz) - z(nz-1);
  else
    dz(i) = ( z(i+1) - z(i-1) ) / 2;
  end

  %= The pressure broadening width
  ga = max( ga_min, GA0 * (p(i)/P0) * (T0/t(i))^X );

  %= The number of ozone molecules
  n  = o3(i) * p(i) / KB / t(i);

  %= Calculate the absorption
  k  = n * S0 * ga ./ ((v-V0).^2+ga^2) / pi;  

  %= The transmission, considering the elevation angle
  dl = dz(i) / sin(el*pi/180);
  tr = exp( -dl * k );
 
  %= Do Jacobian
  if nargout > 1
    K(:,i)   = dl * k .* ( t(i) - tb ) / o3(i);
    if i < nz
      ind      = i+1:nz;
      K(:,ind) = K(:,ind) .* repmat(tr,1,nz-i);
    end
  end

  %= Update tb
  tb = tb.*tr + t(i).*(1-tr);
 
end


Kvmr = K;
Krel = K .* repmat( vec2row(o3), length(v), 1 );