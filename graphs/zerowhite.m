% ZEROWHITE   Creates a colormap with white for 0
%
%    This function creates a color map that gives white for values around
%    zero.
%
%    Examples on color codings:
%
%     *rgb* : negative - zero - positive
%     ------------------------------
%       nzp : red - white - blue
%       pzn : blue - white - red
%       npz : red - white -green
%       znp : green - white - blue
%       pzp : black - white - pink
%
%    The return arguments of this function are used as
%       contourf(D,v)
%       colormap(cmap)
%
% FORMAT   [cmap,v] = zerowhite( D, nclrs, rgb, blackl )
%        
% OUT   cmap     Color map.
%       v        Vector with contour level values.
% IN    D        Data matrix to be displayed
%       nclrs    Number of colors to use between 0 and max absolute
%                value. If this is a vector it is taken to define
%                explictly the contour intervals. This is handy if
%                you want to create nice intervals, such as [-2 -1
%                .5 .5 1 2]. The intervals do not have to be evenly
%                spaced.
% OPT   rgb      Coding for red, green and blue color by a string of length 3.
%                The character 'p' means that positive values will be weighted
%                with the corresponding color. The character 'n' refer to
%                negative values. The character 'z' means max weight at zero.
%                Default is 'nzp'.
%       blackl   Level of blackness. A value between 0 and 1, where 0 means
%                that no black is blended in for high value, and 1 means
%                that max absolute value will be completely black.  
%                Default is 0.5.

% 2003-12-06   Created by Patrick Eriksson.
% 2004-04-07   Stefan Buehler:
%              Added the option to have prescribed contour intervals.
%              Does not yet work correctly. 

function [cmap,v] = zerowhite( D, nclrs, rgb, blackl )


%= Default values
%
if nargin < 3
  rgb = 'nzp';
end
if nargin < 4
  blackl = 0.5;
end


%= Check input
%
if ~ischar(rgb)  &  length(rgb)~=3
  error( 'The argument *rgb* must be string of length 3' );
end
%
if any( ~( (rgb=='n') + (rgb=='p') + (rgb=='z') ) )
  error( 'The argument *rgb* can only include the characters n, z and p.' );
end

%= Get max/min values
%

if length(nclrs)==1
  % Make nclrs contour levels.
  minv = min( min( D ) );
  maxv = max( max( D ) );
  amax = max( abs( [ minv, maxv ] ) );
  dv = amax / nclrs;

  %= Create vector with contour levels
  %
  if abs( minv ) < abs( maxv )
    v = fliplr( (maxv-dv/2) : -dv : (minv-dv) );
    w = ( 1 + blackl ) * ( v' + dv/2 ) / amax;
  else
    v = (minv-dv/2) : dv : (maxv+dv);
    w = ( 1 + blackl ) * ( v' - dv/2 ) / amax;
  end

else
  
  v = nclrs;
  
  % Take dv from the first contour interval:
  dv = v(2)-v(1);
  
  minv = min( v );
  maxv = max( v );
  amax = max( abs( [ minv, maxv ] ) );

  %= Create vector with contour levels
  %
  if abs( minv ) < abs( maxv )
    w = ( 1 + blackl ) * ( v' + dv/2 ) / amax;
  else
    w = ( 1 + blackl ) * ( v' - dv/2 ) / amax;
  end
end



%= Set up vectors for positive, negative and mixing colour
%
%
p      = w + 1;
ind    = find( p < 0 );
p(ind) = 0;
ind    = find( p > 1 & p < 2);
p(ind) = 1;
ind    = find( p >= 2);
p(ind) = 3 - p(ind);
%
z      = 1 - abs( w );
ind    = find( z < 0 );
z(ind) = 0;
%
n      = -w + 1; 
ind    = find( n < 0 );
n(ind) = 0;
ind    = find( n > 1 & n < 2);
n(ind) = 1;
ind    = find( n >= 2);
n(ind) = 3 - n(ind);


%= Put color map together
%
cmap = zeros( length(w), 3 );
%
cmap(:,1) = eval( rgb(1) ); 
cmap(:,2) = eval( rgb(2) ); 
cmap(:,3) = eval( rgb(3) ); 


