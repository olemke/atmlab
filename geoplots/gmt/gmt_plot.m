function filename = gmt_plot(in,field)
%% gmt_plot
%
% GMT_PLOT plotting interface for GMT (Generic Mapping Tools)
%
% It is assumed that the data is CENTERED at the corresponding lat/lon points.
% 
%
% OUT   filename    The filename of the figure.
%
% IN    in        A structure with input data and options. See below for
%                 a detailed description of the structure.
%
% OPT   field     The string name of the structure element that contains the
%                 data to be plotted. If no field is given, 'datafield' is
%                 assumed.
%
% Easy example: If you just want to plot some data..
%                 in.somefield = data2plot
%                 in.lon  = longitudes 
%                 in.lat  = latitudes
%
%                 file = gmt_plot(in,'somefield');
%
% SEE BELOW for the rest of the available arguments
%    
% Structure contents: 
%
% MANDITORY INPUT
%
% 1) in.(field) % the data (default is field = 'datafield', i.e. in.datafield)
% 2) in.lat     % the corresponding latitudes
% 3) in.lon     % the corresponding longitudes
%
% If your data is ungridded the dimensions must be:
% length(in.lon) = length(in.lat) = length(in.(field))
%
% If your data is gridded the data MUST have the dimensions:
% [length(in.lat),lenght(in.lon)] = size(in.(field));
%  << transpose: in.(field) = in.(field)'; if this is not the case >>
%
% NOTE: 1) If your data is UNGRIDDED I recommend setting:
%          in.increment = arcminutes (default = 60)
%       2) gmt_plot automatically detects if the data is gridded or not
%
%
%
% OPTIONAL INPUT      |DEFAULTS
%                     |
% Filename, title etc.
% in.title            |'string';
% in.outdir           |'name/a/directory'
% in.filename         |'yourfilename', default generated from title
% in.figuretype       |'pdf', you can pick 'eps' or 'ps' instead.
%
% in.display          | true (if 0, make pdf without displaying figure.
% in.unit             |e.g: 'g/m^2' displayed on the y-axis of the legend (default axis)
% in.xunit            | as in.unit except for the x-axis
% in.varname          |e.g: 'IWP'
%
% gmtdefaults:        type 'man gmtdefaults' for behaviour of following options:
%
% in.ticks            |'60g60/30g30'; annotations on major lines (e.g 40 xaxis,20 yaxis)
%                     and plot minor lines (e.g 20 xaxis & yaxis)
% in.header_size      |e.g: 20  (GMT default = 36p)
% in.basemap_axis     |e.g 'WSne': prompts which axis need annotations.
%                      (GMT default = 'WSNE')
% in.header_offset    |e.g -0.5: puts title right on the axis. (GMT default = 0.5cm)
% in.gmtset           | cell with one or more gmtset commands. e.g. in.gmtset={'gmtset D_FORMAT %3.1e','ect'}
%
% .... and many more: | Just add other options you need from the list of gmtdefaults
%
%
% FOR GRIDDING:
%       Using nearneighbor
% in.search           |'30m' ; %search for data within 30arcmin
% in.increment        |'60m' ; %increment the grid by 60arcmin (1deg)
%                     | If nothing is given the increment and search radius is
%                     | loosely based on the density of the data points
%
%
% Projection & grid:
% in.grdimage         | to explicitly set the grdimage command line
% in.nearneighbor     | to explicitly set the nearneighbor command line
%
% in.projection       | e.g. 'Q'
% in.center           | Center longitudes to given center
% in.map_width        | inches
% in.proj             | e.g. 'Q0/9i' ( sprintf('%s%d/%di',in.projection,in.center,in.map_width))
% in.region           | e.g sprintf('%d/%d/%d/%d',lonmin,lonmax,latmin,latmax);
%
% COASTLINES:
% in.pscoast          | to explicitly set the pscoast command line
%
% in.features         |10 (do not plot features < in.features) [km^2]
% in.resolution       |l (available: (f)ull, (h)igh, (i)ntermediate, (l)ow, and (c)rude )
% in.rivers           |1 (major rivers), see GMT doc on pscoast for other options
% in.cwidth           |1 width of coastlines
%
% COLORS:
%
% in.color_background | set the background color (values less than range)
% in.color_foreground | set the foreground color (values greater tham range)
% in.color_nan        | set the color of NaNs
% in.cptfile          | path to any .cpt file generated earlier
% in.nlevels          | refers to the number of contour levels (converted to stepsize using datarange)
% in.stepsize         | The stepsize between data values. This overrides nlevels (-T/min/max/stepsize in makecpt)
%
% For your own color table. Specify the contour levels and colors directly (need both) 
% in.ctable_clevels   | e.g. [1000 1002 1015 1030]
% in.ctable_colors    | e.g. {[0 0 0],[155 0 0],[255 0 0],[0 0 0],[255 255 255]}
%                         has to be in vector RGB format and the last 2 elements
%                         are background and foreground colors
%
% in.ctable           |See GMT color paletts. 'mypolar' is a nice colortable for difference plots.
%                     if strcmp(in.ctable,'mypolar')
%                       in.reference == mean(data(:)). (default)
%                       % Recommend set in.reference = 0 for difference plots,
%                       % but any reference works.
%                     
%                       in.whiteboxes | The number of white contours around a reference value
%                     end
%
% For your own custom colortable use in.colorrange.colors (see below). Assign a
% color to a relative value, e.g between 0-1, where 0 is for the minimum of the
% datarange and 1 is for the color of the maximum datarange. For example,
% in.colorrange.colors = {{0,'red'},{.3,'black'},{0.5,'green'},{1,'blue'}},
% makes a colortable that goes from red to black to green to blue.
% 
% in.colorrange.colors      | {{%d,'color'},{%d,'color2'},etc.} 
%              color can be give as e.g. '255/0/0' (red in RGB)
% in.colorrange.color_model |  'RGB', '+HSV', or '-HSV'
%
%
% LEGENDS:
% in.psscale          | to explicitly set the pscale on the command line
% in.psscale_nan      | to explicitly set the pscale for NaN legend on the command line
%
% in.savelegend       | true: if you want to have a separate pdf for the legend
% in.legend           | false; if you don't want a legend
% in.nanlegend        | false; if you don't want an extra NaN legend
% in.tickcentering    | true; Have ticks at the center of the boxes (default=edges)
% in.tickspacing      | if you want to manually decide how the ticks in the
%                       legend should be spread. x=> every xth data value,
%                       1=>same number of ticks as datarange, []= one tick per
%                       contour level (default behaviour). desirable if you have
%                       many contour levels.
% in.tick_annotation_format
%                     | e.g. '%3.1e'
% in.tick_length      | length of the ticks
% in.annot_font_size_primary
%                     | size of annotations in legend
% in.tick_annotations | e.g {'','','middle','',''} if you have 5 ticks in legend
% in.shift_tick_annotations
%                     | move tick annotions to the right by x inches (e.g
%                     0.5)
% in.equalboxwidth
%                     | false (-L option)
% in.legend_orient    |if you want a horisontal/vertical/no legend: 'h'/'v'/''.
% in.legendsize       |'9.7i/2.3i/10c/0.8c'; %i = inch , c = cm
% in.legendbox_spacing| space between legend boxes (%d)
%
% in.sidebar          |0,1,2,or 3. Indicates none, bellow range only, above -||-, or both
% in.sizenanlegend    |''; %i = inch , c = cm
%
% VALUE RANGE
%                      GMT picks an appropriate default is field is not given
% in.datarange        |[min, max];  default = [min(data) max(data)];
%
% EXTRAS:
% in.psbox (%double)  | [lon11 lat11 lon12 lat12; lon21 lat21 lon22 lat22; ect]
%                        [Bottom left corner , Top right corner; ...]
%
% in.psboxes          | The index of the last row of the regions. e.g 3 7, if
%                       you have 2 regions defined by 3 resp 4 boxes. This is
%                       useful for defining psboxcolor.
%
% in.psboxcolor       | Default is black for every region ( 'k'={[0 0 0]}). otherwise RGB*255.
%                     append color vector in a cell for every boxregion.
% in.psboxthick       | Default is 20 for every region boundary {20}.
%                     append thick value in a cell for every boxregion boundary.
%
% in.pspoly (%double) | {[lon1 lat1; lon2 lat2; ...]}
%                       Draws a polygon. Use one cell row per polygon:
%                       {[p1lon1 p1lat1; p1lon2 p1lat2; ...];
%                        [p2lon1 p2lat1; p2lon2 p2lat2; ...];
%                        ...}
%
% in.pspolycolor       | See in.psboxcolor
%
% in.pspolythick       | See in.psboxthick
%
% LOCATION MARKERS:
%
% in.locations.lat          | Latitude of location marker x
% in.locations.lon          | Longitude of location marker x
% in.locations.name         | Name of location marker x (optional)
% in.locations.shape        | Shape of location marker x (default: c0.08i)
%                             if empty => don't draw dot
% in.locations.color        | Color of location marker x (default: white) (and text if textcolor if not given)
% in.locations.textsize     | Size of location text x (default: 15)
% in.locations.textcolor    | Color of location text x (default: marker color)
% in.locations.textalign    | Position of marker relative to the text
%                             first letter for horizontal position: L, C, R
%                             second letter for vertical position: T, M, B
%                             (default: LT)
%  for muliple locations define all fields according to : 
%  in.locations(1).name = 'x',
%  in.locations(2).name = 'y', etc...
%
%
% CONTOUR LINES
% in.grdcontour.spacing     | scalar
% in.grdcontour.range       | [min max]
% in.grdcontour.linethick   | scalar
%  if several contour plots should overlap define all fields according to: 
%  in.grdcontour(1).spacing = x,
%  in.grdcontour(2).spacing = y, etc...
%
% EXTRA EXTRAS
% If you don't want to plot data and only want a map (compatible with all options)
% in.nodata                 | tells gmt that there is no data.
%
% If you don't want to delete intermediate files:
% in.keep_files             | true
%
%
% $Author$
% $Date$

if ~exist('field','var') && ~isfield(in,'datafield') && ...
        isfield(in,'nodata') && ~in.nodata
    error('atmlab:input',...
        'Need name of structure field to plot. input field = ''str'' or name the field ''datafield''')
elseif ~exist('field','var')
    field = 'datafield';
end
out = set_GMT_plot(in,field);                                                   % setup

if out.grid
    out.grdfile = [out.filename '.grd'];
    write_gmtgrid(out.lon,out.lat,out.(field),out.grdfile);                     % writegmt (gridded)
    fprintf('Writing grdfile: %s sucessfull\n',out.grdfile)
else
    out = save_ungridded4GMTplot(out,field);                                    % create ascii (not gridded)
end

commands = create_gmt_earth(out);                                               % main function

filename=sort_figures(out,commands);                                            % finalize

%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%     ||||
%     vvvv
function in = set_GMT_plot(in,field)
%% SETUP %%

% CHECK input type
check_optional_input(in);

% SET DEFAULTS
default.display           = true;               % Display figure to screen
default.figuretype        = 'pdf';              % default figure
default.outdir            = atmlab('OUTDIR');   % where to put the figure
default.map_width         = 9;                  % inches
default.ticks             = '60g60/30g30';      % grid majorx'deg'minorx/majory'deg'minory
default.projection        = 'Q';                % Cylindrical Equidistant Projection. Projection Will only work with format: 'Q0/9i' ('%s%3.0f/%ii'in.projection,in.center,in.map_width))
                                                % otherwise specify in.proj explicitly with the full projection command

