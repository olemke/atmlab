function filename = gmt_plot(in,field)
% GMT_PLOT plotting interface for GMT (Generic Mapping Tools)
%
% The function is basically a wrapper that calls gmt shell commands using easy
% to use matlab arguments. Try test_gmt.m for some examples on how to use the function.
% Preferably, the data should be CENTERED if the data is gridded (fastest
% performance).
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
% gmtlab( 'OUTDIR', '/name/a/favorite' ) %% The default directory to put plots
% gmtlab( 'PSVIEWER','gv');             %% set viewer for .ps files
% gmtlab( 'PDFVIEWER','xpdf -z width'); %% set viewer for .pdf files
% gmtlab( 'OPEN_COMMAND','gnome-open'); %% set a general open command
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
% If your data is gridded the data MUST have the dimensions:
% [length(in.lat),length(in.lon)] == size(in.(field));
%  << transpose: in.(field) = in.(field)'; if this is not the case >>
%
% NOTE: 1) If your data is UNGRIDDED I recommend setting
%          in.nearneighbor.resolution = Deg (something suitable).
%       2) gmt_plot automatically detects if the data is gridded or not
%
%
% HOW TO READ VARIABLE DESCRIPTION OF OPTIONAL VARIABLES:
%
%% KEY: in.variable   |Type| Explanation/Example |Default value/behavior|
%
%                  types: %s=character or string
%                         %f=numeric/logical
%                         {}=cell
%                  default: []=means there is no default value/behaviour.
%--------------------------------------------------------------------------
%
% GENERAL:
%
% in.basemap_axis     |%s|
%                     E.g. 'WSne', annotates West and South of the map.
%                     | 'WSne' |
%                     ------------
% in.display          |%i| If false, file created but not displayed |true |
%                     ------------
% in.filename         |%s| E.g. 'yourfilename' | generated from title |
%                     ------------
% in.figuretype       |%s| 'pdf','eps','png', or 'tif' | 'pdf' |
%                     ------------
% in.gmtset           |{%s,%s,...}|
%                     Cell with one or more gmtset commands.
%                     E.g. in.gmtset={'gmtset D_FORMAT %3.1e','gmtset ...'}
%                     | [] |
%                     ------------
% in.header_size      |%f| Title size | 36 [p] |
%                     ------------
% in.header_offset    |%f| Moves the title in y-dir on the page | 0.5 [cm] |
%                     ------------
% in.keep_files       |%f|
%                     If you don't want to delete intermediate files
%                     | false |
%                     ------------
% in.measure_unit     |%s|
%                     The default unit to use for all commands if none is given.
%                     Choose between:  'point' (1/72 inch), 'cm', 'm' and 'inch'
%                     |'cm'|
%                     ------------
% in.nodata           |%f|
%                     If you only want a map (compatible with all options)
%                     | [] |
%                     ------------
% in.outdir           |%s| E.g. 'name/a/directory'
%                     |gmtlab('OUTDIR')  ('.' if not set in startup) |
%                     ------------
% in.ticks            |%s|
%                     E.g '60g30/30g15'. The first value for both axis
%                     denotes the tick interval to annotate, the second
%                     value is the interval to draw the gridlines. xaxis and
%                     yaxis are separated by '/'.
%                     i.e (x-axis: 'annot'g'grid'/ y-axis: 'annot'g'grid')
%                     Note: To remove gridlines set the second value to 0.
%                     | determined by input lat/lon range. |
%                     ------------
% in.title            |%s| Title of plot | '' |
%                     ------------
% in.unit             |%s| String displayed on the y-axis of legend | '' |
%                     ------------
% in.xunit            |%s| String displayed on the x-axis of legend | '' |
%                     ------------
% in.plotPlacement    |%s| String of global plotPlacements | '-Ya5 -Xa5' |
%
%--------------------------------------------------------------------------
%
% PROJECTION, GRID, COASTLINES:
%
% in.region           |%s|
%                     E.g. '-180/180/-90/90'=global range, defined from
%                      sprintf('%f/%f/%f/%f',lon1,lon2,lat1,lat2)
%                     | determined by input lat/lon range. |
%                     ------------
% in.nearneighbor     |%s|
%                     E.g. 'nearneighbor OPT > filename.ps', explicitly sets
%                     the nearneighbor GMT command directly. If
%                     in.nearneighbor is a structure, it'll use the
%                     structure arguments to generate the command.
%                     | [] |
%                     ----------------------
%
% in.nearneighbor.    | STRUCTURE with one or more of the following fields:
%
%  search             |%s|
%                     E.g. 30m' Search for data within 30 [arcmin]
%                     | Loosely based on the density of the data points |
%                     ------------
%  resolution         |%f|
%                     E.g. 1 [Deg] (== 60minuntes) looks for values withing 1deg
%                     | Loosely based on the density of the data points, or avialable memory |
%
%                     ----------------------
%
% in.projection       |%s|
%                     See available projections in GMT manual.
%                     |'Q' (cylindric equidistant) |
%                     ------------
% in.center           |%f| Center map at given longitude | 0 [deg] |
%                     ------------
% in.map_width        |%f| Set width of map | 9 [inches] |
%                     ------------
% in.proj             |%s|
%                     Describes the projection, center, and map_width
%                     | 'Q0/9i' (see above) |
%                     ------------
% in.pscoast          |%s|
%                     E.G 'pscoast OPT > filename.ps', explicitly sets the
%                     pscoast GMT command.
%                     |[]|
%                     ----------------------
% in.coast            |%s|
%                     If you don't want coastlines, set to false. If
%                     in.coast is a structure, it'll use the structure
%                     arguments to generate the pscoast command.
%                     | create coastlines |
%                     ----------------------
%
% in.coast.           | STRUCTURE with one or more of the following fields:
%
%  features           |%f| Don't plot features < in.features [km^2]
%                     | determined by lon/lat range |
%                     ------------
%  resolution         |%s|
%                     (f)ull, (h)igh, (i)ntermediate, (l)ow, and (c)rude
%                     | determined by lon/lat range |
%                     ------------
%  rivers             |%s|
%                     Display rivers. pscoast -Ioption (1-10, a,r,i,c)
%                     | '1' (major rivers) |
%                     ------------
%  width              |%i| Width of coastlines | .3 |
%                     ----------------------
%  color              |%s| color of coast and rivers in rgb
%                     e.g. '255/255/255' gives white coastlines
%                     | COLOR_BAGROUND |
%                     ----------------------
%
%--------------------------------------------------------------------------
%
% COLORS & DATA REPRESENTATION:
%
% in.datarange        |[%f, %f]|
%                     Range of data values to display
%                     | [min(data) max(data)] |
%                     ------------
% in.grdimage         |%s|
%                     E.g. 'grdimage OPT > filename.ps', explicitly sets
%                     the grdimage GMT command directly.
%                     | [] |
%                     ------------
% in.makecpt          |%s|
%                     E.g. 'makecpt OPT > filename.ps', explicitly sets the
%                     makecpt GMT command directly.
%                     | [] |
%                     ------------
% in.cptfile          |%s| Path to any .cpt file generated previously
%                     | [] |
%                     ------------
% in.ctable           |%s| See GMT color palettes | 'rainbow' |
%
%                     NOTE: 'mypolar' is a nice colortable for difference
%                     plots, and there are two additional optional
%                     arguments for this color table:
%                       in.reference: |%d|
%                                     where to center the white color
%                                     | mean(data(:)) |
%                           Note:     Recommend set in.reference = 0 for
%                                     difference plots, but any reference
%                                     will work.
%
%                       in.nwhite:     |%d|
%                                      The number of white contours around
%                                      a reference value
%                                      | determined by number of levels |
%
% in.color_background |%s|
%                     Set the background color (values less than range)
%                     | '0/0/0' ('black') |
%                     ------------
% in.color_foreground |%s|
%                     Set the foreground color (values greater than range)
%                     | '255/255/255' ('white') |
%                     ------------
% in.color_nan        |%s| Set the color of NaNs
%                     | '125/125/125' ('grey') |
%                     ------------
% in.nlevels          |%d|
%                     Refers to the number of contour levels (converted to
%                     stepsize using datarange)
%                     | 20 |
%                     ------------
% in.stepsize         |%f|
%                     The stepsize between data values. This overrides
%                     nlevels (-T/min/max/stepsize in makecpt)
%                     | determined by nlevels |
%                     ------------
%
% in.tickval          |%d|
%                     Vector of values to be used for ticks and data interval
%                     | determined by datarange and stepsize|
%                     ------------
%
% NOTE: For your own CUSTOM COLORTABLE use in.colorrange.colors
% (see below). Assign a color to a relative value, e.g between 0-1, where
% 0 is for the minimum of the datarange and 1 is for the color of the
% maximum datarange. For example,
% in.colorrange.colors = {{0,'red'},{.3,'black'},{0.5,'green'},{1,'blue'}},
% makes a colortable that goes from red to black to green to blue.
% Naturally you can also use the 'contour values' directly as long as you
% assign all levels a color.
%
%                     ----------------------
% in.colorrange.      | STRUCTURE with one or more of the following fields:
%
%  colors             | {{%d,%s},{%d,%s},etc.}
%                     %d is the data value, %s is the color
%                     (e.g. {20,'255/0/0'} (red in RGB))
%                     | [] |
%                     ------------
%  color_model        |%s|
%                     'RGB', 'HSV'
%                     | 'RGB' |
%                     ----------------------
%
%------------------------------------------------------------------------------------
% LEGENDS:
%
% in.pscale           |%s|
%                     E.g. 'psscale OPT > filename.ps', explicitly sets the
%                     psscale GMT command for the legend directly.
%                     | [] |
%                     ------------
% in.pscale_nan       |%s|
%                     E.g. 'psscale OPT > filename.ps', explicitly sets the
%                     psscale GMT command for the NaN legend directly.
%                     | [] |
%                     ------------
% in.savelegend       |%f|
%                     if you want to have a separate pdf for the legend
%                     | [] |
%                     ------------
% in.nanlegend        |%f|
%                     Set to false if you don't want an extra NaN legend
%                     | true if there are NaN values in the data |
%                     ------------
% in.legend           |%f|
%                     Set to false if you don't want a legend. if in.legend
%                     is a structure, it's equivalent to in.legend = true
%                     | true |
%                     ----------------------
%
% in.legend.          | STRUCTURE with one or more of the following fields:
%
%  annot_font_size_primary
%                     |%f| Size of annotations in legend  | [] |
%                     ------------
%  box_spacing        |%f| Space between legend boxes | 0 (side by side) |
%                     ------------
%  position           |%s|
%                     e.g '9.7i/2.3i/10c/0.8c' (i = inch , c = cm)
%                     ('x-displacement/y-displacement/height/width'). Append 'h'
%                     for horisontal legend.
%                     | size determined by map dimensions |
%                     ------------
%  position_nan       |%s|
%                     As for in.legend.position, but for the NaN legend
%                     ------------
%  equalboxwidth      |%f|
%                     If the legend color boxes have to be the same size, 1
%                     | false (-L option) |
%                     ------------
%  length             |%f| or |%s|
%                     Toggle the length of the legend bar. If input is a string,
%                     you must append 'c' or 'i' for cm or inches, otherwise
%                     in.MEASURE_UNIT is used. Use negative value to reverse the
%                     legend. See also width,xpos,ypos,orientation for legend
%                     | '3.9i' |
%                     ------------
%  orientation        |%s|
%                     if you want a horizontal/vertical legend input 'h'/'v.
%                     See also length,width,xpos,ypos for legend
%                     | determined by map dimensions |
%                     ------------
%  shift_tick_annotations
%                     |%f|
%                     Move tick annotations to the right by x inches
%                     | [] |
%                     ------------
%  sidebar            |%f|
%                     Input scalar 0, 1, 2, or 3. Indicates none,
%                     below range only, above range, or both
%                     | determined from data |
%                     ------------
%  tick_annotations   |{%s,%s,...}|
%                     E.g. {'','','middle','',''}.
%                     Number of annotations must be = nlevels.
%                     | [] |
%                     ------------
%  tick_annotation_format
%                     |%s|
%                     E.g. '%3.1e'
%                     | [] |
%                     ------------
%  tick_centering     |%f|
%                     Have tick annotation at the center of the boxes
%                     | false (edges) |
%                     ------------
%  tick_length        |%f|
%                     The length of the ticks
%                     | [] |
%                     ------------
%  tick_spacing       |%f|
%                     If you want to manually decide how the ticks in the
%                     legend should be spread. x=> every xth data value,
%                     1=>same number of ticks as datarange
%                     | one tick per data level |
%                     NOTE: This option is desirable if you have many
%                     data levels.
%                     ------------
%  width              |%f| or |%s|
%                     Toggle the width of the legend bar. If input is a string,
%                     you must append 'c' or 'i' for cm or inches, otherwise
%                     in.MEASURE_UNIT is used.
%                     See also length,xpos,ypos, orientation for legend
%                     | '.2i' |
%                     ------------
%  xpos               |%f| or |%s|
%                     Toggle the x-position of the center of the legend bar.
%                     If input is a string, you must append 'c' or 'i' for cm or inches,
%                     otherwise in.MEASURE_UNIT is used.
%                     See also length,width,ypos, orientation for legend
%                     | '9.8i' for verticle |
%                     ------------
%  ypos               |%f| or |%s|
%                     Toggle the y-position of the center of the legend bar.
%                     If input is a string, you must append 'c' or 'i' for cm or inches,
%                     otherwise in.MEASURE_UNIT is used.
%                     See also length,width,xpos, orientation for legend
%                     | '2.3i' for verticle |
%
%                     ----------------------
%
%------------------------------------------------------------------------------------
% PLOT LOCATION MARKERS:
%
%  for multiple locations define all fields according to :
%  in.locations(1).name = 'x',
%  in.locations(2).name = 'y', etc...
%
%                     ----------------------
%
% in.locations.       | Structure with one or more of the following fields:
%
%  lat (mandatory)    |%f| Latitude of marker | [] |
%                     ------------
%  lon (mandatory)    |%f| Longitude of marker | [] |
%                     ------------
%  name               |%s| Name of marker | [] |
%                     ------------
%  shape              |%s| Shape of marker | 'c' c=filled circle |
%                     ------------
%  size               |%s or %f|
%                      size of shape. If size = %f, cm ('c') is assumend.
%                      If size = %s, give the size and unit in string (see
%                      default)
%                     | '.08i' |
%                     ------------
%  color              |%s| Color of marker | 'white' |
%                     ------------
%  textsize           |%f| Size of name | 15 |
%                     ------------
%  textcolor          |%s| Color of name | in.location.color |
%                     ------------
%  textalign          |%s|
%                     Two letters for the position of marker relative
%                     to the text. 1st letter for horizontal
%                     position: L, C, R. 2nd letter for vertical
%                     position: T, M, B
%                     | 'LT' |
%                     ----------------------
%
%--------------------------------------------------------------------------
%
% PLOT CONTOURS:
%
% in.grdcontour       |%s|
%                     E.g. 'grdcontour OPT > filename.ps', explicitly sets
%                     the grdcontour GMT command directly.
%                     | [] |
%                     ------------
% in.grdcontour       | to explicitly set pscale GMT command
%
%                     ----------------------
%
% in.contourline.     | Structure with one or more of the following fields:
%
% spacing             |%f| data interval between contours|
%                     ------------
% range               |[%f %f]| [min max]| default= same as in.datarange
%                     ------------
% linethick           |%f| -||-|
%                     ------------
% more                |%s|
%                     Additional commands for GMT's grdcontour.
%                     E.g. '-T1c/0.001c:LH'
%                     | [] |
%
%                     ----------------------
%
% If several contour plots should overlap define all fields according to:
%  in.grdcontour(1).spacing = x,
%  in.grdcontour(2).spacing = y, etc...
%--------------------------------------------------------------------------
%
% DRAW SHAPES ON MAP: FIXME are both necessary?
%
% in.psbox.           | Structure with one or more of the following fields:
%
%                     ----------------------
%  box                |[%f %f %f %f]|
%                     E.g. for box regions:
%                     [lon11 lat11 lon12 lat12;lon21 lat21 lon22 lat22]=
%                     [Bottom left corner1, Top right corner1;
%                     Bottom left corner2, Top right corner2]|
%                     ------------
%  boxes              |[%f %f ...]|
%                     The index of the last row of the regions. e.g 3 7, if
%                     you have 2 regions defined by 3 resp 4 boxes. This is
%                     useful for defining psboxcolor. Each index is defines
%                     the last corner of a region, where a region is
%                     essentially made up of many smaller boxes regions.
%                     ------------
% boxcolor            |{[%f %f %f]}| RGB color or every region
%                     | [{[0 0 0]})] for every region |
%                     ------------
% boxthick            |{%f}|
%                     Thickness of lines
%                     | 20 for every region boundary |
%                     ------------
%
% in.pspoly (%double) |{[%f %f;%f %f;...] [%f %f;...]}|
%                      Draws a polygon. Use one cell row per polygon:
%                      {[p1lon1 p1lat1; p1lon2 p1lat2| ...];...}
%                     ------------
% in.pspolycolor      | See in.psboxcolor
%                     ------------
% in.pspolythick      | See in.psboxthick
%                     ------------
%
%--------------------------------------------------------------------------
%
% QUICK TEST
%
% in.lat  = -89.5:89.5;
% in.lon  = -179.5:179.5
% in.data = rand(length(in.lat),length(in.lon))
% file = gmt_plot(in);
%
%
% Created by Salomon Eliasson (s.eliasson@ltu.se) and Oliver Lemke
% $Id$

