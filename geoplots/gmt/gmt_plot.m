function filename = gmt_plot(in,field)
% GMT_PLOT plotting interface for GMT (Generic Mapping Tools)
%
% The function is basically a wrapper that calls gmt shell commands using easy
% to use matlab arguments. Try test_gmt.m for some examples on how to use the function.
% It is assumed that the data is CENTERED at the corresponding lat/lon points.
% 
%
% OUT   filename  The filename of the figure.
%
% IN    in        A structure with input data and options. See below for
%                 a detailed description of the structure.
%
% OPT   field     The string name of the structure element that contains 
%                 the data to be plotted. If no field is given, 'datafield'
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
%    
% Structure contents: 
%
% MANDATORY INPUT
%
% 1) in.(field) % the data (default is field='datafield' i.e. in.datafield)
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
% NOTE: 1) If your data is UNGRIDDED I recommend setting in.increment =
%          arcminutes (default = 60) to something suitable.
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
% in.verbosity        |%f| Display non essential output | gmtlab('VERBOSITY') | 
%                     ------------                     
% in.title            |%s| Title of plot | '' |
%                     ------------                     
% in.outdir           |%s| E.g. 'name/a/directory' 
%                     |gmtlab('OUTDIR')  ('.' if not set in startup) |
%                     ------------
% in.filename         |%s| E.g. 'yourfilename' | generated from title |
%                     ------------
% in.figuretype       |%s| 'pdf','eps','png', or 'tif' | 'pdf' |
%                     ------------
% in.display          |%i| If false, file created but not displayed |true |
%                     ------------
% in.unit             |%s| String displayed on the y-axis of legend | '' |
%                     ------------
% in.xunit            |%s| String displayed on the x-axis of legend | '' |
%                     ------------
% in.ticks            |%s| 
%                     E.g '60g50/30g20'. Adds annotations to  major lines
%                     (e.g 60 xaxis (lon),50 yaxis (lat)) and displays
%                     minor lines at (e.g 30 xaxis,20 yaxis)
%                     | determined by input lat/lon range. |
%                     ------------
% in.header_size      |%f| Title size | 36 [p] |
%                     ------------
% in.basemap_axis     |%s| 
%                     E.g. 'WSne', annotates West and South of the map.
%                     | 'WSNE' |
%                     ------------
% in.header_offset    |%f| Moves the title in y-dir on the page | 0.5 [cm] |
%                     ------------
% in.gmtset           |{%s,%s,...}|
%                     Cell with one or more gmtset commands. 
%                     E.g. in.gmtset={'gmtset D_FORMAT %3.1e','gmtset ...'}
%                     | [] |
%                     ------------
% in.nodata           |%f| 
%                     If you only want a map (compatible with all options)
%                     | [] |
%                     ------------
% in.keep_files       |%f| 
%                     If you don't want to delete intermediate files
%                     | false |
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
% in.nearneighhbor.   | STRUCTURE with one or more of the following fields:  
%
%  search             |%s| 
%                     E.g. 30m' Search for data within 30 [arcmin]
%                     | Loosely based on the density of the data points |
%                     ------------
%  increment          |%s| 
%                     E.g. '60m' Increment the grid by 60 [arcmin] = 1deg
%                     | Loosely based on the density of the data points |
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
%  dimensions         |%s| 
%                     e.g '9.7i/2.3i/10c/0.8c' (i = inch , c = cm)
%                     ('x-displacement/y-displacement/height/width')
%                     | size determined by map dimensions |
%                     ------------
%  dimensions_nan     |%s| 
%                     As for dimensions, but for the NaN legend
%                     ------------
%  equalboxwidth      |%f| 
%                     If the legend color boxes have to be the same size, 1
%                     | false (-L option) |
%                     ------------                        
%  orientation        |%s|
%                     if you want a horizontal/vertical legend input 'h'/'v.
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
%                     NOTE: This options is desirable if you have many 
%                     data levels.
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
% 2011-02-22 created by Salomon Eliasson (s.eliasson@ltu.se) and Oliver Lemke

if ~exist('field','var')
    field = 'datafield';
end
if ~isfield(in,field) && ~isfield(in,'nodata')
    error('gmtlab:input',...
        'Data field: "%s" not found',field)
end

out = set_GMT_plot(in,field);

if out.gridded
    out.grdfile = [out.filename '.grd'];
    gmt_nc_save_gridded(out.lon,out.lat,out.(field),out.grdfile);
    if out.verbosity
        fprintf('Writing grdfile: %s sucessfull\n',out.grdfile)
    end
else
    if ~out.nodata
        gmt_nc_save_ungridded([out.filename '.nc'],out.(field),out.lat,out.lon);
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