default.title             = '';                 % no title by default
default.nodata            = false;              % true if you only want the map
default.savelegend        = false;              % make an additional pdf-file only containing the legend
default.keep_files        = false;              % keep intermediate files (debugging)
default.ctable            = 'rainbow';          % color palette
default.legend            = true;               % show a legend
default.legend_orient     = 'v';                % orientation of the legend (h = horisontal, v = vertical)
default.unit              = '';                 % unit displayed with legend
default.xunit             = '';                 % xlabel for the legend
default.nanlegend         = any(isnan(in.(field)(:))); % include NaNs in the legend
default.tickspacing       = [];                 % [] Show values every xth contour level. Otherwise tickspacing based on datarange
default.center            = 0;                  % The center longitude of the map. The region has to be -180:180 (cyclic)

in = optargs_struct(in,default);

default.datarange         = getdatarange(in,field);
if ~isempty(in.title), default.filename = in.title; else default.filename = 'default'; end

in = optargs_struct(in,default);

% replace bad symbols for filename and mask them for the title
in.filename = regexprep(in.filename,'[:=, ()*/<>!?]','_');
in.title = regexprep(in.title,'([=,()+*<>!?])','\\$1');
in.title = regexprep(in.title,':',' ');

if in.nodata
    % If I only want an empty map, get the essentials and leave here.
    in = nodata(in);
    return