errId = 'gmtlab:gmt_plot:input';
assert(isstruct(in),errId,'"in" must be a structure')
if nargin==2
    assert(ischar(field),errId,['2nd input ''field'' must be the string '...
        'name of the field in the structure you want to plot'])
    assert(isfield(in,field),errId,'Data field: "%s" not found',field)
elseif nargin == 1 && isfield(in,'data')
    field = 'data';
elseif nargin == 1
    in.nodata=true;
    field = '';
end

out = set_GMT_plot(in,field);

% make TEMPDIR and set atmlab('VERBOSITY') to gmtlab('VERBOSITY')
% cleanup after I'm done
out.tmpdir = create_tmpfolder();
p = pwd(); V = atmlab('VERBOSITY');
cleanupObject = onCleanup(@() cleanup(out.tmpdir,p,out.keep_files,V));

atmlab('VERBOSITY',gmtlab('VERBOSITY'));

cd(out.tmpdir);

if out.gridded
    out.grdfile = sprintf('%s/%s.grd',out.tmpdir,out.filename);
    gmt_nc_save_gridded(out.lon,out.lat,out.(field),out.grdfile);
    logtext(1,'Writing grdfile: %s sucessfull\n',out.grdfile)
else
    if ~out.nodata
        out.ungriddedfile = sprintf('%s/%s.nc',out.tmpdir,out.filename);
        gmt_nc_save_ungridded(out.ungriddedfile,out.(field),out.lat,out.lon);
    end