[a,b] = system('gmtset 2>&1');

if a == 127
    c  = 'Either GMT is not installed';
    d  = 'you need to add its installation directory to your PATH';
    e  = 'e.g. in Matlab you can add the PATH via';
    f  = 'setenv(''PATH'',[getenv(''PATH'') '':<GMTINSTALLDIR>/bin''])';
    error('gmtlab:shell','%s%s or %s\n%s:\n%s',b,c,d,e,f)
end

% SET DEFAULTS
% general
default.verbosity         = gmtlab('VERBOSITY');% Display non essential stdout in command window
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

if isfield(in,field)
    default.datarange     = getdatarange(in,field); %
    default.nanlegend     = any(isnan(in.(field)(:))); % include NaNs in the legend
end
in = gmt_optargs_struct(in,default);


if isnan(in.outdir)
    in.outdir = tempdir;
    a = sprintf('Files are saved in your tempdir (%s)',in.outdir);
    in.outdir = in.outdir(1:end-1);
    b = 'It is better to set a default directory.';
    c = 'I.e by setting gmtlab(''OUTDIR'',''<Somewhere>''), e.g. in startup.m';
    d = 'Setting this, or inputting or inputting a valid directory: in.outdir will suppress this message.';
    warning('warning:input:outdir','%s\n%s\n%s\n%s',a,b,c,d)
end

% check outdir
if any(ismember(in.outdir,' '))
    error('gmtlab:input','"spaces" ar not supported for outdir (%s)',in.outdir)
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

% colors & data representation:
default.ctable      = 'rainbow';          % color palette
[default.stepsize,default.legend.tick_annotation_format]    = getstepsize(in);    % color level datastep interval
in = gmt_optargs_struct(in,default); clear default

in.filename = regexprep(in.filename,'[:=, ()*/<>!?]','_');
in.filename = sprintf('%s/%s',in.outdir,in.filename);
in.title = regexprep(in.title,'([=,()+*<>!?])','\\$1');
in.title = regexprep(in.title,':',' ');

%coast
if ~isfield(in,'coast') || isstruct(in.coast) || in.coast
    if ~isfield(in,'coast'), in.coast=struct([]);end
    default.rivers      = '1';  % '1' displays major rivers only. 'a' displays all.
    default.width       = .3;   % width of the coast
    
    in.coast            = gmt_optargs_struct(in.coast,default); clear default
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

% Check to see if the data  is gridded or not
in = isgridded(in,field);

% make sure that the lons,lats and data are ordered in ascending and data(lat,lon)
if in.gridded
    [in.(field),in.lat,in.lon] = homogenize_datalatlon(in.(field),in.lat,in.lon);
end

%legend
if ~isfield(in,'legend') || isstruct(in.legend) || in.legend
    if ~isfield(in,'legend') || ~isstruct(in.legend)
        in.legend=struct([]);
    end
    szdef = {[9.8 2.3 3.9 .2],[4.7 -0.4 7.1 .2]}; %inches matching map_width = 9i
    tmp = ['v','h']; %vertical,horisontal
    tmp2 = sprintf('%.2fi/',szdef{1}*in.map_width/9); sz{1} = tmp2(1:end-1);
    tmp2 = sprintf('%.2fi/',szdef{2}*in.map_width/9); sz{2} = [tmp2(1:end-1) 'h'];
    
    % when to decide to have horisontal legend
    myHcondition = ( in.lon(end)-in.lon(1) )/( in.lat(end)-in.lat(1) ) < 2*.85;
    
    default.orientation = tmp(myHcondition+1);
    if isfield(in,'legend') && isfield(in.legend,'orientation')
        default.dimensions = sz{strcmp(in.legend.orientation,'h')+1};
    else
        default.dimensions  = sz{myHcondition+1};
    end
    default.sidebar     = getsidebar(in); % coloroured triangles using in.datarange
    in.legend           = gmt_optargs_struct(in.legend,default);
end

function filename = sort_figures(in,command)                                    %% SORT FIGURES %%
%% SORT FIGURES

if in.savelegend
    % MAKE a separate file for the legend
    legend = makelegendpdf(command(~cellfun('isempty',regexp(command,'psscale'))),outdir);
    if ~in.legend
        command = command(cellfun('isempty',regexp(command,'psscale')));
    end
end

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

command{end+1} = sprintf('ps2raster %s.ps -A -P %s',in.filename,T);

command{end+1} = sprintf('rm -f .gmtcommands4 .gmtdefaults4 ');

if ~in.keep_files
    command{end+1} = sprintf('rm -f %s.{grd,asc,ps,nc} *.cpt',in.filename);
end