end

if ~ismember(field,fieldnames(in))
     error('atmlab:input','no field by the name of "%s" in struct',field)
end

in.fieldname  = field;

default.stepsize          = getstepsize(in); % color level datastep interval
default.sidebar           = getsidebar(in); % coloroured triangles for data outside max/min legend
in = optargs_struct(in,default);

if ndims(in.(field))>2
    error('atmlab:input','Too many dimensions in in.%s',field)
end
% check for lat and lons
if ~isfield(in,'lat')
    l = {'Latitude','latitude'};
    if any(isfield(in,l))
        in.lat = in.(l{isfield(in,l)});
    else error('atmlab:input','No latitudes present')
    end
end
if ~isfield(in,'lon')
    l = {'Longitude','longitude','long'};
    if any(isfield(in,l))
        in.lon = in.(l{isfield(in,l)});
    else error('atmlab:input','No longitudes present')
    end
end

% Check to see if the data  is gridded or not
in = isgridded(in,field);

% is the data plotable?
isdata(in,field)

% make sure that the lons,lats and data are ordered in ascending and data(lat,lon)
[in.(field),in.lat,in.lon] = homogenize_datalatlon(in.(field),in.lat,in.lon);


function filename = sort_figures(se,command)                                    %% SORT FIGURES %%
%% SORT FIGURES