end

% main function
commands = create_gmt_earth(out);

% finalize
filename=sort_figures(out,commands);

%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%     ||||
%     vvvv
function in = set_GMT_plot(in,field)
%% SETUP %%

errId = 'gmtlab:gmt_plot:badInput'; % common error ID

% Test is GMT is installed and in the path
[a,b] = system('which gmtset');
if a == 1
    error('gmtlab:gmt_plot:shell',[ [ b '\n\n'],...
        'Either GMT is not installed\n',...
        'or\n',...
        'You need to add its installation directory to your PATH\n',...
        'e.g. in Matlab you can add the PATH via \n',...
        'setenv(''PATH'',[getenv(''PATH'') '':<GMTINSTALLDIR>/bin''])'])
end

% SET DEFAULTS
% general
default.basemap_axis      = 'nSeW';             % Annotates West and South of the map.
default.display           = true;               % Display figure to screen
default.figuretype        = 'pdf';              % default figure
default.outdir            = gmtlab('OUTDIR');   % where to put the figure
default.projection        = 'Q';                % Cylindrical Equidistant Projection.
default.center            = 0;                  % The center longitude of the map. The region has to be -180:180 (cyclic)
default.map_width         = 9;                  % in inches
% i.e. default.proj = 'Q0/9i'

default.title             = '';                 % no title by default
default.nodata            = false;              % true if you only want the map
default.savelegend        = false;              % make an additional pdf-file only containing the legend
default.keep_files        = false;              % keep intermediate files (debugging)
default.unit              = '';                 % unit displayed with legend
default.xunit             = '';                 % xlabel for the legend
default.plotPlacement     = '-Xa5 -Ya5';        % String of global plotPlacements

