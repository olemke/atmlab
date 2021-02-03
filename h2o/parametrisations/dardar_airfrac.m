% DARDAR_AIRFRAC returns air fraction for ice particles
%
% This function returns the air fraction for ice particles as assumed in
% DARDAR retrievals.
%
% FORMAT          airfrac = dardar_airfrac(de_grid, [, version])
%
% OUT             airfrac   vector with airfraction
%
% IN              de_grid   particle size vector [m]
%
%        version 'v2': Parameterisation used for DARDAR v2.1. It is defined 
%                      in Delanoe et al 2014, Normalized particle size 
%                      distribution for remote sensing application. JGR.
%                      The arameterisation is also found in Table 1 of
%                      Cazenave et al, AMT, 2019. This option is default.
%                'vX': New parameterisation, as defined in Table of Cazenave et
%                      al, AMT, 2019. It will be used in the next DARDAR version.

% Created by Bengt Rydberg 2017-02-01

function [airfrac] = dardar_airfrac( de_grid, varargin )

[version] = optargs( varargin, {'v2'} );

rhoice = constants('DENSITY_OF_ICE');


switch version
  case 'v2'
    %
    ar = 0.6;
    rhoair = 1;
    
    b1 = 2.91;
    a1 = 1.677e-1 * 100^b1 * 1e-3;
    b2 = 1.91;
    a2 = 1.66e-3 * 100^b2 * 1e-3;
    b3 = 1.9;
    a3 = 1.9241e-3 * 100^b3 * 1e-3;
    %
    dmax = 1/ar^(1/3)*de_grid;
    %
    rhovec1 = (6 / pi * a1 * dmax.^b1) ./ de_grid.^(3);
    rhovec2 = (6 / pi * a2 * dmax.^b2) ./ de_grid.^(3);
    rhovec3 = (6 / pi * a3 * dmax.^b3) ./ de_grid.^(3);
    % 
    airfrac = zeros( size(de_grid) );
    %
    for i= 1 : length(de_grid)
      if dmax(i) < 100e-6
        airfrac(i) = (rhoice - rhovec1(i)) / (rhoice - rhoair);
      elseif dmax(i) < 300e-6
        airfrac(i) = (rhoice - rhovec2(i)) / (rhoice - rhoair);
      else  
        airfrac(i) = (rhoice - rhovec3(i)) / (rhoice - rhoair);
      end
    end

    
  case 'vX'
    %
    b = 2.2;
    a = 7.1e-6 * 100^b;
    %
    dmax    = (pi * rhoice / 6 / a * de_grid.^3).^(1/b);
    rhovec  = (6 / pi * a * dmax.^b) ./ dmax.^(3);
    airfrac = max( 0, 1 - rhovec / rhoice );
  
  otherwise
    error( 'Allowed options for *version* are: ''v2'' and ''vX''.' );
end
end