if se.savelegend
    % MAKE a separate file for the legend
    legend = makelegendpdf(command(~cellfun('isempty',regexp(command,'psscale'))),se.outdir);
    if ~se.legend
        command = command(cellfun('isempty',regexp(command,'psscale')));
    end
end

% for figuretypes
switch se.figuretype
    case 'pdf'
        T = '-Tf';
    case 'eps'
        T = '-Te';
    case 'png'
        T = '-Tg -Qg -Qt';
    case 'tif'
        T = '-Tt -Qg -Qt';
    otherwise
        error('Atmlab:figuretype','%s: not supported',se.figuretype)
end

command{end+1} = sprintf('ps2raster %s.ps -A -P %s',se.filename,T);

command{end+1} = sprintf('rm -f .gmt{commands4,defaults4} ');

if ~se.keep_files
    command{end+1} = sprintf('rm -f %s.{grd,asc,ps} *.cpt',se.filename);
end

if isdir(se.outdir)
     command{end+1} = sprintf('mv %s.%s %s/  ',se.filename,se.figuretype,se.outdir);
else
    se.outdir=pwd;
end

openwith = NaN;
if strcmp(se.figuretype,'pdf')
    openwith = atmlab('PDFVIEWER');
elseif strcmp(se.figuretype,'eps')
    openwith = atmlab('PSVIEWER');
end
if isnan(openwith)
    openwith = atmlab('OPEN_COMMAND');