in = optargs_struct(in,default);

if any(ismember(in.outdir,' '))
    error('gmtlab:input','"spaces" ar not supported for outdir (%s)',in.outdir)
elseif strcmp(in.outdir(1),'~')
    % netcdffunctions don't like ~ for home
    in.outdir = [getenv('HOME') '/' in.outdir(2:end)];
end

if system(sprintf('test -d %s -a -w %s',in.outdir,in.outdir))
    a = 'gmtlab:input'; b = 'Either %s doesn''t exist';
    c = ', or gmtlab does not have write access to %s';
    error(a,[b,c],in.outdir,in.outdir)
end

% replace bad symbols for filename and mask them for the title
if ~isempty(in.title)
    default.filename = in.title;
else default.filename = 'default';
end
in = optargs_struct(in,default);
in.filename = regexprep(in.filename,'[:=, ()*/<>!?%]','_');
in.title = regexprep(in.title,'([=,()+*<>!?])','\\$1');
in.title = regexprep(in.title,':',' ');

%coast
if ~isfield(in,'coast') || isstruct(in.coast) || in.coast
    if ~isfield(in,'coast'), in.coast=struct([]);end
    default.rivers      = '1';  % '1' displays major rivers only. 'a' displays all.
    default.width       = .3;   % width of the coast
    
    in.coast            = optargs_struct(in.coast,default); clear default
