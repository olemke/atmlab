% ARTS_ATMINTERP   Regridding of atmospheric fields
%
%   Mimics the interpolation done in ARTS. For example, log(p) is used as
%   vertical coordinate. 
%
%   Both Q1 and Q2 are assumed to have fields P_GRID, LAT_GRID and LON_GRID,
%   though fields for dimensions not used can be left out. 
%
%   Any extrapolation results in NaN.
%
% FORMAT   F = arts_atminterp( dim, Q1, F0, Q2 )
%        
% OUT   F     Interpolated field.
% IN    dim   Atmospheric dimensionality.
%       Q1    Structure with original grids.
%       F0    Field to interpolate.
%       Q2    Structure with new grids.

% 2006-08-18   Created by Patrick Eriksson


function F = arts_atminterp( dim, Q1, F0, Q2 )


if dim == 1

  F = regrid( qarts_get(F0), log(qarts_get(Q1.P_GRID)), ...
                             log(qarts_get(Q2.P_GRID)), 'linear' );

elseif dim == 2

  F = regrid( qarts_get(F0), log(qarts_get(Q1.P_GRID)), ...
                             log(qarts_get(Q2.P_GRID)), ...
                    qarts_get(Q1.LAT_GRID), qarts_get(Q2.LAT_GRID), 'linear' );

elseif dim == 3

  F = regrid( qarts_get(F0), log(qarts_get(Q1.P_GRID)), ...
                             log(qarts_get(Q2.P_GRID)), ...
                    qarts_get(Q1.LAT_GRID), qarts_get(Q2.LAT_GRID), ...
                    qarts_get(Q2.LON_GRID), qarts_get(Q2.LON_GRID), 'linear' );

else
  error('Atmospheric dimensionality must be 1-3.');
end