end
if isnan(openwith)
    disp('No viewer program defined. ')
    disp('Add something like the following to your startup file')
    disp('To view PS files with ghost view: atmlab( ''PSVIEWER'',''gv'');')
    disp('To view PDF files with ex pee dee eff: atmlab( ''PDFVIEWER'',''xpdf -z width'');')
end

if se.display
    command{end+1} = sprintf('%s %s/%s.%s &',openwith,se.outdir,se.filename,se.figuretype);
end

out = exec_gmt_cmd(command,atmlab('VERBOSITY')); % execute commands

hunt_down_errors(command,out)

filename = sprintf('%s/%s.%s',se.outdir,se.filename,se.figuretype);
fprintf('GMT plot stored at:  %s/%s.%s\n',se.outdir,se.filename,se.figuretype)

if se.savelegend
    fprintf('File containing legend is located at: %s\n',legend)
end

function legend = makelegendpdf(command,outdir)
%% Make a separate pdf for the legend

file = 'legend.ps';

%make sure it's not here
exec_gmt_cmd(sprintf('rm -f %s.{ps,eps,pdf}',file(1:end-3)))

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

command{end+1} = sprintf(' ps2eps -f -B --loose legend.ps ');
command{end+1} = sprintf(' epstool --copy -b legend.eps legend2.eps ');
command{end+1} = sprintf(' mv legend2.eps legend.eps ');
command{end+1} = sprintf(' epstopdf legend.eps ');
command{end+1} = sprintf(' mv legend.pdf %s/',outdir);

exec_gmt_cmd(command)
legend = sprintf('%s/legend.pdf',outdir);


%% SUBFUNCTIONS FOR SETUP
%      ||||||
%      VVVVVV
function check_optional_input(in)
%% check_optional_input
% Note: I want to put all legend things in a structure and all psbox things in a
% structure

fields = fieldnames(in);

% STRINGS
checkinput(1,:) = {@ischar,'string'...
     {'basemap_axis','cptfile','ctable','figuretype','filename','grdimage',...
     'increment','legend_orient','legendsize','nearneighbor','outdir','proj',...
     'projection','pscoast','psscale','psscale_nan','region','resolution',...
     'search','sizenanlegend','tick_annotation_format','ticks','title','unit',...
     'varname','xunit'}};

% SCALARS/VECTORS
checkinput(2,:) = {@(x)(isnumeric(x) | islogical(x)),'scalar/array',...
    {'annot_font_size_primary','center','ctable_clevels','cwidth','datarange',...
    'display','equalboxwidth','features','header_offset','header_size',...
    'keep_files','legend','legendbox_spacing','map_width','nanlegend','nlevels',...
    'nodata','psbox','psboxes','reference','rivers','savelegend',...
    'shift_tick_annotations','sidebar','stepsize','tick_length',...
    'tickcentering','tickspacing','whiteboxes'}};

% CELLS
checkinput(3,:) = {@iscell,'cell',...
    {'ctable_colors','gmtset','psboxcolor','psboxthick','pspoly',...
    'pspolycolor','pspolythick','tick_annotations'}};

% STRUCTURES
checkinput(4,:) = {@isstruct,'structure',{'colorrange','grdcontour','locations'}};

for i = 1:4
    % test structure arguments: 
    % e.g. cellfun(@(x)(ischar(in.(x))),{'unit','title'}), 
    %       where in.title='str'; in.unit='str2';
    F = fields(ismember(fields,checkinput{i,3}));
    test = ~cellfun(@(x)(checkinput{i,1}(in.(x))),F);
    if any(test)
        err=cellfun(@(x,y)(sprintf('in.%s must be of type: %s',x,y)),...
            F(test),repmat(checkinput(i,2),length(F(test)),1),'uniformoutput',0);
        error('atmlab:input','\n%s',err{:})
    end
end

function datarange = getdatarange(in,field)
%% getdatarange


