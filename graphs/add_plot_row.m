% ADD_PLOT_ROW   Adds a row of plots to a figure.
%
%    This function works in a similar way as *subplot*, but this function
%    can be called repeatedly, and each row of plots can have a different
%    number of plots.
%
%    The size allocated for the plots is specified by giving lengths with
%    respect to the vertical size of the figure area. This is valid both
%    for the width and height. This means that if the width and height are set
%    to the same value, the plot will be square. All plots have the same height
%    but the width can differ. Note that the size given does not include the
%    space used for axis numbering and label text, it includes only the actual
%    plot area. This means that if there shall be any space left for y-labels
%    the plot widths cannot add up to 1.
%
%    The plots can either be flushed to the right (flush='r'), flushed to
%    the left (flush='l'), or be centered. For left and right flushing, 5%
%    of the width is used for a margin on the side of the flush direction.
%    The rest of the width not occupied of plots is evenly distributed
%    between the plots. If you want to get nice margins between rows with
%    different numbers of plots, remember that the avaliable width for
%    left and right flushing is 95% of the total width. An example:
%       h1 = add_plot_row(0.3,[0.3 0.3],0.1,'r');
%       h2 = add_plot_row(0.3,[0.775],0.1,'r');
%
%    while for centered plots, this works better
%       h1 = add_plot_row(0.3,[0.3 0.3],0.1,'c');
%       h2 = add_plot_row(0.3,[0.8],0.1,'c');
%
%    as the avaliable width is here 100% of the total width. Make sure that
%    the figure window has sufficient height for both plot rows before
%    trying these examples. The width must be increased before creating the
%    first rows the widths set are normalised to the size, and the size
%    of the plots will change if the size of the figure is changed.
%
%    For normal plotting with the y-axis to the left, right flushing should
%    be the standard choice, and it is also default.
%
% FORMAT   h = add_plot_row(height,widths[,vspacing,flush])
%        
% OUT   h          Handles to the created plots (axes).
% IN    height     Height of plots. This length is given in fractions of the 
%                  vertical size. 
%       widths     Widths of each plot as a vector. This lengths are given in
%                  fractions of the vertical size. 
% OPT   vspacing   Vertical spacing to plots above, or to the top of figure
%                  area. This length is given in fractions of the horisontal
%                  size. Default is 0.1.
%       flush      Flushing of plots. See further above. Default is 'r'.

% 2002-12-11   Created by Patrick Eriksson.


function h = add_plot_row(height,widths,vspacing,flush)


%=== Basic check of input
%
min_nargin( 2, nargin );
%
if ~isscalar( height )
  error(' The argument *height* must be a scalar.');
end
%
if ~isvector( widths )
  error(' The argument *width* must be a vector.');
end
%
if sum( widths ) > 1
  error( 'The sum *widths* can not be > 1.');  
end
%
if nargin < 3
  vspacing = 0.1;
else
  if ~isscalar( vspacing )
    error(' The argument *vspacing* must be a scalar.');
  end
end
%
if nargin < 4
  flush = 'r';
else
  if ~( strcmp(flush,'l') | strcmp(flush,'c') | strcmp(flush,'r') )
    error('The argument *flush* must be ''l'', ''c'' or ''r''.');
  end
end 


%=== Handle to figure
%
hf = gcf;


%=== Convert the height to be valid with respect to the vertical size (and
%=== not the horisontal).
%
%- The case of unit='norm' forces the conversion to be done in a more tricky
%- way, than required for other units.
%
%- Save unit and change to cm
unit1 = get( hf, 'unit' );
set( hf, 'unit', 'ce' );
%
pos    = get( hf, 'Position' );
height = height * pos(3) / pos(4);
%
%- Reset unit
set( hf, 'unit', unit1 );


%=== Check at what height the plot row shall be placed
%
%- Handle to childrens of the figure
hc = get( hf, 'Children' );
%
if isempty( hc )
  hbase = 1;
else
  %- Loop children and look at what height they start
  hbase = pos(2) + pos(4);
  for ic = 1 : length(hc)
    cpos = get( hc(ic), 'position' );
    if cpos(2) < hbase
      hbase = cpos(2);
    end 
  end
end
%
hbase = hbase - vspacing - height;
%
if hbase < 0
  error('The given height is larger than free vertical space.');
end


%=== Calculate the horisontal space between the plots
%
%- The space between plots is made twice the space to the figure borders
%
nplots = length( widths );
%
if flush == 'c'
  hspacing = (1 - sum(widths) ) / nplots;
else
  hspacing = (0.95 - sum(widths) ) / nplots;
end


%=== Place the axes
%
if flush == 'l'
  vbase = 0.05;
elseif flush == 'c'
  vbase = hspacing/2;
else
  vbase = hspacing;
end

h     = zeros( nplots, 1 );
%
for ip = 1 : nplots
  h(ip) = axes( 'position', [vbase hbase widths(ip) height] );
  vbase = vbase + widths(ip) + hspacing;
end
