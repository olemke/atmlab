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


rqre_scalar( 'dim', dim, 1, 3 );


[grid11,grid12,grid13] = extract_grids( dim, Q1 );
[grid21,grid22,grid23] = extract_grids( dim, Q2 );


if dim == 1

  F = regrid( qarts_get(F0), grid11, grid21, 'linear' );

elseif dim == 2

  F = regrid( qarts_get(F0), grid11, grid21, grid12, grid22, 'linear' );

elseif dim == 3

  F = regrid( qarts_get(F0), grid11, grid21, grid12, grid22, ...
                                                    grid13, grid23, 'linear' );
end



function [grid1,grid2,grid3] = extract_grids( dim, Q )

if isfield( Q, 'P_GRID' )
  grid1 = log( qarts_get( Q.P_GRID ) );
elseif isfield( Q, 'GRID1' )
  grid1 = log( qarts_get( Q.GRID1 ) );
else
  error('Neither field P_GRID or GRID1 found.');
end

if dim >= 2
  if isfield( Q, 'LAT_GRID' )
    grid2 = qarts_get( Q.LAT_GRID );
  elseif isfield( Q, 'GRID2' )
    grid2 = qarts_get( Q.GRID2 );
  else
    error('Neither field LAT_GRID or GRID2 found.');
  end
else
  grid2 = NaN;
end

if dim >= 3
  if isfield( Q, 'LON_GRID' )
    grid3 = qarts_get( Q.LON_GRID );
  elseif isfield( Q, 'GRID3' )
    grid3 = qarts_get( Q.GRID3 );
  else
    error('Neither field LON_GRID or GRID3 found.');
  end
else
  grid3 = NaN;
end


