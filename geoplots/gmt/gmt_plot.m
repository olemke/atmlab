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
% 1) in.(field) % the data
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
% NOTE: If your data is UNGRIDDED I recommend setting:
%          in.increment = arcminutes (default = 60)
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
% For gridding:
% in.search           |30 ; %search for data within 30arcmin
%                      Can also give a string arg if you don't want minutes e.g
%                      in.search = '250k' (250km)
%                      string appended with 'k' for search radius in km
% in.increment        |60 ; %increment the grid by 60arcmin (k = km)
%                      Can also give a string arg if you don't want minutes e.g
%                      in.increment = '500k' (500km)
%
% Projection & grid:
% in.grdimage         | to explicitly set the grdimage command line
% in.nearneighbor     | to explicitly set the nearneighbor command line
% in.projection       |'Q'; Cylindrical Equidistant Projection
% in.center           |180; (longitude) 180 for entire earth otherwise middle
% in.map_width        |9; nine inches
% in.proj             |'Q180/9i' ( sprintf('%s%d/%di',in.projection,in.center,in.map_width))
% in.region           e.g sprintf('%d/%d/%d/%d',lonmin,lonmax,latmin,latmax);
% in.plotimage        |grdimage;
%
% Coastlines:
% in.pscoast          | to explicitly set the pscoast command line
% in.pscoast          |pscoast;
% in.features         |10; km^2; (do not plot features < in.features)
% in.resolution       |l; available: (f)ull, (h)igh, (i)ntermediate, (l)ow, and (c)rude
% in.rivers           |'1'; (major rivers), see GMT doc on pscoast for other options
% in.cwidth           |1; width of coastlines
% in.ticks            |'40g20/20g20'; annotations on major lines (e.g 40 xaxis,20 yaxis)
%                     and plot minor lines (e.g 20 xaxis & yaxis)
%
% CONTOUR LINES:
% in.ctable           |'rainbow'
% in.cptfile          | path to any .cpt file generated earlier
% in.pscontour        |'true' if you want contour lines
% in.ctwidth          |0.5; width of contour lines
% in.nlevels          | refers to the number of contour levels
%
%
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
% in.datarange.max    |default = max(data); specify otherwise
% in.datarange.min    |default = min(data);
%
%
% Extras:
%
%
% in.psbox (%double)  | [lat1 lon1 lat2 lon2] % [Bottom left corner; Top right corner]
%                     to add further boxes append an extra row.
% in.psboxes          | The index of the last row of the regions. e.g 3 7, if
%                       you have 2 regions defined by 3 resp 4 boxes. This is
%                       useful for defining psboxcolor.
%
%
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
%%
% Location markers:
%
% in.locations(x).lat       | Latitude of location marker x
% in.locations(x).lon       | Longitude of location marker x
% in.locations(x).name      | Name of location marker x (optional)
% in.locations(x).shape     | Shape of location marker x (default: c0.08i)
% in.locations(x).color     | Color of location marker x (default: white)
% in.locations(x).textsize  | Size of location text x (default: 15)
% in.locations(x).textcolor | Color of location text x (default: marker color)
% in.locations(x).textalign | Position of marker relative to the text
%                             first letter for horizontal position: L, C, R
%                             second letter for vertical position: T, M, B
%                             (default: LT)
%
%
% If you don't want to plot data and only want a map (compatible with all options)
% in.nodata                 | tells gmt that there is no data.
% in.(field)=[];            | gives the same effect as in.nodata.
% 
% If you don't want to delete intermediate files:      se,'keep_intermediate'           
%
% 2010-03-04   Created by Salomon Eliasson

if ~exist('field','var'), field = 'datafield'; end

out = set_GMT_plot(in,field);                                                   % setup

if out.grid
    out.grdfile = [out.filename '.grd'];
    try
        write_gmtgrid(out.lon,out.lat,out.(field),out.grdfile);                 % writegmt (gridded)
        fprintf('Writing grdfile: %s sucessfull\n',out.grdfile)
    catch me
        if strcmp(me.identifier,'MATLAB:netcdf:putVar:dataSizeMismatch')
            error('Dimension mismatch: data,lat,lon')
        else
            m=me.stack(1);
            error('%s line %d: %s',m.name,m.line,me.message)
        end
    end
else
    out = save_ungridded4GMTplot(out,field);                                   % create ascii (not gridded)
