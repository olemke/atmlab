function filename = gmt_plot(in,field)
%
% GMT_PLOT plotting interface for GMT (Generic Mapping Tools)
%
% It is assumed that the data is CENTERED at the corresponding lat/lon points.
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
%   -----------------------------------------------------------------------
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
% in.unit             |e.g: 'g/m^2' displayed over legend
% in.varname          |e.g: 'IWP'
%
% gmtdefaults:        type 'man gmtdefaults' for behaviour of following options:
%
% in.headersize       |e.g: 20  (GMT default = 36p)
% in.basemap_axis     |e.g 'WSne': prompts which axis need annotations.
%                      (GMT default = 'WSNE')
% in.header_offset    |e.g -0.5: puts title right on the axis. (GMT default = 0.5cm)
%
% .... and many more: | Just add other options you need from the list of gmtdefaults
%
%
% FOR GRIDDING:
%
% in.search           |'30m' ; %search for data within 30arcmin
% in.increment        |'60m' ; %increment the grid by 60arcmin (1deg)
%                     | If nothing is given the increment and search radius is 
%                     | loosely based on the density of the data points
%
%
% Projection & grid:
% in.grdimage         | to explicitly set the grdimage command line
% in.nearneighbor     | to explicitly set the nearneighbor command line
% in.projection       |'Q'; Cylindrical Equidistant Projection
% in.center           | not working right now....
% in.map_width        |9; nine inches
% in.proj             |'Q0/9i' ( sprintf('%s%d/%di',in.projection,in.center,in.map_width))
% in.region           e.g sprintf('%d/%d/%d/%d',lonmin,lonmax,latmin,latmax);
% in.plotimage        |grdimage;
%
% COASTLINES:
% in.pscoast          | to explicitly set the pscoast command line
% in.pscoast          |pscoast;
% in.features         |10; km^2; (do not plot features < in.features)
% in.resolution       |l; available: (f)ull, (h)igh, (i)ntermediate, (l)ow, and (c)rude
% in.rivers           |'1'; (major rivers), see GMT doc on pscoast for other options
% in.cwidth           |1; width of coastlines
% in.ticks            |'40g20/20g20'; annotations on major lines (e.g 40 xaxis,20 yaxis)
%                     and plot minor lines (e.g 20 xaxis & yaxis)
%
% CONTOURS & COLORS:
% in.ctable           |'rainbow' | 'mypolar' (nice for difference plots)
% in.cptfile          | path to any .cpt file generated earlier
% in.pscontour        |'true' if you want contour lines
% in.ctwidth          |0.5; width of contour lines
% in.nlevels          | refers to the number of contour levels
% in.reference        | Only applies when using ctable='mypolar'. Default ~=
%                     | mean(data). Recommend in.reference = 0 for difference
%                     | plots, but any reference works.
%
%
% LEGENDS:
% in.legend_orient    |if you want a horisontal/vertical/no legend: 'h'/'v'/''.
% in.sizelegend       |'9.7i/2.3i/10c/0.8c'; %i = inch , c = cm
% in.sidebar          |true; gives triangles for lower and higher values
% in.nanlegend =      |''; if you don't want a legend
% in.sizenanlegend    |''; %i = inch , c = cm
%
% VALUE RANGE
%                      GMT picks an appropriate default is field is not given
% in.datarange.max    |[min, max];  default = [min(data) max(data)];
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
% in.locations(x).lat       | Latitude of location marker x
% in.locations(x).lon       | Longitude of location marker x
% in.locations(x).name      | Name of location marker x (optional)
% in.locations(x).shape     | Shape of location marker x (default: c0.08i)
% in.locations(x).color     | Color of location marker x (default: white) (and text if textcolor if not given)
% in.locations(x).textsize  | Size of location text x (default: 15)
% in.locations(x).textcolor | Color of location text x (default: marker color)
% in.locations(x).textalign | Position of marker relative to the text
%                             first letter for horizontal position: L, C, R
%                             second letter for vertical position: T, M, B
%                             (default: LT)
%
% EXTRA EXTRAS
% If you don't want to plot data and only want a map (compatible with all options)
% in.nodata                 | tells gmt that there is no data.
% 
% If you don't want to delete intermediate files:
% in.keep_files             | true
%
% If you want to have a separate pdf for the legend:
% in.savelegend             | true
%
% $Author$
% $Date$

if ~exist('field','var'), field = 'datafield'; end
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

in.fieldname  = field;

default.display           = true;               % Display figure to screen
default.figuretype        = 'pdf';              % default figure
default.outdir            = atmlab('OUTDIR');   % where to put the figure
default.title             = '';                 % no title by default
default.nodata            = false;              % true if you only want the map
default.savelegend        = false;              % make an additional pdf-file only containing the legend
default.keep_files        = false;              % keep intermediate files (debugging)
%default.center            = 180;               % The center longitude of the
                                                %map. The region has to be
                                                %-180:180 or 0:360. but that
                                                %currently the region is
                                                %specified directly from lat/lon
                                                

in = optargs_struct(in,default);

if ~isempty(in.title)
    default.filename = in.title;
else default.filename = 'default';
end

in = optargs_struct(in,default);

