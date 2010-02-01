% GMT_PLOT plotting interface for GMT (Generic Mapping Tools)
%
% It is assumed that the data is CENTERED at the corresponding lat/lon points.
%
% FORMAT   filename = gmt_plot(in,field)
%
% OUT   filename    The filename of the figure.
%
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
% in.lon = array of longitudes
% in.lat = array of latitudes
% in.(field):
%    2) length(in.lon) = length(in.lat) = length(in.(field)) <= ungridded data
%    3) size(in.(field)) = [length(in.lat),length(in.lon)] where length(in.lat)~=length(in.lon)
%    4) size(in.(field)) = square region where
%       length(in.lat)==length(in.lon) and then .(field)(lat,lon) is assumed
%
%   -----------------------------------------------------------------------
%
% NOTE: If your data is UNGRIDDED I recommend setting:
%          in.grid=0,
%          in.increment = arcminutes (default = 60)
%
% Define the fields as empty if you don't want the following functions used.
%
% OPTIONAL INPUT      |DEFAULTS
%                     |
% Filename, title etc.
% in.grid             | 1 (i.e assumed gridded) and size(lat,lon)). If
%                       ungridded, then lat,lon,data vectors must be the same
%                       length.
% in.title            |'string';
% in.outdir           |'name/a/directory'
% in.filename          |'yourfilename', default generated from title
% in.figuretype       |'pdf', you can pick 'eps' or 'ps' instead.
%
% in.display          | true (if 0, make pdf without displaying figure.
% in.unit             |e.g: 'g/m^2' displayed over legend
% in.varname          |e.g: 'IWP'
% in.headersize       |e.g: 20  (GMT default = 36)
% in.basemap_axis     |e.g 'WSne' (only the western and southern axis and
%                     annotations). Uncapitolized ne plots the north and east
%                     axis without annotations.
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
% in.projection       |'Q'; %Cylindrical Equidistant Projection
% in.center           |180; %(longitude) 180 for entire earth otherwise middle of spatial range
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
% Contour lines:
% in.pscontour        |none;
% in.ctwidth          |0.5; width of contour lines
%
% Legends:
% in.legend =         |true     (false, if you don't want a legend)
% in.sizelegend       |'9.7i/2.3i/10c/0.8c'; %i = inch , c = cm
% in.sidebar          |true; gives triangles for lower and higher values
% in.nanlegend =      |''; if you don't want a legend
% in.sizenanlegend    |''; %i = inch , c = cm
% in.legend_orient    |''; if you want a horisontal legend: in.legend_orientation = 'h'
% in.datarange.max    |default = max(data); specify otherwise
% in.datarange.min    |default = min(data);
%
% Color table:
% in.cptfile          |[]; %path to any .cpt file generated earlier
% in.ctable           |'rainbow'
% in.nlevels          | refers to the number of contour levels
%
% Extras:
%
% in.psbox (%double)  | [lat1 lon1 lat2 lon2] % [Bottom left corner; Top right corner]
%                     to add further boxes append an extra row.
% in.psboxes          | vector containing number of boxes in one region. e.g
%                     all IPCC regions have 1 box per region.
%
%       example       | [in.psbox,in.psboxes]=list_regions({'twp','aus'});
%
% in.psboxcolor       | Default is black for every region ( 'k'={[0 0 0]}). otherwise RGB*255.
%                     append color vector in a cell for every boxregion.
% in.psboxthick       | Default is 20 for every region boundary {20}.
%                     append thick value in a cell for every boxregion boundary.
%
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
%
% 2010-01-20   Created by Salomon Eliasson

function filename = gmt_plot(in,field)

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
else out = create_ascii4gmtplot(out,field);                                     % create ascii (not gridded)
end

create_gmt_earth(out);                                                          % main function

filename=sort_figures(out);                                                     % finalize

function se = set_GMT_plot(se,field)                                            %% Set up %%

if ~isfield(se,'display')                                                       % view the figure?
    se.display=1;                                                               % 0 if you just want to create plot
end

if ~isfield(se,'figuretype'), se.figuretype='pdf'; end                          % default figure type = .eps

se.outdir = atmlab('OUTDIR');                                                   % output dir

se = makefilename(se);

if isfield(se,'nodata')&&se.nodata||isempty(se.(field))
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

if ~isfield(se,'grid')
    a = sum(size(se.lat) == size(se.(field)))==ndims(se.(field));
    b = sum(size(se.lon) == size(se.(field)))==ndims(se.(field));
    
    if a && b
        if ~isvector(se.(field))
            se.(field) = reshape(se.(field),1,numel(se.(field)));
            se.lat = reshape(se.lat,1,numel(se.(field)));
            se.lon = reshape(se.lon,1,numel(se.(field)));
        end
        se.grid = false;
        txt1 = 'is NOT';txt2='1';txt3='is';
    else
        se.grid = true;
        txt1 = 'is';txt2='0';txt3='isn''t';
    end
    fprintf('Assuming the data %s gridded...\n',txt1)
    fprintf('Include structure argument se.grid=%s if it %s.\n',txt2,txt3)
end

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
    if ~isfield(se,'title')
        se.filename = 'default';
    else se.filename = se.title;
    end
end
if ~isfield(se,'title')
    se.title = se.filename;
end

% replace bad symbols for filename and mask them for the title
se.filename = regexprep(se.title,'[:=, ()*<>!?]','_');
se.title = regexprep(se.title,'([=,()+*<>!?])','\\$1\\');
se.title = regexprep(se.title,'[:]',' ');

function filename = sort_figures(se)                                             %% Sort figures %%

if strcmp(se.figuretype,'ps')
    command = sprintf('rm -f .gmt{commands4,defaults4}');
    exec_gmt_cmd(command)
    filename=[se.filename '.ps'];
elseif strcmp(se.figuretype,'eps')
    %ps->eps
    command = sprintf('ps2eps -f -B --loose %s.ps',se.filename);exec_gmt_cmd(command)
    command = sprintf('epstool --copy -b %s.eps %s2.eps',se.filename,se.filename);exec_gmt_cmd(command)
    command = sprintf('mv %s2.eps %s.eps',se.filename,se.filename);exec_gmt_cmd(command)
    command = sprintf('rm -f %s.ps .gmt{commands4,defaults4}',se.filename);
    exec_gmt_cmd(command)
    filename = [se.filename '.eps'];
elseif strcmp(se.figuretype,'pdf') %turn the eps into a .pdf file
    command = sprintf('ps2eps -f -B --loose %s.ps',se.filename);exec_gmt_cmd(command)
    command = sprintf('epstool --copy -b %s.eps %s2.eps',se.filename,se.filename);exec_gmt_cmd(command)
    command = sprintf('mv %s2.eps %s.eps',se.filename,se.filename);exec_gmt_cmd(command)
    command = sprintf('rm -f %s.pdf',se.filename);exec_gmt_cmd(command)
    command = sprintf('epstopdf %s.eps',se.filename);exec_gmt_cmd(command)
    command = sprintf('rm -f %s.{ps,eps} .gmt{commands4,defaults4}',se.filename);
    exec_gmt_cmd(command)
    filename=[se.filename '.pdf'];
end

command=sprintf('rm -f %s.{grd,asc}',se.filename);
exec_gmt_cmd(command)

! rm -f *.cpt

if isdir(se.outdir)
    command=sprintf('mv %s %s/',filename,se.outdir);
    exec_gmt_cmd(command)
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
    system( sprintf('%s %s/%s &',openwith,se.outdir,filename));
end
filename = sprintf('%s/%s',se.outdir,filename);
fprintf('GMT plot stored at:  %s\n',filename)

