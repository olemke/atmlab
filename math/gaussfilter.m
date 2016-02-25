% GUASSFILTER   Gauss filtering of data series
%
%    A simple gaussian filtering is performed. The filter is cut at +-4
%    standard deviations.
%
%    The data are assumed to be equidistant, but gaps in the data series are
%    allowed. Parts of the filter extending outside the data range are
%    neglected. The response is normalised for each point and if y equals
%    one everywhere, also yf will be one everywhere.
%
% FORMAT   yf = gaussfilter(x,y,xw)
%        
% OUT   yf   Filtered data.
% IN    x    Data abscissa.
%       y    Data values. Must be given as a column vector or a matrix.
%       xw   Width (total) of the filter. 

% 2006-04-05   Created by Patrick Eriksson.


function yf = gaussfilter(x,y,xw)

if size(y,1) ~= length(x)
  error('Size of *y* does not match size of *x*.');
end
%
if ~issorted(x)
  error('The vector *x* must be sorted.');
end


%= Set-up output variable
%
yf = y;


%= Make sure that *x* is a column vector
%
x = vec2col(x);


%= Calculate "1 std dev"
%
si = fwhm2si( xw );


for i = 1:length(x)

  % Calculate distance and determine data points to consider  
  d       = abs( x - x(i) );
  ind     = find( d < si*4 );

  % Calculate weights
  w = gauss( x(ind), si, x(i) );

  % Filter
  yf(i,:) = sum(y(ind,:).*repmat(w,1,size(y,2))) / sum(w);

end

