% ARTS_POLYBASIS_FUNC   Polynomial basis functions (following arts-2)
%
%   This function matches the arts internal function polynomial_basis_func, used
%   to set up the basis functions for jacobian polynomial representations. For
%   example, arts_polybasis_func( Q.SENSOR_RESPONSE.F_BACKEND, 1 ) gives the
%   "weight" for changing the backend frequencies to match a retrieved frequency
%   stretch.
%
% FORMAT   b = arts_polybasis_func( grid, polcoeff )
%        
% OUT      b          Calculated basis function.
% IN       x          The grid 
%          polcoeff   Polynomial coefficient.

% 2009-10-22   Created by Patrick Eriksson.


function b = arts_polybasis_func( grid, polcoeff )
  
if polcoeff == 0
  %
  b = ones( size(grid) );
  
else
  %
  x1 = min( grid );
  b = ( grid - x1 ) / ( 0.5*( max(grid) - x1 ) ) - 1;
  if polcoeff > 1
    b = b.^ polcoeff;
  end
  b = b - mean(b);
end