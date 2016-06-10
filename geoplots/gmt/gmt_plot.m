function filename = gmt_plot(in,field)
% GMT_PLOT plotting interface for GMT (Generic Mapping Tools)
%
% The function is basically a wrapper that calls GMT shell commands using easy
% to use matlab arguments.
% Try <a href="matlab:help test_gmt">test_gmt</a> for some examples on how to use the function.
% Preferably, the data should be CENTERED if the data is gridded. Plotting
% gridded data is faster than plotting ungridded data. This GMT wrapper supports
% GMT 5.
%
% OUT   filename  The filename of the figure.
%
% IN    in        A structure with input data and options. See below for
%                 a detailed description of the structure.
%
% OPT   field     The string name of the structure element that contains
%                 the data to be plotted. If no field is given, 'data'
%                 is assumed.
%
% Easy example: If you just want to plot some data..
%                 in.somefield = data2plot
%                 in.lon  = longitudes
%                 in.lat  = latitudes
%
%                 file = gmt_plot(in,'somefield');
%
% see STRUCTURE CONTENTS below for the rest of the available arguments
%
% VIEWING THE PLOT:
% The easiest thing to do is to define a viewer in your startup file.
%
% Add something like the following to your startup file')
% gmtlab( 'OUTDIR', '/name/a/favorite/directory' ) %% The default directory to put plots
% gmtlab( 'PSVIEWER','gv');             %% set viewer for .ps files
% gmtlab( 'PDFVIEWER','xpdf -z width'); %% set viewer for .pdf files
% --> gmtlab( 'OPEN_COMMAND','gnome-open'); %% set a general open command <-- This one is enough
% gmtlab( 'VERBOSITY',1); %% This outputs stdout on the screen.
%
% Structure contents:
%
% MANDATORY INPUT
%
% 1) in.(field) % the data (default is field='data' i.e. in.data)
% 2) in.lat     % the corresponding latitudes
% 3) in.lon     % the corresponding longitudes
%
% If your data is ungridded the dimensions of the manditory input
% (lat,lon.data) must be the same.
% i.e isequal(size(in.lat),size(in.lon),size(in.data))
%
%
% NOTE: 1) If your data is UNGRIDDED I recommend setting
%          in.nearneighbor.resolution = Deg (something suitable).
%       2) gmt_plot automatically detects if the data is gridded or not
%
%
% HOW TO READ THIS HELP
% in.variable   in = expect input type
%               ex = Explanation/Example
%               de = Default value/behavior
%
% NOTE: If "def" is missing for a variable it means the variable is not used by default
%
%                  types: %s=character or string
%                         %f=numeric/logical
%                         {}=cell
%--------------------------------------------------------------------------
%
% OPTIONS
%
%                     ------------
% in.add_offset        in:     %f
%                      ex:     The offset you want to automatically apply to the
%                              provided data. This is often provided 
%                              by convention in the attributes of a variable
%                              (from netcdf). See also scale_factor and
%                              fill_value
%                     ------------
% in.cptfile           in:     %s
%                      ex:     Path to a colortable (*.cpt)
%                     ------------
% in.ctable           See below how to set the color table (default=rainbow)
%                     ------------
% in.color_background  in:  %s
%                      ex:  Set the background color (values less than range)
%                      def: '0/0/0' ('black')
%                     ------------
% in.color_foreground  in:  %s
%                      ex:  Set the foreground color (values greater than range)
%                      def: '255/255/255' ('white')
%                     ------------
% in.color_nan         in:     %s
%                      ex:     Set the color of NaNs
%                      def:    '125/125/125' ('grey')
%                     ------------
% in.colorrange       See below how to make your own colortables
%                     ------------
% in.contourline      See below how to draw contour lines on the map
%                     ------------
% in.datarange         in:     [%f, %f]
%                      ex:     Min and max range of data values to display
%                     ------------
% in.display           in:     %f
%                      ex:     If false, file created but not displayed
%                      def:    true
%                     ------------
% in.filename          in:     %s
%                      ex:     'yourfilename', or 'yourfilename.jpg'
%                      def:    Generated from title. The filetype is determined by the file
%                           ending given by your filename, e.g., any of bla.{pdf,jpg,eps,tif,png,ps}
%                     ------------
% in.fill_value        in:     %f
%                      ex:     The fill value to NaN-out. This is often provided
%                              by convention in the attributes of a variable
%                              (from netcdf). See also scale_factor and
%                              add_offset
%                     ------------
% in.figuretype        in:     %s
%                      ex:     'eps','pdf','BMP','jpg','PNG','PPM' (not recommended), or 'tif'.
%                           If the figure type is included in the filename,
%                           e.g., file.png, or file.jpg, then that file type is
%                           used, however defining in.figuretype will
%                           override this.
%                      def:    'pdf'
%                     ------------
% in.fontsize_annot_primary
%                      in:     %s or %f (if %f, unit is assumed from in.proj_length_unit)
%                      ex:     The size of the font, e.g., '2c'=2cm for e.g., the axis.
%                              Setting this will also change the size of the
%                              fonts of the annotations for the legend. If you
%                              want a different size for the legend
%                              annotations, set in.legend.fontsize.
%                      def:    '14p'
%                     ------------
% in.font_annot_primary
%                      in: %s or %f
%                      ex: There are 35 fonts to choose from. Either provide a
%                          number 0-34 or a string (case sensitive) of the
%                          font to use. E.g., 'Helvetica' (0), 'Times-Roman' (4),
%                          'Courier' (8), etc. See "gmtdefault" man page for the
%                          whole list. You can even setup other fonts
%                          (see also <a href="http://gmt.soest.hawaii.edu/doc/5.1.1/GMT_Docs.html">GMT Docs</a>                      def: 'Helvetica' ('0')
%                     -------------
% in.fontsize_annot_secondary
%                      in:     %s or %f (if %f, unit is assumed from in.proj_length_unit)
%                      ex:     The size of the font, e.g., '2c'=2cm for e.g., the axis.
%                              Setting this will also change the size of the
%                              fonts of the annotations for the legend. If you
%                              want a different size for the legend
%                              annotations, set in.legend.fontsize.
%                      def:    '14p'
%                     ------------
% in.font_annot_secondary
%                      in: %s or %f
%                      ex: There are 35 fonts to choose from. Either provide a
%                          number 0-34 or a string (case sensitive) of the
%                          font to use. E.g., 'Helvetica' (0), 'Times-Roman' (4),
%                          'Courier' (8), etc.
%                      def: 'Helvetica' ('0')
%                     -------------
% in.font_title        in: %s or %f
%                      ex: There are 35 fonts to choose from. Either provide a
%                          number 1-35 or a string (case sensitive) of the
%                          font to use. E.g., 'Helvetica' (0), 'Times-Roman' (4),
%                          'Courier' (8), etc. See "gmtdefault" man page for the
%                          whole list
%                      def: 'Helvetica' ('0')
%                     --------------
% in.fontsize_title    in:    %s or %f (if %f, unit is assumed from in.proj_length_unit)
%                      ex:     Title size
%                      def:    '36p' (points)
%                     --------------
% in.func              in:     function handle
%                      ex:     Apply this function to the data field. e.g. @(x)(nanmean(x(:,:,:,2),3))
%                      def:    none
%                     --------------
% in.gmtset            in:     {%s,%s,...}
%                      ex:     Cell with one or more gmtset commands.
%                              E.g. in.gmtset={'gmt set FORMAT_FLOAT_OUT %3.1e','gmt set ...'}
%                     ------------
% in.grdimage          in:     %s
%                      ex:     'gmt grdimage OPT > filename.ps', explicitly sets
%                              the grdimage GMT command directly.
%                     ------------
% in.keep_files        in:     %f
%                      ex:     If you don't want to delete intermediate files.
%                              If you are really after the shell script that make
%                              the plot see in.makeScriptAndStop 
%                      def:    false
%                     ------------
% in.map_title_offset
%                      in:     %s or %f (if %f, unit is assumed from in.proj_length_unit)
%                      ex:     Moves the title in y-dir on the page
%                      def:    '0c' (cm)
%                     ------------
% in.makecpt           in:     %s
%                      ex:     'gmt makecpt OPT > filename.ps', explicitly sets the
%                              makecpt GMT command directly.
%                     ------------
% in.makeScriptAndStop
%                      in:  %f
%                      ex:  For the developer and those who want the shell script
%                           generated by this program
%                      def: false
%                     -------------
% in.mask              in:     function handle
%                      ex:     @(x)(x<0); This masks all values less 0 with NaN
%                      def:    no mask by default
%                     ------------
% in.nearneighbor:    See below on nearneigbour
%                     ------------
% in.nlevels           in:     %d
%                      ex:     Refers to the number of contour levels (converted to
%                            stepsize using datarange)
%                      def:    best fit for nice tickvalues
%                     ------------
% in.force_nlevels     in:     (logical)
%                      ex:     If set to true, keep nlevels even if it
%                              exceeds  the number of unique values.  If
%                              set to false, nlevels is reduced to the
%                              number of unique values if it exceeds it.
%                      def:    false
%                     ------------
% in.locations         See below how to plot locations on the map
%                     ------------
% in.nodata            in:     %f
%                      ex:     If you only want a map (compatible with all options)
%                      def:    false
%                     ------------
% in.outdir            in:     %s
%                      ex:     'name/a/directory'
%                      def:    gmtlab('OUTDIR')  ('.' if not set)
%                     ------------
% in.plotPlacement     in:     %s
%                      ex:     String of global plotPlacements (see "man grdimage" for info)
%                      def:    '-Ya5 -Xa5'
%                     ------------
% in.proj             See below on map projections/size
%                     ------------
% in.proj_length_unit
%                      in:     %s
%                      ex:     You can explicitly specify the unit used for
%                              distances and lengths by appending c (cm), i (inch), m
%                              (meter), or p (points). When no unit is indicated the
%                              value will be assumed to be in the unit set by
%                              proj_length_unit. The default unit to use for all commands
%                              if none is given. This used to be called
%                              measure_unit in earlier versions but is now
%                              adapted to gmt5 conventions
%
%                      def:    'c'
%                     ------------
% in.psbasemap        See below on psbasemap
%                     ------------
% in.pscoast          See below on pscoast
%                     ------------
% in.pspoly           See below on pspoly how to draw shapes
%                     ------------
% in.pstext           See below on pstext write on the map
%                     ------------
% in.region            in:     %s
%                      ex:     '-180/180/-90/90'=global range, defined from
%                              sprintf('%f/%f/%f/%f',lon1,lon2,lat1,lat2)
%                      def:    determined by input lat/lon range
%                     ------------
% in.scale_factor      in:     %f
%                      ex:     The scale factor you want to automatically apply to the
%                              provided data. This is often provided 
%                              by convention in the attributes of a variable
%                              (from netcdf). See also add_offset and
%                              fill_value
%                     ------------
% in.stepsize          in:     %f
%                      ex:     The stepsize between data values. This overrides
%                              nlevels (-T/min/max/stepsize in makecpt)
%                      def:    determined by nlevels
%                     ------------
%
% in.tickval           in:     %f
%                      ex:     Vector of values to be used for ticks and data interval
%                      def:    Determined by datarange and stepsize
%                     ------------
% in.title             in:     %s
%                      ex:     Title of plot
%                      def     ''
%                     ------------
% in.treatAsGridded    in: %f
%                      ex:  1; This is a patch. It allows you to treat gridded data as ungridded.
%                           This can be useful if you think the
%                           internal interpolation for the plot projection is
%                           causing weird side effects (such as near NaN values)
%                      def: 0
%                     ------------
% in.unit              in:     %s
%                      ex:     String displayed on the y-axis of a legend
%                      def:    ''
%                     ------------
% in.xunit             in:     %s
%                      ex:     String displayed on the x-axis of a legend
%                      def:    ''
%                     ------------
%
% NOTE:             For SPECIAL CHARACTERS in a string (such as title) refer to the
%                   GMT cookbook  (<a href="http://gmt.soest.hawaii.edu/doc/5.1.0/index.html#the-cookbook">GMT Cookbook</a>)
%
% ======================
%  Structure options
% ======================
%
%---------------------------
%
% COLORRANGE
%
% NOTE: For your own CUSTOM COLORTABLE use in.colorrange.colors
% (see below). Assign a color to a relative value, e.g between 0-1, where
% 0 is for the minimum of the datarange and 1 is for the color of the
% maximum datarange. For example,
% in.colorrange.colors = {{0,'250/0/0''},{.3,'0/0/0'},{0.5,'0/255/0'},{1,'0/0/255'}},
% makes a colortable that goes from red to black to green to blue.
% Naturally you can also use the 'contour values' directly as long as you
% assign all levels a color.
%
%                     ----------------------
% in.colorrange.      | STRUCTURE with one or more of the following fields:
%
%  colors              in:     {{%d,%s},{%d,%s},etc.} %d is the data value, %s is the color
%                      ex:     {20,'255/0/0'} (red in RGB)
%                     ------------
%  color_model         in:     %s
%                      ex:     'RGB', 'HSV'
%                      def:    'RGB'
%                     ------------
%
%------------------------------------------------------------------------------------
%
% COLOR TABLE
%
% ---- string --------
% in.ctable            in:     %s
%                      ex:     See GMT color palettes
%                      def:    'rainbow'
%
%                      NOTE: 'mypolar' is a nice colortable for difference
%                      plots, and there are two additional optional
%                      arguments for this color table:
% ----- struct ---------
%
% in.ctable
%                     ------------
%       name           in:    %s
%                      ex:    'rainbow' | 'mypolar' | etc
%                     ------------
%       nwhite:        in:    %d
%                      ex:    The number of white contours around
%                             a reference value
%                      def:   determined by number of levels
%                     ------------
%       reference:     in:    %d
%                      ex:    Where to center the white color
%                      def:   mean(data(:))
%                     ------------
%
%                      Note:    Recommend set in.reference = 0 for
%                               difference plots, but any reference
%                               will work.
%
%
% ----------------------------------------------------------------------------
%
% LEGENDS:
%
% in.extra_legend     structure containing:
%       name           in:     %s
%                      ex:     An associated string name. E.g., 'NaN','masked', etc...
%                      def:    mandatory
%                     ------------
%       type           in:     %s
%                      ex:     'bg','fg', or 'nan', means use the color for the background,
%                              foreground, or nan, given in in.color_background, in.color_foreground,
%                              in.color_nan. So far these are the only 3 options.
%                      def:    mandatory
%                     ------------
%      fontsize        in:     %s or %f (if %f, unit is assumed from in.proj_length_unit)
%                      ex:     '10c'
%                     ------------
%      see in.legend of more options
%                     ------------
% in.pscale            in:     %s
%                      ex:     'gmt psscale OPT > filename.ps', explicitly sets the
%                              psscale GMT command for the legend directly.
%                     ------------
% in.pscale_extra      in:     %s
%                      ex:     'gmt psscale OPT > filename.ps', explicitly sets the
%                           psscale GMT command for the extra legend directly.
%                     ------------
% in.savelegend        in:     %f
%                      ex:     Controls separate PDF for the legend.  If value
%                              is 0, only 1 file will be generated containing
%                              map+legend.  If value is 1, one file will be
%                              generated for map+legend and one file for
%                              legend only.  If value is 2, one file will be
%                              generated containing ONLY the map, and one
%                              containing ONLY the legend.  The legend will be
%                              stored in [in.filename '_legend.' extension] in
%                              the output directory.
%                      def:    false
%                     ------------
% in.legend            in:     %f
%                      ex:     Set to false if you don't want a legend. if in.legend
%                              is a structure, it's equivalent to in.legend = true
%                      def:    true
%                     ------------
%
% in.legend.          | STRUCTURE with one or more of the following fields:
%
%  fontsize
%                      in:     %s or %f (if %f, unit is assumed from in.proj_length_unit)
%                      ex:     Size of annotations in legend, e.g., '1c'=1cm
%                      def:    '14p'
%                     ------------
%  box_spacing         in:     %f. It has to be a number, and it seems to be in inches
%                      ex:     Space between legend boxes.
%                      def:    0 (side by side)
%                      NOTE:   If you set a non-zero number you'll also get rid of
%                              the color gradient, i.e. each box will have it's own color
%                     ------------
%  equalboxwidth       in:     %f
%                      ex:     If the legend color boxes have to be the same size, 1
%                      def:    false (-L option)
%                     ------------
%  extra_legend        in:     %s
%                      ex:     more instrucrtions to psscale. e.g. '-Li'
%                      def:    none
%                     ------------
%  justify             in:     %s
%                      ex:     sets the alignment. The alignment refers to the part of the legend 
%                              that will be mapped onto the (x,y) point. Choose a 2 character 
%                              combination of L, C, R (for left, center, or right) and 
%                              T, M, B for top, middle, or bottom. e.g., BL for lower left.
%                      def:    'BR'
%                     ------------
%  length              in:     %s or %f (if %f, unit is assumed from in.proj_length_unit)
%                      ex:     Toggle the length of the legend bar (e.g., '3.9i'=3.9 inch).
%                              Use negative value to reverse the legend.
%                              See also width,xpos,ypos,orientation for legend
%                      def:    '3.9i'
%                     ------------
%  lineThick           in:     %f
%                      ex:     Thickness of the boxline surrounding legend
%                      def:    0.2
%                     ------------
%  map_annot_offset_primary
%                      in:     %s
%                      ex:     Move tick annotations to the right by x units, e.g. '.5i' (.5 inches)
%                     ------------
%  map_tick_length_primary
%                      in:     %s or %f (if %f, unit is assumed from in.proj_length_unit)
%                      ex:     The length of the ticks, e.g., '.5c'=.5cm
%                     ------------
%  map_tick_length_secondary
%                      in:     %s or %f (if %f, unit is assumed from in.proj_length_unit)
%                      ex:     The length of the ticks, e.g., '.5c'=.5cm
%                     ------------
%  orientation         in:     %s
%                      ex:     If you want a horizontal/vertical legend input 'h'/'v'.
%                      def:    Determined by map dimensions
%                     ------------
%  sidebar             in:     %f
%                      ex:     Input scalar 0, 1, 2, or 3. Indicates none,
%                              below range only, above range, or both
%                      def:    Determined from data
%                     ------------
%  tick_annotations
%                      in:     {%s,%s,...}
%                      ex:     {'','','middle','',''}. Number of annotations must be = nlevels, and all
%                              cell elements must be strings (or empty strings)
%                     ------------
%  tick_annotation_format
%                      in:     %s
%                      ex:     '%3.1e'
%                     ------------
%  tick_centering      in:     %f
%                      ex:     Have tick annotation at the center of the boxes
%                      def:    false (edges)
%                     ------------
%  tick_spacing        in:     %f
%                      ex:     If you want to manually decide how the ticks in the
%                             legend should be spread. x=> every xth data value,
%                             1=>same number of ticks as datarange
%                      def:    One tick per data level
%
%                   NOTE: This option is desirable if you have many
%                           data levels.
%                     ------------
%  xoffset             in:     %s
%                      ex:     offset the color scale by dx away from the refpoint
%                              point in the direction implied by justify
%                      def:    '-1c'
%                     ------------
%  yoffset             in:     %s
%                      ex:     offset the color scale by dy away from the refpoint
%                              point in the direction implied by justify
%                      def:    '-1c'
%                     ------------
%  width               in:     %s or %f (if %f, unit is assumed from in.proj_length_unit)
%                      ex:     Toggle the width of the legend bar.
%                              See also length,xpos,ypos, orientation for legend
%                      def:    '.2i'
%------------------------------------------------------------------------------------
%
% NEARNEIGHBOR
%
% i) A string to be used for the system call to invoke nearneighbor
% or
% ii) A structure with one or more of the following fields:
%
% in.nearneighbor.    |
%
%  search              in:     %s
%                      ex:     '30m' Search for data within 30 [arcmin]
%                      def:    Loosely based on the density of the data points
%                     ------------
%  resolution          in:     %f [degree]
%                      ex:     1 [deg] (== 60minuntes) looks for values withing 1 [deg]
%                      def:    Loosely based on the density of the data points, or avialable memory
%
%
%  memGB               in:     %f
%                      ex:     1 = allow up to 1Gib of memory to be used to make
%                              the map. This could be useful of you have high
%                              density and the default of 100Mib is not enough
%                              to represent the data in the resolution you want
%                      def:    0.1
% ------------------------------------------------------------------------
%
% PROJECTION
%
% in.proj           struct
%         projection   in:     %s
%                      ex:     See available projections in GMT manual.
%                      def:    'Q' (cylindric equidistant)
%                     ------------
%         center       in:     %f
%                      ex:     Center map at given longitude
%                      def:    0 [deg]
%                     ------------
%         map_width    in:     %s or %f (if %f, unit is assumed from in.proj_length_unit)
%                      ex:     Set width of map, e.g., '20c'=20cm
%                      def:    20 (cm)
%
% or the string:
%
% in.proj              in:     %s
%                      ex:     'projection/center/mapwidth'
%                      def:    'Q0/20' (see above)
%-----------------------------------------------------------------
% PSBASEMAP
%
% in.psbasemap
%
%     axes             in:     %s
%                      ex:     'WSne', annotates West and South of the map,
%                              but not North or East
%                      def:    'WSne'
%                     ------------
%     ticks            in:     %s
%                      ex:     '60g30/30g15'. The first value for both axis
%                              denotes the tick interval to annotate, the second
%                              value is the interval to draw the gridlines. xaxis and
%                              yaxis are separated by '/'. i.e (x-axis:
%                              'annot'g'grid'/ y-axis: 'annot'g'grid')
%                              Note: To remove gridlines set the second value to 0.
%                      def:    Determined by input lat/lon range.
%--------------------------------------------------------------------------
% PSCOAST
%
% --string ------
% in.pscoast           in:     %s (STRING COMMAND)
%                      ex:     'pscoast OPT > filename.ps', explicitly sets the
%                           pscoast GMT command.
% --logical -----
% in.pscoast           in:     %f (LOGICAL TURN OFF)
%                      ex:     If you don't want coastlines, set to false. If
%                              in.coast is a structure, it'll use the structure
%                              arguments to generate the pscoast command.
%                      def:    To generate coastlines
% --structure ---
%
% in.pscoast           | STRUCTURE with one or more of the following fields:
%
%  color               in:     %s
%                      ex:     Color of coast and rivers in rgb e.g. '255/255/255'
%                              gives white coastlines
%                      def:    COLOR_BACKGROUND
%                     ------------
%  features            in:     %f
%                      ex:     Don't plot features < in.features [km^2]
%                      def:    determined by lon/lat range
%                     ------------
%  resolution          in:     %s
%                      ex:     (f)ull, (h)igh, (i)ntermediate, (l)ow, and (c)rude
%                      def:    determined by lon/lat range
%                     ------------
%  rivers              in:     %s
%                      ex:     Display rivers. pscoast -Ioption (1-10, a,r,i,c)
%                      def:    '1' (=major rivers)
%                     ------------
%  width               in:     %s
%                      ex:     Width of coastlines
%                      def:    '.3p'
% ----------------------------------------------------------------
% LOCATION MARKERS:
%
%  for multiple locations define all fields according to :
%  in.locations(1).name = 'x',
%  in.locations(2).name = 'y', etc...
%
%                     ----------------------
%
% in.locations.       | Structure with one or more of the following fields:
%
%  lat                 in:     %f
%                      ex:     Latitude of marker
%                      def:    mandatory user input
%                     ------------
%  lon                 in:     %f
%                      ex:     Longitude of marker
%                      def:    manditory user input
%                     ------------
%  symbol              in:     %s
%                      ex:     Shape of marker. '' if you don't want one
%                      def:    'c' c=filled circle
%                     ------------
%  symbolsize          in:     %s
%                      ex:     Size of shape.
%                      def:    '5p'
%                     ------------
%  symbolcolor         in:     %s
%                      ex:     color of the symbol.
%                      def:    '0/0/0'
%                     ------------
%  symbolfill          in:     %s
%                      ex:     Color of marker
%                      def:    'white' (or '255/255/255')
%
% see pstext for the text arguments (text,fontsize,angle,font,justify,color)
% for in.locations.(textarg)
%
%--------------------------------------------------------------------------
%
% CONTOURS:
%
% in.contourline.     | Structure with one or more of the following fields:
%
% spacing              in:     %f
%                      ex:     Data interval between contours
%                     ------------
% range                in:     [%f %f]
%                      def:    in.datarange
%                     ------------
% linethick            in:     %f
%                     ------------
% more                 in:     %s
%                      ex:     Additional commands for GMT's grdcontour.
%                              E.g. '-T1c/0.001c:LH'
%
% If several contour plots should overlap define all fields according to:
%  in.grdcontour(1).spacing = x,
%  in.grdcontour(2).spacing = y, etc...
%--------------------------------------------------------------------------
%
% PSPOLY: DRAWING LINES and SHAPES ON MAP
%
% in.pspoly.coord
%                      in:     {[%f %f;%f %f;...] [%f %f;...]}
%                      ex:     Draws a polygon based on coordinates.
%                              Use one cell row per polygon region:
%                              {[lon1 lat1; lon2 lat2; ...];...}
%                     ------------
% in.pspoly.color      in:     contains strings: {'%f/%f/%f',...}
%                      ex:     RGB color or every region
%                      def:    {'0/0/0'} for every region (values range from 0 to 255)
%                     ------------
% in.pspoly.thick      in:     {%s,...}
%                      ex:     Thickness of lines
%                      def:    10p for every region boundary
%--------------------------------------------------------------------------
% PSTEXT: Write text on a map
%
% in.pstext            in:     %s
%                      ex:     'pstext OPT > filename.ps', explicitly sets
%                           the pstext GMT command directly. If in.pstext is a
%                           structure, it'll use the structure arguments to
%                           generate the command.
%                     ----------------------
%
% in.pstext.          | STRUCTURE with one or more of the following fields:
%
%  for multiple text entries define all fields according to :
%  in.pstext(1).text = 'example',
%  in.pstext(2).text = 'example2', etc...
%
%  lat                 in:     %f
%                      ex:     Centre word at this latitude
%                      def:    manditory user input
%                     ------------
%  lon                 in:     %f
%                      ex:     Centre word at this longitude
%                      def:    manditory user input
%                     ------------
%  text                in:     %s
%                      ex:     String to appear at lat/lon
%                      def:    manditory user input
%                     ------------
%  fontsize            in:     %s
%                      ex:     Text size in points
%                      def:    10p
%                     ------------
%  angle               in:     %f
%                      ex:     degrees counter-clockwise from horizontal
%                      def:    0 [deg]
%                     ------------
%  font                in:     %s or %f
%                      ex:     Sets the font type
%                      def:    1
%                     ------------
%  justify             in:     %f
%                      ex:     Sets the alignment
%                      def:    6
%                     ------------
%  color               in:     %s
%                      ex:     RGB text color
%                      def:    '0/0/0'
%
%--------------------------------------------------------------------------
%
%
% QUICK TEST
%
% in.lat  = -89.5:89.5;
% in.lon  = -179.5:179.5
% in.data = rand(length(in.lat),length(in.lon))
% file = gmt_plot(in);
%
% ACKNOWLEDGEMENTS
%
% Copyright ?1991?2014 by P. Wessel, W. H. F. Smith, R. Scharroo, J. Luis and F. Wobbe
%
% The Generic Mapping Tools (GMT) is free software; you can redistribute it
% and/or modify it under the terms of the GNU Lesser General Public License as
% published by the Free Software Foundation.
%
% See also: <a href="http://gmt.soest.hawaii.edu/doc/5.1.1/GMT_Docs.html">GMT Docs</a>
%
% Created by Salomon Eliasson and Oliver Lemke
% $Id$


if ~exist('field','var') && isfield(in,'data')
    field = 'data';
elseif isfield(in,'nodata') && in.nodata
    field = '';
end

assert(logical(exist('field','var')) || (isfield(in,'nodata')&&in.nodata) ,...
    ['atmlab:' mfilename ':badInput'],...
    'I need a "field".\nIf you want to plot the map with no data, input in.nodata=true')

check_input(in,field)

if isfield(in,'nodata')&&in.nodata
    out = set_GMT_plot(in);
else out = set_GMT_plot(in,field);
end

% make TEMPDIR and set atmlab('VERBOSITY') to gmtlab('VERBOSITY')
% cleanup after I'm done
out.tmpdir = create_tmpfolder();
p = pwd(); V = atmlab('VERBOSITY');
cleanupObject = onCleanup(@() gmtcleanup(out.tmpdir,p,out.keep_files,V));

atmlab('VERBOSITY',gmtlab('VERBOSITY'));

cd(out.tmpdir);

if out.gridded
    out.grdfile = [out.filename '.nc'];
    gmt_nc_save_gridded(out.lon,out.lat,out.(field),out.grdfile);
    logtext(1,'Writing grdfile: %s sucessfull\n',out.grdfile)
else
    if ~out.nodata
        out.ungriddedfile = [out.filename '.nc'];
        gmt_nc_save_ungridded(out.ungriddedfile,double(out.(field)),out.lat,out.lon);
    end
end

% main function
commands = create_gmt_earth(out);

% finalize

filename=setup_figure(out,commands);

end
%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%     ||||
%     vvvv
function in = set_GMT_plot(in,field)
%% SETUP %%


% Test is GMT is installed and in the path

[a,b] = system('which gmt');

if a == 1
    error(['gmtlab:' mfilename ':shell'],[ [ b '\n\n'],...
        'Either GMT is not installed\n',...
        'or\n',...
        'You need to add its installation directory to your PATH\n',...
        'e.g. in Matlab you can add the PATH via \n',...
        'setenv(''PATH'',[getenv(''PATH'') '':<GMTINSTALLDIR>/bin''])'])
else
    %This is gmt5
    [~,in.gmtVersion] = system('gmt --version');
    in.gmtVersion = strtrim(in.gmtVersion);
end
logtext(1,'Using GMT version %s\n',in.gmtVersion)

% SET DEFAULTS
% general
default.add_offset               = 0;
default.color_background         = '0/0/0';
default.color_foreground         = '255/255/255';
default.color_nan                = '150/150/150';
default.display                  = true;
default.fill_value               = [];
default.font_title               = 'Helvetica';
default.font_annot_primary       = 'Helvetica';
default.fontsize_annot_primary   = '14p';
default.font_annot_secondary     = 'Helvetica';
default.fontsize_annot_secondary = '10p';
default.fontsize_title           = '36p';
default.psbasemap.axes           = 'nSeW';
default.scale_factor             = 1;     
default.title                    = '';

in = optargs_struct(in,default);
clear default

default.keep_files               = false;

% how far the title is removed from the top of the map (depends on 'N' or 'n')
default.map_title_offset         = [num2str(-0.4+0.6*ismember('N',in.psbasemap.axes)) 'c'];


default.force_nlevels            = false;
default.makeScriptAndStop        = false;
default.nodata                   = false;
default.outdir                   = gmtlab('OUTDIR');
default.plotPlacement            = '-Xa5 -Ya5';
default.proj.projection          = 'Q';
default.proj.map_width           = 20;
default.proj_length_unit         = 'cm';
default.savelegend               = false;
default.treatAsUngridded         = false;
default.unit                     = '';
default.xunit                    = '';

in = optargs_struct(in,default);

clear default

in.outdir = sanitise(in.outdir);

if strcmp(in.outdir(1),'~')
    % netcdffunctions don't like ~ for home
    in.outdir = [getenv('HOME') '/' in.outdir(2:end)];
end

if system(sprintf('test -d %s -a -w %s',in.outdir,in.outdir))
    error(['gmtlab:' mfilename ':BadInput'],...
        'Either %s doesn''t exist, or atmlab does not have write access to %s',in.outdir,in.outdir)
end

if ~isempty(in.title)
    default.filename = ['gmtfile_' in.title '.pdf'];
    default.filename = strrep(default.filename,'/','-');
else default.filename = 'default.pdf';
end

in = optargs_struct(in,default);
clear default

% find default figuretype
b = regexp(in.filename,'\.');
if ~isempty(b)
    ft = in.filename(b(end)+1:end);
    if ismember(lower(ft),lower({'eps','pdf','BMP','JPEG','jpg','PNG','PPM','tif'}))
        default.figuretype = ft;
    else
        logtext(atmlab('OUT'),'figuretype: %s is not an available type. Will produce .pdf\n',ft);
        default.figuretype = 'pdf';
    end
    if ~isfield(in,'figuretype')
        in.filename=in.filename(1:b(end)-1);
    end
else
    default.figuretype = 'pdf';
end

in = optargs_struct(in,default);
clear default

in.filename = sanitise(in.filename);
in.title = regexprep(in.title,'([()])','\\$1');
in.title = regexprep(in.title,':',' ');

if in.nodata
    % If I only want an empty map, get the essentials and leave here.
    in = nodata(in);
    return
end

if ~ismember(field,fieldnames(in))
    error(['gmtlab:' mfilename ':BadInput'],...
        'no field by the name of "%s" found in input structure',field)
else
    in.fieldname  = field;
end

if ~strcmp(field,'mask') && isfield(in,'mask')
    in.(field)(in.mask(in.(field))) = NaN;
end

% apply a function to the data first
if ~strcmp(field,'func') && isfield(in,'func')
    logtext(1,'Applying "%s" to the datafield "%s"\n',func2str(in.func),field)
    in.(field) = in.func(in.(field));
end

% use fillvalue, add_offset, and scale_factor
if ~isempty(in.fill_value)
    in.(field) = double(in.(field));
    in.(field)(in.(field) == in.fill_value) = NaN;
end

if ~isempty(in.scale_factor)
    in.(field) = double(in.(field)).*in.scale_factor + in.add_offset;
end

% is the data plotable?
in = isdata(in,field);

% Check to see if the data is gridded or not
in = isgridded(in,field);

% special patch if you want to test if you want to switch to treating gridded
% data ungridded
in = treatAsUngridded(in,field);

% Also get rid of NaNs in the geodata (This only applies to ungridded data)
in = rmNaNsGeo_and_standardize_geodata(in,field);

% REGION
in = assign_region(in,field);

in = specialregion(in,field); %in case the region covers the dateline and is not continuous

% get default ticks for map borders
in = getDefaultTicks(in);

% DATARANGE
if ~in.nodata
    default.datarange     = getdatarange(in,field); %
    if any(isnan(in.(field)(:)))
        default.extra_legend = struct('name','NaN','type','nan'); % include NaNs in the legend
    else
        if isfield(in,'extra_legend') && strcmpi(in.extra_legend.name,'NaN') && in.gridded
            logtext(2,'Asked to make a NaN-legend although none are present in the data\n')
        end
        default.extra_legend = false;
    end
end

in = optargs_struct(in,default);
clear default
in.datarange = double(in.datarange);


assert(diff(in.datarange)>0,'atmlab:badInput','min=max in the datarange. Aborting...')

% COLORS & DATA REPRESENTATION
if ~isfield(in,'colorrange') % because this has precendence
    default.ctable      = 'rainbow';          % color palette
end
default.nlevels = get_nlevels(in);
in = optargs_struct(in,default);
clear default
[default.stepsize,default.tick_annotation_format]    = getstepsize(in);    % color level datastep interval
in = optargs_struct(in,default);
clear default

% LEGEND
in = setupLegend(in);

% extra LEGEND
if isstruct(in.extra_legend)
    in = setupXtraLegend(in);
end

end

function nl = get_nlevels(in)

dr = in.datarange;

% set some reasonable limits for how many levels I want and the min and max
% levels


des_nlev = 8; % desired levels
minlev = 5; % minium levels
maxlev = 100; % maximum levels


% Leave if there aren't enough values to make the minium number of levels and set it to that
uq = unique(in.(in.fieldname)(...
    in.(in.fieldname)>=dr(1) & ...
    in.(in.fieldname)<=dr(2) ...
    ) );

if length(uq)<=des_nlev
    nl = length(uq);
    return
end


% loop over reasonable levels to see which datarange split into nlevels will
% look best.

a = des_nlev:-1:minlev;
a = a(2:end);
b = des_nlev:maxlev;

% make a vector of desired levels with the desired number first
nlvec(1:2:2*length(a)-1) = b(1:length(a));
nlvec(2:2:2*length(a)) = a;
nlvec(2*length(a)+1:length(b)+length(a)) = b(length(a)+1:end);
pick=nan(1,length(nlvec));indic=pick;

i=1;
for nl = nlvec
    for fc = [1,10,100,1000,1000,10000]
        if abs(fc*(dr(2)-dr(1)) /nl) - floor(fc*(dr(2)-dr(1)) /nl) < 1e-6
            pick(i)=fc;
            indic(i)=i;
            break
        end
    end
    i=i+1;
end
indic=indic(~isnan(pick));
nlvec=nlvec(~isnan(pick));
pick=pick(~isnan(pick));

% choose the lowest value "distance to desired nlevel" * "accuracy" (pick)
nl = nlvec(indic.*pick==min(indic.*pick));

if isempty(nl)
    nl=des_nlev;
end

end

%% SUBFUNCTIONS FOR SETUP
%      ||||||
%      VVVVVV

function check_input(in,field)
%% CheckInput
% Checks the input type of all options. If the field is in the list of
% available options, it will be tested against a anomynous function (e.g.
% in.region should pass @(x)(ischar(x)) ). The field names and their
% corresponding test functions are listed in gmt_inputs.

errID = ['gmtlab:' mfilename ':BadInput'];
assert(isstruct(in),errID,'"in" must be a structure')

[GSE,GSSE] = gmt_inputs;

Fields = fieldnames(in)';
fieldsNotToRead = cell(100,1); ii = 1;
for F = Fields
    
    f = F{1};
    if strcmp(f,field)
        logtext(2,['in.%s is ordinarily a gmt option, but "field"=%s ',...
            'has precedence and thus in.%s will be treated as data\n'],f,f,f)
        continue
    end
    % See if the in.(field) is a listed option
    test = GSE(ismember(GSE(:,2),f),:);
    
    if ~isempty(test)
        % corresponding test function
        fun = test{1};
        strfun = func2str(fun);
        
        assert(fun(in.(test{2})),errID,...
            'Input type is incorrect. in.%s should pass the test: %s',test{2},strfun);
        
        % If in.(field) is itself a structure, do it again (more or less)
        if isstruct(in.(test{2})) && ismember(test{2},fieldnames(GSSE))
            Fields2 = fieldnames(in.(test{2}))';
            for F2 = Fields2
                f2 = F2{1};
                test2 = GSSE.(test{2})(ismember(GSSE.(test{2})(:,2),f2),:);
                if ~isempty(test2)
                    fun = test2{1};
                    strfun = char(fun);
                    assert(fun(in.(test{2})(1).(test2{2})),errID,...
                        'Input type is incorrect. in.%s.%s should pass the test: @%s',...
                        test{2},test2{2},strfun);
                else
                    warning(errID,'in.%s.%s is not a valid field in in.%s ',...
                        test{2},f2,test{2})
                end
            end
        end
    else
        if ~any(strcmp(f,{field,'lat','lon'}))
            fieldsNotToRead{ii} = f; ii= ii+1;
        end
    end
end

logtext(atmlab('VERBOSITY'),'Warning: Fields: ');fprintf(1,'"%s",',fieldsNotToRead{1:ii-1});
logtext(atmlab('VERBOSITY'),'Will not be used as they are not "data" or in the list of options\n');

end

function in = assign_region(in,field)

errId = ['gmtlab:' mfilename ':badInput']; % common error ID

if ~isfield(in,'region')
    if in.gridded
        % check if the data is probably global
        
        dn = diff(in.lon);
        dt = diff(in.lat);
        if isempty(dt), dt = mean(dn);end %incase there's only one latitude
        
        % make the region str, keeping in min the 'resolution' of the grid
        annot_format = {getAnnotFormat(mean(diff(in.lon))),...
            getAnnotFormat(mean(diff(in.lat)))};
        
        % check to see if lon-dlon is out side the boundary. If so, fix the
        % region to the edges. Same goes for lat...
        % If the region passes the dateline it goes back to 0:360 notation
        
        if in.lon360
            cond1 = abs(0 - in.lon(1)) <= dn(1);
            cond2 = 360-in.lon(end) <= dn(end);
        else
            cond1 = abs(-180 - in.lon(1)) <= dn(1);
            cond2 = 180-in.lon(end) <= dn(end);
        end
        cond3 = abs(-90-in.lat(1)) <= dt(1);
        cond4 = 90-in.lat(end) <= dt(end);
        
        af = annot_format{1};
        if cond1 && cond2 && cond3 && cond4
            if in.lon360
                in.region= '0/360/-90/90';
            else
                in.region= '-180/180/-90/90';
            end
        elseif cond1 && cond2
            if in.lon360
                fstr = sprintf('0/360/%s/%s',af,af);
            else
                fstr = sprintf('-180/180/%s/%s',af,af);
            end
            in.region = sprintf(fstr,in.lat(1)-dt(1)/2,in.lat(end)+dt(end)/2);
        elseif cond3 && cond4
            fstr = sprintf('%s/%s/-90/90',af,af);
            in.region = sprintf(fstr,in.lon(1)-dn(1)/2,in.lon(end)+dn(end)/2);
        else
            fstr = sprintf('%s/%s/%s/%s',af,af,af,af);
            in.region = sprintf(fstr,...
                in.lon(1)-dn(1)/2,in.lon(end)+dn(end)/2,...
                in.lat(1)-dt(1)/2,in.lat(end)+dt(end)/2);
        end
    else
        if (max(in.lon(:))-min(in.lon(:)) ) >= 350
            if ~in.lon360
                in.region = '-180/180';
            else
                in.region = '0/360';
            end
        else
            in.region = sprintf('%g/%g',...
                min(in.lon(:)),max(in.lon(:)));
        end
        if (max(in.lat(:))-min(in.lat(:)) ) >= 170
            in.region = sprintf('%s/-90/90',in.region);
        else
            in.region = sprintf('%s/%g/%g',...
                in.region,min(in.lat(:)),max(in.lat(:)));
        end
    end
else
    in.userDefinedRegion = true;
    x = sscanf(in.region,'%f/%f/%f/%f');
    if in.lon360 && (x(1) < 0)
        if ~in.gridded
            in.lon = in.lon-(in.lon > 180)*360;
        else
            [~,tmp] = standardize_geodata(struct('lat',in.lat,'lon',in.lon,'data',in.(field)),struct('lon360',0));
            in.lon = tmp.lon;
            in.(field) = tmp.data;
        end
    end
end

if strcmp(in.region,'g')
    % Then the data is set to global
    if ~in.lon360
        in.region = '-180/180/-90/90';
    else
        in.region = '0/360/-90/90';
    end
    return
end
% remove frivolous data for memory and speed performance in that case
x = sscanf(in.region,'%f/%f/%f/%f');
lt = in.lat >= x(3) & in.lat <=x(4); %logical vector
ln = in.lon >= x(1) & in.lon <=x(2); %logical vector
if in.gridded
    in.(field) = in.(field)(lt,ln);
    in.lat = in.lat(lt);
    in.lon = in.lon(ln);
else
    in.(field) = in.(field)(lt&ln);
    in.lat = in.lat(lt&ln);
    in.lon = in.lon(lt&ln);
end
assert(~isempty(in.lat) && ~isempty(in.lon),...
    errId,'lat or lon are empty')

end

function datarange = getdatarange(in,field)
%% getdatarange

tmp = in.(field)(:);
d = double([min(tmp(~isinf(tmp))) max(tmp(~isinf(tmp)))]);

% Do some tricks to get the most useful datarange. (rounded, but preserve precision)
x = log10(d(2)-d(1));

datarange = [10^(round(x)-1) * round(d(1) * (1/10^(round(x)-1))),...
    10^(round(x)-1) * round(d(2) * (1/10^(round(x)-1)))];


end

function [stepsize,annot_format] = getstepsize(in)
%% getstepsize

if in.nodata
    stepsize = 0;
    annot_format='';
    return
end

if isfield(in,'stepsize')
    % warning('gmtlab:input','in.stepsize overrides in.nlevels')
    stepsize = in.stepsize;
elseif ~isfield(in,'stepsize')
    stepsize = (in.datarange(2)-in.datarange(1))/in.nlevels;
end
annot_format = getAnnotFormat(stepsize);

end

function in = nodata(in)
%% NODATA
% if you want to only plot coastlines

in.sidebar = false;
in.legend  = false;
in.gridded = false;
in.nlevels = 1;

% a stab at the region before something more elaborate is done
in = preGetRegion(in);

% get default ticks for map borders
in = getDefaultTicks(in);

end

function in = preGetRegion(in)

if isfield(in,'region')
    % do nothing
elseif ~isfield(in,'region') && all(isfield(in,{'lat','lon'}))
    in.region = sprintf('%g/%g/%g/%g/%g',...
        min(in.lon(:)),max(in.lon(:)),...
        min(in.lat(:)),max(in.lat(:)));
else
    in.region='-180/180/-90/90';
end
end

function in = getDefaultTicks(in)
%% getDefaultTicks
%
% Set the ticks around the borders of the map
%
%
% requires in.region and in.psbasemap

% 'g'  seems to not work so well
% if strcmp(in.region,'g')
%     if in.lon360
%         rg = [0 360 -90 90];
%     else
%         rg = [-180 180 -90 90];
%     end
% else
rg=sscanf(in.region,'%f/%f/%f/%f');
%end

ln=rg(2)-rg(1);
lt=rg(4)-rg(3);

% for nice step lengths

% lons
as   = [240 180 120 90 60 30 15];
step = [60 40 30 20 15 10 5];
a = step(~(as>ln));
if isempty(a), a = ln/6; end

%lats
bs   = [120 90 60 40 30 20 15];
step = [60 30 30 20 10 5 2.5];
b = step(~(bs>lt));
if isempty(b), b = lt/14; end

default.ticks = sprintf('%gg%g/%gg%g',a(1),b(1),a(1)/2,b(1)/2);
in.psbasemap = optargs_struct(in.psbasemap,default);
end

function in = isdata(in,field)
%% is there any useable data?

Id  = ['gmtlab:' mfilename ':badInput'];
Eps = 1e-10;

% silently squeeze the data
in.(field)=squeeze(in.(field));
assert(isfield(in,field), Id,'The field: "%s" is not in the structure',field)
assert(any(~isnan(in.(field)(:))),'gmtlab:gmt_plot:noData',...
    '%s%s','Data does not contain any valid',...
    ' values for contour levels to be based on...')
assert(~(~ismatrix(in.(field))),Id,'in.%s must not be more than 2 dimensional',field)
assert((max(in.(field)(:))-min(in.(field)(:))>Eps),Id,...
    'min(data) must not be equal to max(data)')

% check for lat and lons
if ~isfield(in,'lat')
    l = {'Latitude','latitude'};
    assert(any(isfield(in,l)),Id,'No latitudes present')
    in.lat = in.(l{isfield(in,l)});
elseif any(isfield(in,{'Latitude','latitude'}))
    disp('Several latitude vectors present. Using in.lat')
end
if ~isfield(in,'lon')
    l = {'Longitude','longitude','long'};
    assert(any(isfield(in,l)),Id,'No longitudes present')
    in.lon = in.(l{isfield(in,l)});
elseif any(isfield(in,{'Longitude','longitude','long'}))
    disp('Several longitude vectors present. Using in.lon')
end

end

function in = isgridded(in,field)
%% ISGRIDDED: Test if the data is gridded
%  If it is not gridded, flatten the data

if isempty(in.(field))
    error(['gmtlab:' mfilename ':BadInput'],....
        'The data variable: in.%s is empty',field)
end

if ndims(in.(field))==3
    in.(field) = squeeze(in.(field));
end

[a,b]=size(in.(field));
pos1 = a==length(in.lat)&b==length(in.lon); %(lat,lon)
pos2 = b==length(in.lat)&a==length(in.lon); %(lon,lat)

% if (pos1 && pos2) && (pos1 || pos2), then we dont know if it gridded, but
% assume it's not.
if ~isfield(in,'gridded')
    ig = ~ (isequal(size(in.(field)(:)),size(in.lat(:)),size(in.lon(:))));
    if ~ig
        in.(field) = in.(field)(:);
        in.lat     = in.lat(:);
        in.lon     = in.lon(:);
        in.gridded = false;
    else
        if pos2 && (pos2 ~= pos1)
            % want it in (lat,lon)
            in.(field)=in.(field)';
        end
        in.gridded = true;
    end
end

end

function in = treatAsUngridded(in,field)

if in.treatAsUngridded && in.gridded
    
    logtext(1,'Treating the gridded data as ungridded\n')
    in.lon = repmat(in.lon',length(in.lat),1);
    in.lat = repmat(in.lat,1,length(in.lon));
    in.gridded = false;
    assert(isequal(size(in.lat),size(in.lon),size(in.(field))),'Something went wrong')
end

end

function in = rmNaNsGeo_and_standardize_geodata(in,field)
%% rmNaNsGeo
% Also get rid of NaNs in the geodata
% This only applies to ungridded data

errId = ['gmtlab:' mfilename ':badInput']; % common error ID

if ~in.gridded
    
    index = in.lat >= -90 & in.lat <= 90 & in.lon >= -180 & in.lon <= 360;
    if any(~index)
        logtext(1,'Data with dodgy geodata will be ignored (%.2f%%)\n',100*sum(~index)/numel(index))
        assert(sum(index)/numel(index)>0,['atmlab:',mfilename,':badInput'],'No valid lat lons!\n')
        in.lat = in.lat(index);
        in.lon = in.lon(index);
        in.(field) = in.(field)(index);
    end
    in.lon360 = ~(min(in.lon(:))<0 || ~max(in.lon(:))>180);
else
    % make sure that the lons,lats and data are ordered in ascending and data(lat,lon)
    assert(length(in.lat)*length(in.lon)==numel(in.(field)),...
        errId,'numel(data) must length(lat)*length(lon)')
    
    dataOptions.lon360 = true;
    dataOptions.dimorder='latlon';
    dataOptions.lat_descend=false;
    dataOptions.lon_descend=false;
    dataOptions.duplicate=false;
    [flags,tmp] = standardize_geodata(...
        struct('lat',in.lat,'lon',in.lon,'data',in.(field)),dataOptions);
    in.lat=tmp.lat;
    in.lon=tmp.lon;
    in.(field)=tmp.data;
    clear tmp
    in.lon360=flags.out.lon360;
end

end

function in = setupXtraLegend(in)

default.width     = in.legend.width;
in.extra_legend   = optargs_struct(in.extra_legend,default); clear default
default.length    = in.extra_legend.width;
default.lineThick = in.legend.lineThick;
default.justify   = 'RB';
default.fontsize  = in.fontsize_annot_primary;
default.unit      = false;

[lw,lwu] = separate_integer_and_unit(in.legend.width);
if strcmp(in.legend.orientation,'h')
    switch in.proj.projection
        case {'H','I'} % hammer,sinusoidal
            projOff = 5;
        case 'N' % robinsson
            projOff = 2.5;
        otherwise
            projOff = 1;
    end
    default.xoffset = sprintf('-%.2f%s',projOff*lw*2,lwu);
    default.yoffset = '0';
    
elseif strcmp(in.legend.orientation,'v')
    default.xoffset = '0';
    default.yoffset = sprintf('-%.2f%s',lw*2,lwu);
end
in.extra_legend   = optargs_struct(in.extra_legend,default);

in.extra_legend.extra_instructions = '-Li'; % no ticks, square   
end

function in = setupLegend(in)
% SETUP LEGEND

errId = ['gmtlab:' mfilename ':badInput']; % common error ID
if isfield(in,'legend') && (~isstruct(in.legend) && ~in.legend)
    % If in.legend = false, do nothing
    return
end
if ~isfield(in,'legend') || ~isstruct(in.legend)
    in.legend=struct();
end

% apply defaults to legend

% ORIENTATION
x = sscanf(in.region,'%f/%f/%f/%f');
f = ( x(4)-x(3))/ ( x(2)-x(1) ); %something between 0->1 equivalent to 180/360->120/360 lats/lons
myHcondition = f <= 0.25; tmp = {'v','h'}; %vertical,horisontal
default.orientation = tmp{myHcondition+1};

    
% I use map_width to find the defaults.
if ischar(in.proj)
    x = regexp(in.proj,'.*/(?<map_width>.+)','names');
    mwstr = x.map_width;
else
    mwstr = in.proj.map_width;
end
[mw,mwu] = separate_integer_and_unit(mwstr);

default.lineThick =.2; %thickness of legend bar

in.legend         = optargs_struct(in.legend,default); %need orientation now
default.width     = sprintf('%.2f%s',in.legend.lineThick*mw/5,mwu);
in.legend         = optargs_struct(in.legend,default); %need orientation now
lw = separate_integer_and_unit(in.legend.width);
switch in.legend.orientation
    case 'v'
        default.justify = 'CR'; %center right
        default.length  = sprintf('%.2f%s',f*mw,mwu);
        default.xoffset = sprintf('-%.2f%s',lw*2,mwu);
        default.yoffset = '0';
        
    case 'h'
        default.justify = 'BC'; % bottom centre
        default.length  = sprintf('%.2f%s',mw,mwu);
        default.xoffset = '0';
        default.yoffset = sprintf('-%.2f%s',lw*2,mwu);
        
    otherwise
        error(errId,'orientation should be "v" or "h", not "%s"',in.legend.orientation)
end

default.tick_annotion_format = in.tick_annotation_format;
if ~isfield(in.legend,'tick_annotations') % incompatible
    default.tick_spacing = (in.datarange(2)-in.datarange(1))/in.nlevels ...
        * (floor((in.nlevels-1)/10) + 1);    %10 is the old default number of levels
end
default.sidebar      = getsidebar(in); % coloroured triangles using in.datarange
in.legend            = optargs_struct(in.legend,default);

end

function sidebar = getsidebar(in)
%% color level datastep interval
% sidebar can have the values 0,1,2,3 (none, bellow only, above only, both).

sidebar =  ( min(in.(in.fieldname)(:))<in.datarange(1) ) + ...
    2* ( max(in.(in.fieldname)(:))>in.datarange(2) );

end

function in = specialregion(in,field)

if in.gridded
    % DO some special treatment of data crossing the dateline that is not continuous
    % after changing to -180:180 regime OR if in.region is in 0:360 mode
    
    if any(diff(in.lon)==0)
        % in case a longitude appears twice. e.g., if the grid was originally
        % lon = 0:360
        cond = diff(in.lon)~=0;
        in.lon = in.lon(cond);
        in.(field) = in.(field)(:,cond);
    end
    
    if in.lon360 && max(diff(in.lon))>5*min(diff(in.lon)) % if the are dicontinuous
        
        in.lon = in.lon+(in.lon < 0)*360;
        [in.lon,lnindex] = sort(in.lon);
        in.(field) = in.(field)(:,lnindex);
        % if diff equal 0 somewhere then at best the data is repeated e.g.
        % at 0 and 360 degrees
        if any(diff(in.lon)==0)
            if isequal(in.(field)(:,find(diff(in.lon)==0)),in.(field)(:,find(diff(in.lon)==0)+1)) %#ok<FNDSB>
                % then remove duplicate line
                in.lon      = in.lon(diff(in.lon)~=0);
                in.(field)  = in.(field)(:,diff(in.lon)~=0);
            else
                error(['atmlab:' mfilename],'Same longitudes are repreated but the data are not the same there')
            end
        end
        % Do the region part again
        if ~isfield(in,'userDefinedRegion') || ~in.userDefinedRegion
            in = rmfield(in,'region');
            in = assign_region(in,field);
        end
    end
    
    
    assert(max(diff(in.lon))<5*min(diff(in.lon)),['atmlab:' mfilename, ':Error'],...
        'The longitudes are not continuous. FIXME: put workaround in place')
    
    if length(in.lat) == size(in.(field),1)+1 || length(in.lon) == size(in.(field),2)+1
        logtext(1,'Data does not appear to be centered. Internally ')
        in = centerGeoData(in,field);
    end
end

end

% ----------------
% Other subfunctions
%

function filename = setup_figure(in,command)
%% SORT FIGURES


%'eps','pdf','BMP','jpg','PNG','PPM','TIFF', ot 'tif'
switch lower(in.figuretype)
    case 'pdf'
        T = '-Tf';
    case 'bmp'
        T = '-Tb -Qg -Qt';
    case 'eps'
        T = '-Te';
    case 'jpg'
        T = '-Tj -Qg -Qt';
    case 'png'
        T = '-Tg -Qg -Qt'; %-Q is for no antialiaing 'g'raphics and 't'ext
    case 'tif'
        T = '-Tt -Qg -Qt';
    case 'ppm' % is not recommended
        T = '-Tm -Qg -Qt';
    otherwise
        error(['gmtlab:' mfilename ':FigureType'],...
            '%s: not supported',in.figuretype)
end
command{end+1} = sprintf('gmt psconvert %s.ps -A -P %s',in.filename,T);

% Assemble open command
if isnan(gmtlab('PDFVIEWER'))
    openwith = gmtlab('OPEN_COMMAND');
else
    openwith = gmtlab('PDFVIEWER');
end

if in.makeScriptAndStop
    filename = makeScriptAndStop(command);
    logtext(1,'Stopped\n')
    return
end

% move the plot
command{end+1} = sprintf('mv %s.%s %s',in.filename,in.figuretype,in.outdir);

% display it
if in.display && ~any(isnan(openwith))
    command{end+1} = sprintf('%s %s/%s.%s >/dev/null &',...
        openwith,in.outdir,in.filename,in.figuretype);
end

if in.savelegend
    % MAKE a separate file for the legend
    findPsScale = ~cellfun('isempty',regexp(command,'psscale'));
    if ~any(findPsScale)
        v = atmlab('VERBOSITY');
        atmlab('VERBOSITY',1);
        logtext(atmlab('ERR'),'psscale, which is used to make the legend was never called. Maybe legend=0 or there was no input data?\n')
        atmlab('VERBOSITY',v);
        filename = '';
        
        return
    end
    in.filename_legend = makelegendpdf(in.filename, command(findPsScale));
    if in.savelegend==2 % store legend ONLY in external file
        command = command(~findPsScale);
    end
    command{end+1} = sprintf('mv %s.%s %s',in.filename_legend,in.figuretype,in.outdir);
end

out = exec_system_cmd(command,gmtlab('verbosity')); % execute all gathered commands

filename = sprintf('%s/%s.%s',in.outdir,in.filename,in.figuretype);

% TRY and open the file even without user input
% If no viewer is defined, check for xpdf, then evince, then okular
if in.display && any(isnan(openwith))
    logtext(2,'display = 1, yet no viewer is defined\nE.g. gmtlab(''pdfviewer'',''gnome-open'')\n')
    
    if strcmp(in.figuretype,'pdf')
        disp('No pdfviewer defined.')
        disp('Set gmtlab(''PDFVIEWER'',''<e.g. xpdf>'') in your startup file')
        if ~system('which xpdf')
            openwith = 'xpdf';
        elseif ~system('which evince')
            openwith = 'evince'; % for gnome users
        elseif ~system('which okular')
            openwith  = 'okular'; % for kde users
        end
        if ~any(isnan(openwith))
            logtext(1,'Opening file with %s for now\n',openwith)
            system(sprintf('%s %s &',openwith,filename));
        end
    end
end
hunt_down_errors(command,out) % look for system call errors in the gmt calls

logtext(atmlab('OUT'), 'GMT plot stored at:  %s\n',filename)

end

function file = makelegendpdf(basename, command)
%% Make a separate pdf for the legend
% Only allowed to have 1 or 2 psscale commands in the commad list. the first one
% is the regular legend. The second is for the nan legend (if it exists)

file = [basename '_legend'];

%make sure it's not here
exec_system_cmd(sprintf('rm -f %s.ps',file),gmtlab('verbosity'));

%Remove trailing .ps entry
crop=regexp(command,'>>');

% Additional adjustments
for i = 1:length(command)
%for i = 2:length(command)
    command{i} = sprintf('%s -P >> %s.ps', command{i}(1:crop{i}-1), file );
    %if i == 2
    if i == 1
        command{i} = regexprep(command{i},'-O','');
    end
    if i == length(command)
        command{i} = regexprep(command{i},'-K','');
    end
end

% This forces it to be a pdf
command{end+1} = sprintf('gmt psconvert %s.ps -A -P -Tf',file);
exec_system_cmd(command,gmtlab('verbosity'));

end

function hunt_down_errors(command,errors)
%% Hunt down any errors encounted using GMT

% messages containing any of these are exempted
error_exeptions = {'warning','not set'};
definite_errors = {'illegal','error'};

% this gives cell{1:nerrors}{1:nerr_exp}
found_err_exp = cellfun(@(x)(regexp(x,error_exeptions,'ignorecase','once')),errors,'uniformoutput',0);
found_def_err = cellfun(@(x)(regexp(x,definite_errors,'ignorecase','once')),errors,'uniformoutput',0);

windex = cellfun(@(x)(any(cell2mat(x))),found_err_exp);
eindex = cellfun(@(x)(any(cell2mat(x))),found_def_err);

Warnings             = errors(windex);
associated_w_warning = command(windex);
Errors               = errors(eindex);
associated_w_errors  = command(eindex);

% display GMT calls containing warning
if ~isempty(Warnings)
    V = atmlab('VERBOSITY'); atmlab('VERBOSITY',1);
    logtext(atmlab('OUT'),'GMT completed with the following warning messages:\n')
    tmp = cellfun(@(x,y)(sprintf('%s\n%s\n',x,y(1:end-1))),associated_w_warning,Warnings,'UniformOutput',0);
    logtext(atmlab('OUT'),'%s\n',[tmp{:}])
    atmlab('VERBOSITY',V);
end

% error on GMT errors
if ~isempty(Errors)
    tmp = cellfun(@(x,y)(sprintf('%s\n%s\n',x,y(1:end-1))),associated_w_errors,Errors,'UniformOutput',0);
    error(['gmtlab:' mfilename ':GMT'],...
        'GMT encountered the following errors:\n%s',[tmp{:}])
end

end

function gmtcleanup(tmpdir,curdir,keepfiles,V)
%% cleanUp

if keepfiles
    logtext(1,'in.keep_files = true;\nTemporary files are stored at %s.\n',pwd)
    logtext(2,'Remember to delete the directory when you are done\n')
else
    % cd back to the original directory
    cd(curdir);
    rmdir(tmpdir,'s')
    logtext(1,'%s is now removed\n',tmpdir)
    atmlab('VERBOSITY',V);
end

end

function filename = makeScriptAndStop(command)
%% Make a script for debugging

logtext(1,'Making directory to put scripts and plot data into\n')
folder = sprintf('%s/gmt_test_%s',gmtlab('OUTDIR'),datestr(now,'yyyymmdd_HHMMSS'));
exec_system_cmd(sprintf('mkdir %s',folder));

exec_system_cmd(sprintf('rsync -avP %s/* %s/.',pwd,folder));

curdir=pwd;
cd(folder)

logtext(1,'Making file: %s/script.sh\n',folder)
fid = fopen('script.sh','w');
fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'\n\n\n');
fprintf(fid,'cd %s\n\n',folder);
for C = command
    fprintf(fid,'%s\n',C{1});
end

exec_system_cmd(sprintf('chmod +x %s/script.sh',folder));
filename = fullfile(folder,'script.sh');

a = exec_system_cmd(sprintf('du -h %s',gmtlab('OUTDIR')));
logtext(2,'\nDon''t forget to clean up\n%swhen you are done!\n',a{1})
cd(curdir)
end
