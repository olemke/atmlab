% BINNING   Simple "binning" of data
%
%  Binning means here data reduction by simple averaging of neighbouring
%  data. The ranges of averaging are given by *xlims*. This is a 2 column
%  matrix, where first column is lower limit and second column upper
%  limit. More precisely, the averaging ranges are [xlims(:,1),xlims(:,2)[.
%
%  The data abscissa is given as columns in *x*. There are two
%  options. Either *x* is a single column, which is interpreted as a common
%  abscissa for all data cases. Otherwise, *x* and *Y* must have same size.
%
% FORMAT   [xp,Yb,N] = binning( xlims, x, Y )
%        
% OUT   xp      Centre points of each bin.
%       Yb      Binned data.
%       N       Number of data points in each binned value.
% IN    xlims   X-grid limits for binning. A 2 column matrix.
%       x       Original x-grid.
%       Y       Data to be binned.

% 2007-02-22   Created by Patrick Eriksson.

function [xp,Yb,N] = binning( xlims, x, Y )

  
if size( xlims, 2 ) ~= 2
  error( 'The variable *xlims* must be a matrix with 2 columns.' );  
end
  
nx = size( x, 2 );
ny = size( Y, 2 );
  
if nx > 1  &  nx ~= ny
  error( 'Mismatch in size between *x* and *Y*.' );
end

if size(x,1) ~= size(Y,1)
  error( 'Mismatch in size between *x* and *Y*.' );
end

xp = mean( xlims' )';

nb = size( xlims, 1 );
Yb = zeros( nb, ny );
N  = zeros( nb, ny );

for ix = 1 : nx

  if nx == 1
    ind = 1 : ny;
  else
    ind = ix;
  end

  for i = 1 : nb
    
    ib = find( x(:,ix) >= xlims(i,1)  &  x(:,ix) < xlims(i,2) );

    N(i,ind)  = length( ib );
    Yb(i,ind) = mean( Y(ib,ind)' )';
    
  end
end
  