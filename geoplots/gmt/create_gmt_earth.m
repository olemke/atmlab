function create_gmt_earth(se)
%           create_gmt_earth
%
% See gmt_plot for input details
%
% 4/12-2009 Salomon Eliasson

se = setup_create_gmt_earth(se);                                                % Most options are assigned here

command = sprintf('rm -f %s.{ps,eps}',se.filename);                             % Remove earlier .ps files
exec_gmt_cmd(command)

command = 'gmtset PAPER_MEDIA a0';                                              % Set paper sizeBASEMAP_AXES
exec_gmt_cmd(command)

if isfield(se,'headersize')                                                     % Size of title
    command = sprintf('gmtset HEADER_FONT_SIZE %dp',se.headersize);
    exec_gmt_cmd(command)
end

if isfield(se,'basemap_axis')                                                   % Annotations of axis
    command = sprintf('gmtset BASEMAP_AXES %s',se.basemap_axis);
     exec_gmt_cmd(command)
end
if isfield(se,'header_offset')                                                  % Distance from axis to Annotation
    command = sprintf('gmtset HEADER_OFFSET %c',se.header_offset);
    exec_gmt_cmd(command)
end

if isfield(se,'nearneighbor')                                                   % Nearneighbor
    command = se.nearneighbor;
    exec_gmt_cmd(command)
elseif ~se.grid && isfield(se.plot,'grid')
    command = nearneighbor(se.plot.grid);
    exec_gmt_cmd(command)
end

if isfield(se,'grdimage')                                                       % Image
    command = se.grdimage;
    exec_gmt_cmd(command)
elseif ~isfield(se,'nodata') && strcmp(se.plot.plotimage.name,'grdimage') 
    command = grdimage(se.plot.plotimage);
    exec_gmt_cmd(command)
end

if isfield(se,'pscoast')                                                        % Coastlines
    command = se.pscoast;
    exec_gmt_cmd(command)
else
    command = pscoast(se.plot.coast);
    exec_gmt_cmd(command)
end

if isfield(se,'locations')                                                      % Location markers
    command = pslocations(se);
    exec_gmt_cmd(command)
end

if isfield(se.plot,'pscontour') && ~isempty(se.pscontour)                       % Contourlines
    command = pscontour(se.plot.pscontour);
    exec_gmt_cmd(command)
end

if isfield(se,'psxy')                                                           % Psbox
    command = se.psxy;
    exec_gmt_cmd(command)
elseif isfield(se.plot,'psbox')
    psbox(se);
end

if isfield(se.plot,'pspoly')
    pspoly(se);
end

if isfield(se.plot,'legend') && ~isempty(se.plot.legend)                        % Legends
    command = psscale(se.plot.legend);
    exec_gmt_cmd(command)
end
if isfield(se.plot,'nanlegend') && ~isempty(se.plot.nanlegend)
    disp('processing psscale for NaN')
    command = psscale(se.plot.nanlegend);
    exec_gmt_cmd(command)
end
% an empty ps file
command = sprintf('echo -e " " | psxy -R%s -J%s -O >> %s.ps', ...
                  se.plot.region,se.plot.proj,se.filename);
exec_gmt_cmd(command)

% close the ps file with

function se = setup_create_gmt_earth(se)                                        %% setup_create_gmt_earth %%

se = defaults(se);

if ~isfield(se,'region')                                                        % REGION
    se.plot.region = sprintf('%d/%d/%d/%d',...
        min(min(se.lon)),max(max(se.lon)),...
        min(min(se.lat)),max(max(se.lat)));
else se.plot.region = se.region;
end

if ~isfield(se,'proj')                                                          % PROJECTION
    se.plot.proj = setup_projection(se);
else se.plot.proj = se.proj;
end

if ~se.grid && ~isfield(se,'nearneighbor') && ~isfield(se,'nodata')                                      % GRIDDING
    se.plot.grid = mkgrid(se);
end

if ~isfield(se,'nodata')
    se.plot.color = create_colortables(se);                                         % COLOR TABLE
end

if ~isfield(se,'plotimage') && ~isfield(se,'nodata')                                                    % PLOT IMAGE
    se.plot.plotimage = mkpltimage(se);
end

if ~isfield(se,'coast')                                                         % COAST
    se.plot.coast = mkcoast(se);
end

if isfield(se,'psbox')                                                          % PSBOX
    se.plot.psbox = setup_psboxpoly(se, 'psbox');
end

if isfield(se,'pspoly')                                                          % PSBOX
    se.plot.pspoly = setup_psboxpoly(se, 'pspoly');
end

if isfield(se,'pscontour')                                                      % Contour lines
    se.plot.pscontour = mkpscontour(se);
end

[se.plot.legend,se.plot.nanlegend] = mklegend(se);                              % Legend/s

function se = defaults(se)                                                      %% defaults %%

if ~isfield(se,'legend_orient') || ~isempty(se.legend_orient)
    se.legend=true;
    if ~isfield(se,'sidebar')
        se.sidebar = true;
    end