end

if in.nodata
    % If I only want an empty map, get the essentials and leave here.
    in = nodata(in);
    return
end

if ~ismember(field,fieldnames(in))
    error('gmtlab:input','no field by the name of "%s" in struct',field)
else
    in.fieldname  = field;
end

% is the data plotable?
in = isdata(in,field);

% Check to see if the data is gridded or not
in = isgridded(in,field);

% make sure that the lons,lats and data are ordered in ascending and data(lat,lon)
if in.gridded
    assert(length(in.lat)*length(in.lon)==numel(in.(field)),...
        errId,'numel(data) must length(lat)*length(lon)')
    [flags,in.lat,in.lon,in.(field)] = homogenize_datalatlon(in.lat,in.lon,in.(field));

    if length(in.lat) == size(in.(field),1)+1 || length(in.lon) == size(in.(field),2)+1
        logtext(1,'Data does not appear to be centered. Internally ')
        in = centerGeoData(in,field);
    end
end

% REGION
if ~isfield(in,'region')
    if in.gridded
        % check if the data is probably global
        
        dn = diff(in.lon);
        dt = diff(in.lat);
        if isempty(dt), dt = mean(dn);end %incase there's only one latitude
        
        % make the region str, keeping in min the 'resolution' of the grid
        annot_format = {getAnnotFormat(mean(diff(in.lon))),...
            getAnnotFormat(mean(diff(in.lat)))};
        
        cond1 = abs(-180-in.lon(1)) <= dn(1);
        cond2 = 180-in.lon(end) <= dn(end);
        if cond1 && cond2
            fstr = sprintf('-180/180/%s/%s',annot_format{1},annot_format{1});
            in.region = sprintf(fstr,in.lat(1)-dt(1)/2,in.lat(end)+dt(end)/2);
        else
            fstr = sprintf('%s/%s/%s/%s',...
                annot_format{1},annot_format{1},annot_format{2},annot_format{2});
            in.region = sprintf(fstr,...
                min(in.lon(:))-dn(1)/2,max(in.lon(:))+dn(end)/2,...
                min(in.lat(:))-dt(1)/2,max(in.lat(:))+dt(end)/2);
        end
    else
        in.region = sprintf('%f/%f/%f/%f',...
            min(in.lon(:)),max(in.lon(:)),...
            min(in.lat(:)),max(in.lat(:)));
    end
