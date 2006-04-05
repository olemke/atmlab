% BOXCARFILTER   Rectangular filtering of data series
%
%    A rectangular filtering is performed. For each abscissa point, the 
%    filtered value is based on all data points inside +-xw/2.
%    The distance between the abscissa points is considered when calculating
%    filtered values. Data are weighted with data range they represent.
%
% FORMAT   yf = boxcarfilter(x,y,xw)
%        
% OUT   yf   Filtered data.
% IN    x    Data abscissa.
%       y    Data values. Can be a vector with same length as *x* or
%            a matrix. A second case the data series must be stored as columns.
%       xw   Width (total) of the filter. 

% 2006-04-05   Created by Patrick Eriksson.


function yf = boxcarfilter(x,y,xw)

if ~(size(y,1)==1 & length(y)==length(x)  |  size(y,1)==length(x))
  error('Size of *y* does not match size of *x*.');
end



yf = y;

l  = diff( grid2edges(x) );

if size(y,1) > 1
  l = vec2col(l);
  for i = 1:length(x)
    ind     = find( abs(x-x(i)) < xw/2 );
    yf(i,:) = sum(y(ind,:).*repmat(l(ind),1,size(y,2))) / sum(l(ind));
  end
else
  l = vec2row(l);
  for i = 1:length(x)
    ind   = find( abs(x-x(i)) < xw/2 );
    yf(i) = sum(y(ind).*l(ind)) / sum(l(ind));
  end
end