else
    se.legend=false;
end

function region = region(se)                                                    %% region %%

if isfield(se,'regionchoice')
    se = se.regionchoice;
elseif sum(ismember(isfield(se,{'regionchoice','regionstr'}),1))==0
    se.blcorner = [min(min(se.lat)),min(min(se.lon))];
    se.trcorner = [max(max(se.lat)),max(max(se.lon))];
end

if ~isfield(se,'blcorner')
    se.blcorner = [-90,0];
end
if ~isfield(se,'trcorner')
    se.trcorner = [90,360];
end
lonmin = num2str(floor(se.blcorner(2))); latmin = num2str(floor(se.blcorner(1)));
lonmax = num2str(ceil(se.trcorner(2))); latmax = num2str(ceil(se.trcorner(1)));
region = sprintf('%s/%s/%s/%s',lonmin,lonmax,latmin,latmax);

function proj = setup_projection(se)                                            %% setup_projection %%

projection = 'Q'; %Cylindrical Equidistant Projection

x = textscan(se.plot.region','%f','delimiter','/');                             % region

if ~isfield(se,'center')
    center = (x{1}(1)+x{1}(2))/2;
else center = se.center;
end

if ~isfield(se,'map_width')                                                     % map width
    map_width = 9; %inches
else map_width = se.map_width;
end

if center < x{1}(1) || center > x{1}(2)
    disp ('You have picked a projection center outside of the plot region')
    disp('Chooseing the middle of the region instead')
    center = (x{1}(1)+x{1}(2))/2;
end

proj = sprintf('%s%d/%di',projection,center,map_width);

function a = mkgrid(se)                                                         %% mkgrid %%
%%
% a.search is determined only by the spaceing between lonitudes
%
%
a.region = se.plot.region;
a.ungriddedfile = se.ungriddedfile;
a.file = se.filename;
a.name = 'nearneighbor';

if ~isfield(se,'increment')
    a.increment = '60m'; %i.e. One degree
elseif isnumeric(se.increment)
    a.increment = sprintf('%dm',se.increment);
else
    a.increment = se.increment;
end

if ~isfield(se,'search ')
    a.search = '30m'; %i.e. ½ degree
elseif isnumeric(se.search)
    a.search = sprintf('%dm',se.search);
else
    a.search = se.search;
end

function a = create_colortables(se)                                             %% create color tables %%

if ~isfield(se,'cptfile')
    if ~isfield(se,'ctable')
        fprintf('picking the "myrainbow" colortable...\n');
        se.ctable = 'myrainbow';
    end
    
    switch lower(se.ctable)                                                     % generate cpt files
        case 'myrainbow'
            se = setup_cpt(se);
            [tickval,prtstr]=ownctable(se);
            a.cptfile = makerainbow(tickval,prtstr,se.ptype);
        case 'cold2hot'
            se = setup_cpt(se);
            [tickval,prtstr]=ownctable(se);
            a.cptfile = makehot(tickval,prtstr,'cold2hot');
        case 'hot2cold'
            se = setup_cpt(se);
            [tickval,prtstr]=ownctable(se);
            a.cptfile = makehot(tickval,prtstr,'hot2cold');
        case 'mypolar'
            if ~isfield(se.datarange,'min')
                se.datarange.min=-1*se.datarange.max;
            end
            if ~isfield(se.datarange,'max')
                se.datarange.max=abs(se.datarange.min);
            end
            se = setup_cpt(se);
            [tickval,prtstr]=ownctable(se);
            a.cptfile = makepolar(tickval,prtstr);
        otherwise
            disp('processing makecpt')
            se = setup_cpt(se);
            a.cptfile = makecpt(se);
    end
else
    if isfield(se,'datarange')
        fprintf('Chosen data range ignored as a preexisting cptfile will be used\n')
    end
    if isfield(se,'ctable')
        fprintf('Chosen color table ignored as a preexisting cptfile will be used\n')
    end
    a.cptfile = se.cptfile;
end

a.cptnan = 'color_nan.cpt';                                                     % extra legend box for missing values
z = dir (a.cptnan);
if isempty(z)
    xtra_nan_legend();
end

function a = mkpltimage(se)                                                     %% mkpltimage %%

a.name = 'grdimage';
a.region = se.plot.region;
a.proj = se.plot.proj;
a.cptfile = se.plot.color.cptfile;
a.file = se.filename;
a.title = se.title;

function a = mkcoast(se)                                                        %% mkcoast %%

a.name = 'pscoast';
a.region = se.plot.region;
a.proj = se.plot.proj;
a.file = se.filename;
rg = textscan(a.region','%f','delimiter','/');
ln=rg{1}(2)-rg{1}(1);
lt=rg{1}(4)-rg{1}(3);
if ~isfield(se,'features')
    const = 65;%constant => features ~1000km for full map
    a.features = ln*lt/const;
else a.features = se.features;
end
if ~isfield(se,'resolution')
    if ln < 20
        a.resolution = 'h';
    elseif ln < 45
        a.resolution = 'i';
    elseif ln < 90
        a.resolution = 'l';
    else a.resolution = 'c';
    end
else a.resolution = se.resolution;
end
if ~isfield(se,'rivers')
    a.rivers = '1';
else a.rivers = se.rivers;
end
if ~isfield(se,'cwidth')
    a.width = 0.3;
else a.width = se.cwidth;
end
if ~isfield(se,'ticks')
    x1=ln/9; x2=x1/(1+(round(ln/lt)>=2));
    x3=lt/9; x4=x3/(1+(round(lt/ln)>=2));
    fac=10^(floor(log10(x1)));
    a.ticks = sprintf('%3.1fg%3.1f/%3.1fg%3.1f',...
        round(x1/fac)*fac,round(x2/fac)*fac,round(x3/fac)*fac,round(x4/fac)*fac);
else a.ticks = se.ticks;
end

function a = mkpscontour(se)                                                    %% mkpscontour %%

a.file = se.filename;
a.region = se.plot.region;
a.proj = se.plot.proj;
a.cptfile = se.plot.color.cptfile;
if ~isfield(se,'ctwidth')
    a.width = 0.5;
else a.width = se.ctwidth;
end

function [a,b] = mklegend(se)                                                   %% mklegend %%

% automatically orient legend if a vertical legend no longer makes sense
if se.legend
    if ~isfield(se,'unit')
        a.unit = '-?-';
    else a.unit = char(se.unit);
    end
    x = textscan(se.plot.region','%f','delimiter','/');
    if ~isfield(se,'sizelegend') && ~isfield(se,'legend_orient')
        if ( x{1}(2)-x{1}(1) ) / ( x{1}(4)-x{1}(3) ) > 3
            se.legend_orient='h';
        else se.legend_orient='v';
        end
    end
    if strcmp(se.legend_orient,'v')
        %i = inch , c = cm (9.7i/2.3i/4i/0.3i = orig)
        a.legendsize = '25c/5.9c/10c/0.5c';
    end
    if strcmp(se.legend_orient,'h')
        a.legendsize = '12c/0/18c/0.5ch -Ya-1'; %xpos/ypos/length/width
    end
    if ~isfield(se,'nanlegend') || ~isempty(se.nanlegend)
        b.sidebar=false;
        b.unit = '';
        b.cptfile = se.plot.color.cptnan;
        b.equalboxsize = '';
        b.file = se.filename;
        if strcmp(se.legend_orient,'v')
            b.legendsize = '25c/-1.3c/0.5c/0.5c';
        end
        if strcmp(se.legend_orient,'h')
            %i = inch , c = cm  (9.7i/-0.5i/0.3i/0.3i = orig)
            b.legendsize = '1c/0/0.5c/0.5ch';
        end
    else b = '';
    end
    if ~exist('a','var'), a='';return, end
    a.cptfile = se.plot.color.cptfile;
    a.sidebar=se.sidebar;
    a.equalboxsize = '';
    a.file = se.filename;
else a = ''; b = '';
end

function [tickval,prtstr] = ownctable(se)                                       %% ownctable %%

switch lower(se.ptype)
    case 'equal'
        [tickval,prtstr] = ...
            equidistant_contours(se.datarange.min,se.datarange.max,se.plot.nlevels);
    otherwise
        error 'Currently the only available ptype is "equidistant"'
end

function se = setup_cpt(se)                                                     %% Setup color table %%

if ~isfield(se,'datarange')
    fprintf(strcat('No maximum or min values directly .',...
        ' Using default colortable (polar)...\n'));
    fprintf('setting the datarange  to -200:200 as no range is given...')
    se.datarange.min = -200;
    se.datarange.max = 200;
    se.ctable = 'mypolar';
elseif isfield(se.datarange,'max') && ~isfield(se.datarange,'min')
    se.datarange.min = 0;
    fprintf('setting se.datafield.min = %3.1f\n',se.datarange.min)
end
if se.datarange.max == se.datarange.min
    se.plot.nlevels=1;
elseif ~isfield(se,'nlevels')
    se.plot.nlevels=15;
else se.plot.nlevels = se.nlevels;
end

if ~isfield(se,'ptype')
    se.ptype = 'equal'; %contour spacing
end

function out = setup_psboxpoly(se, field)                                                  %% ps box %%

l = size(se.(field),1);
if isfield(se,[field 'color'])
    if length(se.([field 'color']))~=l
        error('Need same number of colors as boxes')
    end
else se.([field 'color'])(1:l) = {'k'}; %default is black
end

if isfield(se,([field 'thick']))
    if length(se.([field 'thick']))~=l
        error('Need same number of sizes as boxes')
    end
else out.thick(1:l)={10}; %default size=10
end
c = list_colors('colors',se.([field 'color']));
for i=1:length(c)
    colors{i}=c{i}.*255; % instead of from 0:1
end
out.colors=colors;
out.(field)=se.(field);