else
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
end

% DATARANGE
if ~in.nodata
    default.datarange     = getdatarange(in,field); %
    default.nanlegend     = any(isnan(in.(field)(:))); % include NaNs in the legend
end
in = optargs_struct(in,default);

% COLORS & DATA REPRESENTATION
default.ctable      = 'rainbow';          % color palette
[default.stepsize,default.tick_annotation_format]    = getstepsize(in,field);    % color level datastep interval
in = optargs_struct(in,default); clear default

% LEGEND
if isfield(in,'legend') && (~isstruct(in.legend) && ~in.legend)
    % If in.legend = false, do nothing
    return
end
if ~isfield(in,'legend') || ~isstruct(in.legend)
    in.legend=struct([]);
end
% apply defaults to legend
if ~isfield(in.legend,'position')
    % ORIENTATION
    
    x = sscanf(in.region,'%f/%f/%f/%f');
    myHcondition = ( x(2)-x(1) )/( x(4)-x(3) ) > 3; tmp = ['v','h']; %vertical,horisontal
    default.orientation = tmp(myHcondition+1);
    
    in.legend           = optargs_struct(in.legend,default); %need orientation now
    
    o = strcmp(in.legend.orientation,'h'); %logical ishorizontal
    
    if strcmp(in.legend.orientation,'v')
        % vertical
        % fullheight vertical            9.8 2.25 4.5 .2
        % min height (good for 20 lvls)  9.8  1.5   3 .2
        f = 2- ( x(2)-x(1) )/( x(4)-x(3) ); %something between 0->1 equivalent to 180/360->120/360 lats/lons
        v = [9.8 2.25-f*0.75 4.4-f*1.5 .2];
    else v = [];
    end
    factors = {v/9 ,[4.5 -0.4 7.1 .2]/9}; %empirically good defaults for inch
    % this is based on in.mapwidth in inches !
    default.xpos   = sprintf('%.2fi',factors{o+1}(1)*in.map_width);
    default.ypos   = sprintf('%.2fi',factors{o+1}(2)*in.map_width);
    default.length = sprintf('%.2fi',factors{o+1}(3)*in.map_width);
    default.width  = sprintf('%.2fi',factors{o+1}(4)*in.map_width);
    
