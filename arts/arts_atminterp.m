% ARTS_ATMINTERP   Regridding of atmospheric fields
%
%   Mimics the interpolation done in ARTS. For example, log(p) is used as
%   vertical coordinate. 
%
%   There two options to specify grids, valid for both Q1 and Q2.
%   The first option is that Q is a structure, including the fields 
%   P_GRID, LAT_GRID and LON_GRID.
%   The second option is that Q is an ArrayOfGrids, where the first
%   grid is takan as p_grid etc.
%
%   Grids for dimensions not used can be left out, on both cases.
%
%   Any extrapolation results in NaN.
%
% FORMAT   F = arts_atminterp( dim, Q1, F0, Q2 )
%        
% OUT   F     Interpolated field.
% IN    dim   Atmospheric dimensionality.
%       Q1    Original grids. See further above.
%       F0    Field to interpolate.
%       Q2    New grids. See further above.

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

if isstruct(Q)  &  isfield( Q, 'P_GRID' )
  grid1 = log( qarts_get( Q.P_GRID ) );
elseif iscell(Q)
  grid1 = log( Q{1} );
else
  error('No recognised format for Q (p dimension).');
end 

if dim >= 2
  if isstruct(Q)  &  isfield( Q, 'LAT_GRID' )
    grid2 = qarts_get( Q.LAT_GRID );
  elseif iscell(Q)
    grid2 = Q{2};
  else
    error('No recognised format for Q (lat dimension).');
  end 
else
  grid2 = NaN;
end

if dim >= 3
  if isstruct(Q)  &  isfield( Q, 'LON_GRID' )
    grid3 = qarts_get( Q.LON_GRID );
  elseif iscell(Q)
    grid3 = Q{3};
  else
    error('No recognised format for Q (lon dimension).');
  end 
else
  grid3 = NaN;
end


