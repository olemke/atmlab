% EXPAND2INF   Exands data for extrapolation of data
%
%   Grids are expanded to -"Inf" and "Inf". Both increasing and decreasing 
%   grids are accepted (no strict check, only comparison of two first values).
%
%   "Inf" is set to 1e99. It was first tried to actually use Inf, and this
%   worked for single interpolations (interpolation to a single position),
%   but not for parallel interpolation to several positions (for some
%   unknown Matlab "feature").
%
%   Data matrix is expanded correspondingly where end values are duplicated to
%   positions of Inf positions. Data are thus assumed to be constant outside
%   end points. This procedure can be combined with all Matlab interpolation 
%   options ('linear', 'cubic', etc.),  beside 'spline' which results in
%   NaN.
%
%   Only data with dimension <= 3 are handled.
%   If no grids are given, *A* is then assumed to be a scalar (no expansion).
%
% FORMAT   [A2,x2,y2,z2] = expand2inf( A [, x, y, z] )
%        
% OUT   A2  Expanded data.
%       x2  Expanded grid in dimension in 1.
%       y2  Expanded grid in dimension in 2.
%       z2  Expanded grid in dimension in 3.
% IN    A   Data to be interpolated.
% OPT   x   Grid in dimension in 1.
%       y   Grid in dimension in 2.
%       z   Grid in dimension in 3.

% 2007-05-21   Created by Patrick Eriksson.


function [A2,x2,y2,z2] = expand2inf(A,x,y,z)
  
dim = nargin - 1;


% Can all this be done in a more efficient way? 
% Quick implementation ...


% Dimension 0
%
if dim == 0
  if max(size(A)) > 0
    error( 'No input grids imply scalar *A*.' );
  end
  %
  return
end


if dimens(A) > dim
  error( 'Dimension of *A* and number of input grids differ.' );
end

% Dimension 1
%
if size(A,1) ~= length(x)
  error( 'Mismatch in size between *x* and dimension of 1 of *A*.' );
end
%
x2 = expand_grid( x );
%
if dim == 1
  A2 = [ A(1,1); A(:,1); A(end,1) ];
  return
end


% Dimension 2
%
if size(A,2) ~= length(y)
  error( 'Mismatch in size between *y* and dimension of 2 of *A*.' );
end
%
y2 = expand_grid( y );
%
if dim == 2
  A2 = [ A(1,1)   A(1,:)   A(1,end);    ...
         A(:,1)   A        A(:,end);    ... 
         A(end,1) A(end,:) A(end,end) ];
  return
end


% Dimension 3
%
if size(A,3) ~= length(z)
  error( 'Mismatch in size between *z* and dimension of 3 of *A*.' );
end
%
z2 = expand_grid( z );
%
if dim == 3
  A2 = zeros( [size(A,1)+2,size(A,2)+2,size(A,3)+2] );
  %
  for i = 1:size(A,3)
    A2(:,:,i+1) = [ A(1,1,i)   A(1,:,i)   A(1,end,i);    ...
                    A(:,1,i)   A(:,:,i)   A(:,end,i);    ... 
                    A(end,1,i) A(end,:,i) A(end,end,i) ];
  end  
  A2(:,:,1) = A2(:,:,2);
  A2(:,:,end) = A2(:,:,end-1);  
  return
end






function x = expand_grid(x)
  if length(x) == 1  |  x(2) > x(1)
    x = [ -1e99; vec2col(x); 1e99 ];
  else
    x = [ 1e99; vec2col(x); -1e99 ];
  end
return