else
    default = regexp(in.legend.position,'(?<xpos>.+)/(?<ypos>.+)/(?<length>.+)/(?<width>.+)(?<orientation>\w{1})','names');
end
default.tick_annotion_format = in.tick_annotation_format;
default.sidebar     = getsidebar(in); % coloroured triangles using in.datarange
in.legend           = optargs_struct(in.legend,default);


function filename = sort_figures(in,command)
%% SORT FIGURES

if in.savelegend
    % MAKE a separate file for the legend
    in.filename = makelegendpdf(command(~cellfun('isempty',regexp(command,'psscale'))),in);
    command = {};
else
    
    % for figuretypes (pdf,eps,png, or tif)
    switch in.figuretype
        case 'pdf'
            T = '-Tf';
        case 'eps'
            T = '-Te';
        case 'png'
            T = '-Tg -Qg -Qt';
        case 'tif'
            T = '-Tt -Qg -Qt';
        otherwise
            error('gmtlab:figuretype','%s: not supported',in.figuretype)
    end
    
    command{end+1} = sprintf('ps2raster %s/%s.ps -A -P %s',in.tmpdir,in.filename,T);
    command{end+1} = sprintf('mv %s/%s.%s %s',in.tmpdir,in.filename,in.figuretype,in.outdir);
end


% Assemble open command
openwith = NaN;
if strcmp(in.figuretype,'pdf')
    openwith = gmtlab('PDFVIEWER');
elseif strcmp(in.figuretype,'eps')
    openwith = gmtlab('PSVIEWER');
end
if isnan(openwith)
    openwith = gmtlab('OPEN_COMMAND');
end
if in.display && ~any(isnan(openwith))
    command{end+1} = sprintf('%s %s/%s.%s >/dev/null &',...
        openwith,in.outdir,in.filename,in.figuretype);
end

out = exec_system_cmd(command,gmtlab('verbosity')); % execute all gathered commands

filename = sprintf('%s/%s.%s',in.outdir,in.filename,in.figuretype);

% If no viewer is defined, check for xpdf, then evince, then okular
if in.display && any(isnan(openwith)) && strcmp(in.figuretype,'pdf')
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

hunt_down_errors(command,out) % look for system call errors in the gmt calls

fprintf('GMT plot stored at:  %s\n',filename)

function file = makelegendpdf(command,in)
%% Make a separate pdf for the legend
% Only allowed to have 1 or 2 psscale commands in the commad list. the first one
% is the regular legend. The second is for the nan legend (if it exists)

file = fullfile(in.outdir,'legend');

%make sure it's not here
exec_system_cmd(sprintf('rm -f %s.ps',file),gmtlab('verbosity'));

% Make the page large enough to fit most legends
cmd = {'gmtset PAPER_MEDIA a0'};
command = [cmd, command];

%Remove trailing .ps entry
crop=regexp(command,'>>');

% Additional adjustments
for i = 2:length(command)
    command{i} = sprintf('%s -P >> %s.ps', command{i}(1:crop{i}-1), file );
    if i == 2
        command{i} = regexprep(command{i},'-O','');
    end
    if i == length(command)
        command{i} = regexprep(command{i},'-K','');
    end
end

command{end+1} = sprintf('ps2raster %s.ps -A -P -Tf',file);

exec_system_cmd(command,gmtlab('verbosity'));

%% SUBFUNCTIONS FOR SETUP
%      ||||||
%      VVVVVV

function datarange = getdatarange(in,field)
%% getdatarange

tmp = in.(field)(:);
d = double([min(tmp) max(tmp(~isinf(tmp)))]);

