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
% FORMAT    e = eps_water_liebe93( f, t )
%        
% OUT   e   Complex dielectric constant
% IN    f   Frequency
%       t   Temperature

% 2004-10-22   Created by Patrick Eriksson


function e = eps_water_liebe93( f, t )

source = 'paper';

switch source

  % Expressions directly from the Liebe 93 paper
  case 'paper'
    %
    theta = 300 ./ t;
    fghz  = f/1e9;
    %
    e0 = 77.66 + 103.3 * ( theta - 1 );
    e1 = 0.0671 * e0;
    e2 = 3.52;
    %
    g1 = 20.2 - 146 * ( theta -1 ) + 316 * ( theta -1 ).^2;
    g2 = 39.8 * g1;
    %
    e  = e0 - fghz .* ( (e0-e1)./(fghz+i*g1) + (e1-e2)./(fghz+i*g2) );


  % Corrected expressions from the WATS report, provided by T. Kuhn
  case 'wats'
    %  
    theta = 300 ./ t;
    fghz  = f/1e9;
    %
    e0 = 77.66 + 103.3 * ( theta - 1 );
    e1 = 0.0671 * e0;
    e2 = 3.52;
    %
    g1 = 20.2 - 146 * ( theta -1 ) + 316 * ( theta -1 ).^2;
    g2 = 39.8 * g1;
    %
    a  = (e0-e1)./(fghz.^2+g1.^2);
    b  = (e1-e2)./(fghz.^2+g2.^2);   % The report says g1 here. Wrong!
    %
    e  = e0 - fghz.^2 .* ( a +b ) + i * fghz .* ( g1*a + g2*b );
end