if isdir(in.outdir)
    [figpath, figname] = fileparts(in.filename);
    command{end+1} = sprintf('mv %s.%s %s/%s.%s', ...
        in.filename,in.figuretype,in.outdir,figname,in.figuretype);
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
    command{end+1} = sprintf('%s %s.%s >/dev/null &',...
        openwith,in.filename,in.figuretype);
end

out = exec_gmt_cmd(command,in.verbosity); % execute all gathered commands

filename = sprintf('%s.%s',in.filename,in.figuretype);

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
        fprintf('Opening file with %s for now\n',openwith)
        system(sprintf('%s %s &',openwith,filename));
    end
end

hunt_down_errors(command,out) % look for system call errors in the gmt calls

fprintf('GMT plot stored at:  %s\n',filename)

if in.savelegend
    fprintf('File containing legend is located at: %s\n',legend)
end

function legend = makelegendpdf(command,outdir)
%% Make a separate pdf for the legend

if isnan(outdir), outdir = '.'; end
file = 'legend.ps';

%make sure it's not here
basename=file(1:end-3);
exec_gmt_cmd(sprintf('rm -f %s.{ps,eps,pdf}',basename))

%Remove trailing .ps entry
crop=regexp(command,'>>');

for i = 1:length(command)
    command{i} = sprintf('%s -P >> %s', command{i}(1:crop{i}-1), file );
    if i == 1
        command{i} = regexprep(command{i},'-O','');
    end
    if i == length(command)
        command{i} = regexprep(command{i},'-K','');
    end
end

command{end+1} = sprintf('ps2raster %s.ps -A -P -Tf',file);

command{end+1} = sprintf(' mv legend.pdf %s/',outdir);

exec_gmt_cmd(command)
legend = sprintf('%s/legend.pdf',outdir);


%% SUBFUNCTIONS FOR SETUP
%      ||||||
%      VVVVVV

function datarange = getdatarange(in,field)
%% getdatarange

d = [min(in.(field)(:)) max(in.(field)(:))];

% Do some tricks to get the most useful datarange. (rounded, but preserve precision)
x = log10(d(2)-d(1));

datarange = [10^(round(x)-1) * round(d(1) * (1/10^(round(x)-1))),...
    10^(round(x)-1) * round(d(2) * (1/10^(round(x)-1)))];



function [stepsize,annot_format] = getstepsize(in)
%% getstepsize

if in.nodata
    stepsize = 0;
    annot_format='';
    return
end

% default-ish number of levels
x = 20;
diff = double(in.datarange(2)-in.datarange(1));

if all(isfield(in,{'stepsize','nlevels'}))
    warning('gmtlab:input','in.stepsize overrides in.nlevels')
elseif ~isfield(in,'stepsize') && isfield(in,'nlevels')
    stepsize = (in.datarange(2)-in.datarange(1))/in.nlevels;
else
    stepsize = diff/x;
end

% Guess a reasonable annotation format based on stepsize.
% in.tick_annotation_format overwrites this default value.
i = floor(log10(stepsize));
if i>0
    annot_format = sprintf('%%%i.0f',i);
else
    annot_format = sprintf('%%.%if',abs(i));
end

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

if ~isfield(in,field)
    error('gmtlab:input','The field: "%s" is not in the structure',field)
end
if ~any(~isnan(in.(field)))
    error('gmtlab:nodata','%s%s','Data does not contain any valid',...
        ' values for contour levels to be based on...')
end
if ndims(in.(field))>2
    error('gmtlab:input','Too many dimensions in in.%s',field)
end
% check for lat and lons
if ~isfield(in,'lat')
    l = {'Latitude','latitude'};
    if any(isfield(in,l))
        in.lat = in.(l{isfield(in,l)});
    else
        error('gmtlab:input','No latitudes present')
    end
end
if ~isfield(in,'lon')
    l = {'Longitude','longitude','long'};
    if any(isfield(in,l))
        in.lon = in.(l{isfield(in,l)});
    else error('gmtlab:input','No longitudes present')
    end
end
if in.datarange(1)==in.datarange(2)
    error('gmtlab:input','min(data) must not be equal to max(data)')
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
    fprintf('\nGMT completed with the following warning messages:\n')
    tmp = cellfun(@(x,y)(sprintf('%s\n%s\n',x,y(1:end-1))),associated_w_warning,Warnings,'UniformOutput',0);
    fprintf('%s\n',[tmp{:}])
end

% error on GMT errors
if ~isempty(Errors)
    tmp = cellfun(@(x,y)(sprintf('%s\n%s\n',x,y(1:end-1))),associated_w_errors,Errors,'UniformOutput',0);
    error('gmtlab:GMT','GMT encountered the following errors:\n%s',[tmp{:}])
end