% Do some tricks to get the most useful datarange. (rounded, but preserve precision)
x = log10(d(2)-d(1));

datarange = [10^(round(x)-1) * round(d(1) * (1/10^(round(x)-1))),...
    10^(round(x)-1) * round(d(2) * (1/10^(round(x)-1)))];



function [stepsize,annot_format] = getstepsize(in,field)
%% getstepsize

if in.nodata
    stepsize = 0;
    annot_format='';
    return
end

% default-ish number of levels
nlev = 20;

if length(unique(in.(field)))<nlev
    nlev = length(unique(in.(field)));
end

diff = double(in.datarange(2)-in.datarange(1));

if all(isfield(in,{'stepsize','nlevels'}))
    warning('gmtlab:input','in.stepsize overrides in.nlevels')
elseif ~isfield(in,'stepsize') && isfield(in,'nlevels')
    stepsize = (in.datarange(2)-in.datarange(1))/in.nlevels;
else
    stepsize = diff/nlev;
end

annot_format = getAnnotFormat(stepsize);

function sidebar = getsidebar(in)
%% color level datastep interval
% sidebar can have the values 0,1,2,3 (none, bellow only, above only, both).

sidebar =  ( min(in.(in.fieldname)(:))<in.datarange(1) ) + ...
    2* ( max(in.(in.fieldname)(:))>in.datarange(2) );


function in = nodata(in)                                                        %% NODATA %%
%% NODATA
% if you want to only plot coastlines

in.sidebar = false;
in.legend  = false;
in.gridded = false;
in.nlevels = 1;
if isfield(in,'region')
elseif ~isfield(in,'region') && all(isfield(in,{'lat','lon'}))
    in.region = sprintf('%3.1f/%3.1f/%3.1f/%3.1f/%3.1f',...
        min(in.lon(:)),max(in.lon(:)),...
        min(in.lat(:)),max(in.lat(:)));
else
    in.region='-180/180/-90/90';
end

function in = isgridded(in,field)
%% ISGRIDDED: Test if the data is gridded
%  If it is not gridded, flatten the data

if isempty(in.(field))
    error('The data variable: in.%s is empty',field)
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
    ig = ~ (isequal(size(in.(field)),size(in.lat),size(in.lon))) ;
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

function in = isdata(in,field)
%% is there any useable data?

Id  = 'gmtlab:gmt_plot:badInput';
Eps = 1e-10;

assert(isfield(in,field), Id,'The field: "%s" is not in the structure',field)
assert(any(~isnan(in.(field)(:))),'gmtlab:gmt_plot:noData',...
    '%s%s','Data does not contain any valid',...
    ' values for contour levels to be based on...')
assert(~(ndims(squeeze(in.(field)))>2),Id,'in.%s must not be more than 2 dimensional',field)
assert((max(in.(field)(:))-min(in.(field)(:))>Eps),Id,...
    'min(data) must not be equal to max(data)')

% check for lat and lons
if ~isfield(in,'lat')
    l = {'Latitude','latitude'};
    assert(any(isfield(in,l)),Id,'No latitudes present')
    in.lat = in.(l{isfield(in,l)});
end
if ~isfield(in,'lon')
    l = {'Longitude','longitude','long'};
    assert(any(isfield(in,l)),Id,'No longitudes present')
    in.lon = in.(l{isfield(in,l)});
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
    logtext(1,'\nGMT completed with the following warning messages:\n')
    tmp = cellfun(@(x,y)(sprintf('%s\n%s\n',x,y(1:end-1))),associated_w_warning,Warnings,'UniformOutput',0);
    logtext(1,'%s\n',[tmp{:}])
    atmlab('VERBOSITY',V);
end

% error on GMT errors
if ~isempty(Errors)
    tmp = cellfun(@(x,y)(sprintf('%s\n%s\n',x,y(1:end-1))),associated_w_errors,Errors,'UniformOutput',0);
    error('gmtlab:GMT','GMT encountered the following errors:\n%s',[tmp{:}])
end

function annot_format = getAnnotFormat(quantity)
%% getAnnotFormat
% Guess a reasonable annotation format based on the provided quantity.
% in.tick_annotation_format overwrites this default value.

i = floor(log10(quantity));
if i>0
    annot_format = sprintf('%%%i.0f',i);
else
    annot_format = sprintf('%%.%if',abs(i));
end

function cleanup(tmpdir,curdir,keepfiles,V)

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