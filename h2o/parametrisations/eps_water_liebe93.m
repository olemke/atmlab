% EPS_WATER_LIEBE93   Dielectric constant for pure water according to Liebe 93
%
%    Provides the complex dielectric constant following the Liebe 1993
%    paper.
%
%    Note that the function *epswater93* solves the same task. This function
%    was primarily implemented to compare if different versions of the 
%    mathematical expressions give the same result (which they did). In fact,
%    this function contains two parallel versions, giving identical
%    results. This function uses just SI units for input arguments, in 
%    contrast to *epswater93*.
%
%    The actual limits of the parameterisation are not known. The following
%    limits are here applied:
%      f: [ 10 MHz, 1000 GHz] 
%      t: [ -40 C, 100 C ] 
%
% FORMAT    e = eps_water_liebe93( f, t )
%        
% OUT   e   Complex dielectric constant
% IN    f   Frequency
%       t   Temperature

% 2004-10-22   Created by Patrick Eriksson


function e = eps_water_liebe93( f, t )

% Expressions directly from the Liebe 93 paper

theta = 300 ./ t;
fghz  = f/1e9;

if fghz<0.01  |  fghz>1000
  error('Valid range for frequency is 0.01-1000 GHz'); 
end
if t<233  |  t>374
  error('Valid range for temperature is 233-374 K'); 
end

e0 = 77.66 + 103.3 * ( theta - 1 );
e1 = 0.0671 * e0;
e2 = 3.52;

g1 = 20.2 - 146 * ( theta -1 ) + 316 * ( theta -1 ).^2;
g2 = 39.8 * g1;

% epswater93 uses 146.4, but the 1993 paper says just 146
% With 146.4 exactly the same results are obtained.

e  = e0 - fghz .* ( (e0-e1)./(fghz+i*g1) + (e1-e2)./(fghz+i*g2) );