end

create_gmt_earth(out);                                                          % main function

filename=sort_figures(out);                                                     % finalize

function se = set_GMT_plot(se,field)                                            %% Set up %%

if ~isfield(se,'display')                                                       % view the figure?
    se.display=1;                                                               % 0 if you just want to create plot
end

if ~isfield(se,'figuretype'), se.figuretype='pdf'; end                          % default figure type = .eps

if ~isfield(se,'outdir')
    se.outdir = atmlab('OUTDIR');                                               % output dir
end
se = makefilename(se);

if isfield(se,'nodata')&&se.nodata
    field = '';
end
if ~isempty(field) 
    if ~isfield(se,field)
    error('The field: "%s" is not in the structure',field)
    end
    [a,b]=size(se.(field));
    if a>b, error('in.%s must have the dimensions %dx%d (lat,lon)',field,b,a);end
end
if isempty(field) || isempty(se.(field))
    se.sidebar=0;
    se.legend=0;
    se.grid=0;
    if ~isfield(se,'region')                                                    % REGION
        se.region='-180/180/-90/90';
    elseif isfield(se,field)
        se.region = sprintf('%d/%d/%d/%d',...
        min(min(se.lon)),max(max(se.lon)),...
        min(min(se.lat)),max(max(se.lat)));
    se.nodata=1;
    end
    return
end
if ~sum(~isnan(se.(field)))                                                     % data?
    error('%s%s','Data does not contain any valid',...
        ' values for contour levels to be based on...')
end

if ndims(se.(field))==3                                                         % test if I need to use squeeze
    se.(field) = squeeze(se.(field));
end

if ~strcmp(class(se.(field)),'double')                                          %the data has to be double (or single?)
    se.(field) = double(se.(field));
end


isgridded = size(se.(field),1) == length(se.lat) && size(se.(field),2) == length(se.lon);
if ~isgridded
    se.(field) = se.(field)(:);
    se.lat = se.lat(:);
    se.lon = se.lon(:);
    se.grid = false;
    txt1 = 'is NOT';txt2='1';txt3='is';
else
    se.grid = true;
    txt1 = 'is';txt2='0';txt3='isn''t';
end
fprintf('Assuming the data %s gridded...\n',txt1)
fprintf('Include structure argument se.grid=%s if it %s.\n',txt2,txt3)

fprintf('max data value: %2.1f\nmin data value: %2.1f\n',...
    max(max((se.(field)))),min(min(se.(field))))

if ~isfield(se,'datarange')                                                     % contour range
    se.datarange.max = max(max(se.(field)));
    se.datarange.min = min(min(se.(field)));
end
if isfield(se,'region')                                                         % if region: check latlon format
    x = textscan(se.region','%f','delimiter','/');
    if x{1}(2) > 180
        [se.(field),se.lat,se.lon] = flipdata(se.(field),se.lat,se.lon);
    end
end

if isfield(se,'center') && se.center~=0
    x = (se.(field)(:,1)+se.(field)(:,end))/2;
    if min(se.lon)>-180
        se.lon = [-180,se.lon];
        se.(field) = [x,se.(field)];
    end
    if max(se.lon)<180
        se.lon = [se.lon,180];
        se.(field) = [se.(field),x];
    end
    
end

function se = makefilename(se)                                                  %% Make file name %%

if ~isfield(se,'filename')
    if ~isfield(se,'title') || isempty(se.title)
        se.filename = 'default';
    else se.filename = se.title;
    end
end
if ~isfield(se,'title')
    se.title = se.filename;
end

% replace bad symbols for filename and mask them for the title
se.filename = regexprep(se.filename,'[:=, ()*/<>!?]','_');
se.title = regexprep(se.title,'([=,()+*<>!?])','\\$1');
se.title = regexprep(se.title,'[:]',' ');

function filename = sort_figures(se)                                             %% Sort figures %%

command{1} = [];
if strcmp(se.figuretype,'ps')
    command{end+1} = sprintf('rm -f .gmt{commands4,defaults4} ');
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

if ~isfield(se,'keep_intermediate') || ~se.keep_intermediate
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

exec_gmt_cmd(command(2:end)) % execute commands

filename = sprintf('%s/%s',se.outdir,filename);
fprintf('GMT plot stored at:  %s\n',filename)