% GRIDSELECT2D   Simple selection of 2D grids
%
%    The function needs a set of realisations of the quantity for which the
%    grids shall be selected. These realisations are given along dim. 3 of the
%    3D variable *Af*, are provided on a sufficient fine grid that 
%    representation errors can be neglected and shall span the possible cases 
%    that shall be represented. 
%
%    The dimension of Af shall be [ xf, yf, number of realisation ]
%
%    The grid is selected by first including the end points of *xf* and *yf*. 
%    The coarse representation is transformed to the fine one, and a new grid 
%    point is included where the maximum deviation is found (where all
%    realisations are considered in parallel). The point is included in
%    either *xc* or *yc*, depending on which that most effectively reduces
%    the deviation. This procedure is repeated until the coarse and 
%    representations deviates less then *tol*.
%
%    See also GRIDSELECT1D and GRIDSELECT3D.
%
% FORMAT   [xc,yc] = gridselect2D( xf, yf, Af, tol, repr, abs_or_rel )
%        
% OUT   xc          Obtained coarse grid for x dimension.
%       yc          Obtained coarse grid for y dimension.
% IN    xf          Reference fine grid for x dimension.
%       yf          Reference fine grid for y dimension.
%       Af          Reference data (a matrix) on fine grid.
%       tol         Acceptable tolarance.
%       repr        String describing representation used. Possible choices
%                   are equal to allowed 'methods' for *interp1*.
% OPT   abs_or_rel  String telling if tolarance is in absolute ('abs') or
%                   relative ('rel') units. Default is 'abs'.

% 2004-09-23   Created by Patrick Eriksson.


function [xc,yc] = gridselect2D( xf, yf, Af, tol, repr, abs_or_rel )

if nargin < 6
  abs_or_rel = 'abs';
end

nx = length( xf );
ny = length( yf );


%=== Check input
%
if ~isvector( xf )
  error( 'Input argument *xf* must be a vector.' );
end
%
if ~isvector( yf )
  error( 'Input argument *yf* must be a vector.' );
end
%
if ndims( Af ) ~= 3  |  ~isnumeric( Af )
  error( 'Input argument *Af* must be a 3D matrix.' );
end
%
if size( Af, 1 ) ~= nx  &&  size( Af, 2 ) ~= ny
  error( 'Sizes of *xf*/*yf* and *Af* do not match.' );
end
%
if strcmp( abs_or_rel, 'rel' )  &  any( Af == 0 )
   error( 'With *abs_or_rel* = ''rel'', *Af can not contain zeros.' );
end

xind = 1;
yind = 1;
xip  = nx;
yip  = ny;
e    = tol*2;

nrel = size( Af, 3 );
Ac   = zeros( size( Af ) );

while e > tol

  xind = sort( [ xind xip ] );
  yind = sort( [ yind yip ] );

  for i = 1 : nrel
keyboard
    Ac(:,:,i) = interp2( xf(xind), yf(yind), Af(xind,yind,i), xf, yf, repr );
  end

  if strcmp( abs_or_rel, 'abs' )
    [e,ip] = max( max( abs( Ac - Af ), [], 2 ) );
  elseif strcmp( abs_or_rel, 'rel' )
    [e,ip] = max( max( abs( (Ac - Af)./Af ), [], 2 ) );
  else
    error( ...
      sprintf('Unknown error type (%s). Can only be ''abs'' or ''rel''.', ...
                                                                abs_or_rel ) );
  end
end


xc = xf(ind);


return

%= Some code for plotting
%

E = Ac - Af;

plot( xf, mean( E, 2 ), 'r-', xf, max( E, [], 2 ), 'b--', ...
      xf, min( E, [], 2 ), 'g--' );
ylabel( 'Absolute deviation' )
legend( 'Mean deviation', 'Highest deviation', 'Lowest deviation' );