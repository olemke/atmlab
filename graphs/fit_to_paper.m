function fit_fig_to_paper(psize,border)


%=== Basic check of input
%
min_nargin( 1, nargin );


%=== Default values
%
if nargin < 2
  border = 25;   % mm
end


%=== Get paper size (in mm)
%
if strcmp( psize, 'a4' )
  width  = 210;
  height = 297;

else
  error( sprintf( 'Invalid paper type (%s).', psize ) );
end


%=== Store present units
%
h = gcf;
%
unit1 = get( h, 'Unit' );
unit2 = get( h, 'PaperUnit' );


%=== Set unit cm
%
set( h, 'Unit', 'ce' );
set( h, 'PaperUnit', 'ce' );


%=== Scale set lengths
%
width  = width / 10;
height = height / 10;
border = border / 10;


%=== Set positions
%
set( h, 'Position', [border border width-2*border height-2*border] );
set( h, 'PaperPosition', [border border width-2*border height-2*border] );

set( h, 'Unit', unit1 );
set( h, 'PaperUnit', unit2 );