% replace bad symbols for filename and mask them for the title
in.filename = regexprep(in.filename,'[:=, ()*/<>!?]','_');
in.title = regexprep(in.title,'([=,()+*<>!?])','\\$1');
in.title = regexprep(in.title,':',' ');

if in.nodata
    in = nodata(in);
    return
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

% is there useable data?
isdata(in,field)

if ~isfield(in,'datarange')                                                     % contour range
    in.datarange = [min(in.(field)(:)) max(in.(field)(:))];
end

in = regionspecial(in,field);                                                   % if region: check latlon format

in = ifcenter(in,field);                                                        % if map center is given

function filename = sort_figures(se,command)                                    %% SORT FIGURES %%
%% SORT FIGURES 

if se.savelegend
    % MAKE a separate file for the legend
    legend = makelegendpdf(command(~cellfun('isempty',regexp(command,'psscale'))),se.outdir);
    fprintf('FILE CONTAINING LEGEND IS LOCATED AT: %s\n',legend)
end

if strcmp(se.figuretype,'ps')
    filename=[se.filename '.ps'];
else
    command{end+1} = sprintf('ps2eps -f -B --loose %s.ps ',se.filename);
    command{end+1} = sprintf('epstool --copy -b %s.eps %s2.eps ',se.filename,se.filename);
    command{end+1} = sprintf('mv %s2.eps %s.eps ',se.filename,se.filename);
    command{end+1} = sprintf('rm -f %s.ps ',se.filename);
    if strcmp(se.figuretype,'pdf')
            command{end+1} = sprintf('epstopdf %s.eps ',se.filename);
            command{end+1} = sprintf('rm -f %s.eps ',se.filename);
    end
    filename = [se.filename '.' se.figuretype];
end

command{end+1} = sprintf('rm -f .gmt{commands4,defaults4} ');

if ~se.keep_files
    command{end+1} = sprintf('rm -f %s.{grd,asc} ',se.filename);
    command{end+1} = sprintf('rm -f *.cpt');
end

if isdir(se.outdir)
    command{end+1} = sprintf('mv %s %s/  ',filename,se.outdir);
else
    se.outdir=pwd;
end

if strcmp(filename(end-2:end),'pdf')
    openwith = atmlab('PDFVIEWER');
else
    openwith = atmlab('PSVIEWER');
end

if isnan(openwith)
    disp('No viewer program defined. ')
    disp('Add something like the following to your startup file')
    disp('To view PS files with ghost view: atmlab( ''PSVIEWER'',''gv'');')
    disp('To view PDF files with ex pee dee eff: atmlab( ''PDFVIEWER'',''xpdf -z width'');')
end

if se.display
    command{end+1} = sprintf('%s %s/%s &',openwith,se.outdir,filename);
end

exec_gmt_cmd(command) % execute commands

filename = sprintf('%s/%s',se.outdir,filename);
fprintf('GMT plot stored at:  %s\n',filename)

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
%
function se = nodata(se)                                                        %% NODATA %%
% if you want to only plot coastlines

se.sidebar=0;
se.legend=0;
se.grid=false;
if ~isfield(se,'region')                                                    
    se.region='-180/180/-90/90';
elseif all(isfield(se,{'lat','lon'}))
    se.region = sprintf('%d/%d/%d/%d',...
        min(min(se.lon)),max(max(se.lon)),...
        min(min(se.lat)),max(max(se.lat)));
    se.nodata=1;
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

fprintf('max data value: %2.1f\nmin data value: %2.1f\n',...
max(max((se.(field)))),min(min(se.(field))))

function isdata(se,field)                                                       %% ISDATA %%
%% is there useable data?

if ~isempty(field)                                                              % is there data?
  if ~isfield(se,field)
    error('atmlab:input','The field: "%s" is not in the structure',field)
  end

  if se.grid
    if ~ ( size(se.(field),1) == length(se.lat) && size(se.(field),2) == ...
           length(se.lon) )
      error('atmlab:input','in.%s must have the dimensions (lat,lon)',field)
    end
  end
end

if ~any(~isnan(se.(field)))                                                     % data?
    error('atmlab:nodata','%s%s','Data does not contain any valid',...
        ' values for contour levels to be based on...')
end

function se = regionspecial(se,field)                                           %% REGIONSPECIAL %%
%% if region: check latlon format
if isfield(se,'region')                           
    if ~ischar(se.region)
        %[blcorner,trcorner]
        r = se.region;
        se.region = sprintf('%d/%d/%d/%d',min(r(:,2)),max(r(:,4)),min(r(:,1)),max(r(:,3)));
    end
    x = textscan(se.region','%f','delimiter','/');
    if x{1}(2) > 180
        [se.(field),se.lat,se.lon] = flipdata(se.(field),se.lat,se.lon);
    end
end

function se = ifcenter(se,field)                                                %% IFCENTER %%
%% if map center is given
% Picking a center just doesn't work right now....

se.(field) = [se.(field)(:,se.lon >= 180), se.(field)(:,se.lon < 180)];
se.lon = [se.lon(se.lon >= 180); se.lon(se.lon < 180)];
se.lon(se.lon >= 180) = se.lon(se.lon >= 180) - 360;