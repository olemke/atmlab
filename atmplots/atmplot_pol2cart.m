function atmplot_pol2cart( r, lat, varargin )


DEG2RAD = constants( 'DEG2RAD' );


[y1,x1] = pol2cart( DEG2RAD * lat(1), r(1) );

for j = 2 : length( r ) 
  [y2,x2] = pol2cart( DEG2RAD * lat(j), r(j) );
  plot( [x1 x2], [y1 y2], varargin{:} );
  x1 = x2;
  y1 = y2;
end