d = [min(in.(field)(:)) max(in.(field)(:))];
if d(2)-(1)>10
    datarange = [floor(d(1)) ceil(d(2))];
else
    datarange = d;
end


function stepsize = getstepsize(in)
%% getstepsize

% default-ish number of levels
x = 20;
diff = in.datarange(2)-in.datarange(1);

if all(isfield(in,{'stepsize','nlevels'}))
    warning('atmlab:input','in.stepsize overrides in.nlevels')
elseif ~isfield(in,'stepsize') && isfield(in,'nlevels')
    stepsize = (in.datarange(2)-in.datarange(1))/in.nlevels;
elseif diff >= x
    stepsize = floor((diff-1)/x)+1;
else stepsize = diff/x;
end

function sidebar = getsidebar(in)
%% color level datastep interval
% sidebar can have the values 0,1,2,3 (none, bellow only, above only, both). 

sidebar =  ( min(in.(in.fieldname)(:))<in.datarange(1) ) + ...
    2* ( max(in.(in.fieldname)(:))>in.datarange(2) );


function se = nodata(se)                                                        %% NODATA %%
%% NODATA
% if you want to only plot coastlines

se.sidebar = false;
se.legend  = false;
se.grid    = false;
se.nlevels = 1;
if isfield(se,'region')
elseif ~isfield(se,'region') && all(isfield(se,{'lat','lon'}))
        se.region = sprintf('%3.1f/%3.1f/%3.1f/%3.1f/%3.1f',...
        min(min(se.lon)),max(max(se.lon)),...
        min(min(se.lat)),max(max(se.lat)));
else
    se.region='-180/180/-90/90';
end

function se = isgridded(se,field)                                               %% ISGRIDDED %%
%% Test if the data is gridded

if isempty(se.(field))
    error('The data variable: se.%s is empty',field)
end

if ndims(se.(field))==3                                                         % test if I need to use squeeze
    se.(field) = squeeze(se.(field));
end

%% Check to see if the data is gridded or not.
[a,b]=size(se.(field));

pos1 = a==length(se.lat)&b==length(se.lon); %(lat,lon)
pos2 = b==length(se.lat)&a==length(se.lon); %(lon,lat)

% if (pos1 && pos2) && (pos1 || pos2), then we dont know if it gridded, but
% assume it's not.
ig = ~(pos1 && pos2) && (pos1 || pos2);

if ~ig
    se.(field) = se.(field)(:);
    se.lat = se.lat(:);
    se.lon = se.lon(:);
    if ~isfield(se,'grid'), se.grid = false; end
    txt1 = 'is NOT';txt2='1';txt3='is';
else
    if pos2, se.(field)=se.(field)';end % want it in (lat,lon)
    if ~isfield(se,'grid'), se.grid = true; end
    txt1 = 'is';txt2='0';txt3='isn''t';
end

fprintf('Assuming the data %s gridded...\n',txt1)
fprintf('Include structure argument se.grid=%s if it %s.\n',txt2,txt3)
fprintf('max data value: %3.1d\nmin data value: %3.1d\n',max(se.(field)(:)),min(se.(field)(:)))

function isdata(se,field)                                                       %% ISDATA %%
%% is there useable data?

if ~isempty(field)                                                              % is there data?
    if ~isfield(se,field)
        error('atmlab:input','The field: "%s" is not in the structure',field)
    end
    
    if se.grid
        if ~ ( size(se.(field),1) == length(se.lat) && ...
                size(se.(field),2) == length(se.lon) )
            error('atmlab:input','in.%s must have the dimensions (lat,lon)',field)
        end
    end
end

if ~any(~isnan(se.(field)))                                                     % data?
    error('atmlab:nodata','%s%s','Data does not contain any valid',...
        ' values for contour levels to be based on...')
end

function hunt_down_errors(command,errors)
%% Hunt down any errors encounted using GMT

% messages containing any of these are exempted
error_exeptions = {'warning'}; 
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
    error('atmlab:GMT','GMT encountered the following errors:\n%s',[tmp{:}])
end