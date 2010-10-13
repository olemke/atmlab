function create_gmt_earth(in)
%           create_gmt_earth
%
% See gmt_plot for input details
%
% $Id$

in = setup_create_gmt_earth(in);                                                % Most options are assigned here

command = sprintf('rm -f %s.{ps,eps}',in.filename);                             % Remove earlier .ps files
exec_gmt_cmd(command)

command = 'gmtset PAPER_MEDIA a0';                                              % Set paper sizeBASEMAP_AXES
exec_gmt_cmd(command)

if isfield(in,'headersize')                                                     % Size of title
    command = sprintf('gmtset HEADER_FONT_SIZE %dp',in.headersize);
    exec_gmt_cmd(command)
end

if isfield(in,'basemap_axis')                                                   % Annotations of axis
    command = sprintf('gmtset BASEMAP_AXES %s',in.basemap_axis);
    exec_gmt_cmd(command)
end
if isfield(in,'header_offset')                                                  % Distance from axis to Annotation
    command = sprintf('gmtset HEADER_OFFSET %c',in.header_offset);
    exec_gmt_cmd(command)
end

if isfield(in,'nearneighbor')                                                   % Nearneighbor
    command = in.nearneighbor;
    exec_gmt_cmd(command)
elseif ~in.grid && isfield(in.plot,'grid')
    command = nearneighbor(in.plot.grid);
    exec_gmt_cmd(command)
end

if isfield(in,'grdimage')                                                       % Image
    command = in.grdimage;
    exec_gmt_cmd(command)
elseif ~isfield(in,'nodata') && strcmp(in.plot.plotimage.name,'grdimage')
    command = grdimage(in.plot.plotimage);
    exec_gmt_cmd(command)
end

if isfield(in,'pscoast')                                                        % Coastlines
    command = in.pscoast;
    exec_gmt_cmd(command)
else
    command = pscoast(in.plot.coast);
    exec_gmt_cmd(command)
end

if isfield(in,'locations')                                                      % Location markers
    command = pslocations(in);
    exec_gmt_cmd(command)
end

if isfield(in.plot,'pscontour') && ~isempty(in.pscontour)                       % Contourlines
    command = pscontour(in.plot.pscontour);
    exec_gmt_cmd(command)
end

if isfield(in,'psxy')                                                           % Psbox
    command = in.psxy;
    exec_gmt_cmd(command)
elseif isfield(in.plot,'psbox')
    psbox(in);
end

if isfield(in.plot,'pspoly')
    pspoly(in);
end

if isfield(in.plot,'legend') && ~isempty(in.plot.legend)                        % Legends
    command = psscale(in.plot.legend);
    exec_gmt_cmd(command)
end
if isfield(in.plot,'nanlegend') && ~isempty(in.plot.nanlegend)
    disp('processing psscale for NaN')
    command = psscale(in.plot.nanlegend);
    exec_gmt_cmd(command)
end
% an empty ps file
command = sprintf('echo -e " " | psxy -R%s -J%s -O >> %s.ps', ...
    in.plot.region,in.plot.proj,in.filename);
exec_gmt_cmd(command)

% close the ps file with

function in = setup_create_gmt_earth(in)                                        %% setup_create_gmt_earth %%

in = defaults(in);

if ~isfield(in,'region')                                                        % REGION
    in.plot.region = sprintf('%d/%d/%d/%d',...
        min(min(in.lon)),max(max(in.lon)),...
        min(min(in.lat)),max(max(in.lat)));
else in.plot.region = in.region;
end

if ~isfield(in,'proj')                                                          % PROJECTION
    in.plot.proj = setup_projection(in);
else in.plot.proj = in.proj;
end

if ~in.grid && ~isfield(in,'nearneighbor') && ~isfield(in,'nodata')                                      % GRIDDING
    in.plot.grid = mkgrid(in);
end

if ~isfield(in,'nodata')
    in.plot.color = create_colortables(in);                                         % COLOR TABLE
end

if ~isfield(in,'plotimage') && ~isfield(in,'nodata')                                                    % PLOT IMAGE
    in.plot.plotimage = mkpltimage(in);
end

if ~isfield(in,'coast')                                                         % COAST
    in.plot.coast = mkcoast(in);
end

if isfield(in,'psbox')                                                          % PSBOX
    in.plot.psbox = setup_psboxpoly(in, 'psbox');
end

if isfield(in,'pspoly')                                                         % PSBOX
    in.plot.pspoly = setup_psboxpoly(in, 'pspoly');
end

if isfield(in,'pscontour')                                                      % Contour lines
    in.plot.pscontour = mkpscontour(in);
end

if ~isfield(in,'nodata') || ~in.nodata
    [in.plot.legend,in.plot.nanlegend] = mklegend(in);                          % Legend/s
end

function in = defaults(in)                                                      %% defaults %%

if ~isfield(in,'legend_orient') || ~isempty(in.legend_orient)
    in.legend=true;
    if ~isfield(in,'sidebar')
        in.sidebar = true;
    end
else
    in.legend=false;
end

function region = region(in)                                                    %% region %%

if isfield(in,'regionchoice')
    in = in.regionchoice;
elseif sum(ismember(isfield(in,{'regionchoice','regionstr'}),1))==0
    in.blcorner = [min(min(in.lat)),min(min(in.lon))];
    in.trcorner = [max(max(in.lat)),max(max(in.lon))];
end

if ~isfield(in,'blcorner')
    in.blcorner = [-90,0];
end
if ~isfield(in,'trcorner')
    in.trcorner = [90,360];
end
lonmin = num2str(floor(in.blcorner(2))); latmin = num2str(floor(in.blcorner(1)));
lonmax = num2str(ceil(in.trcorner(2))); latmax = num2str(ceil(in.trcorner(1)));
region = sprintf('%s/%s/%s/%s',lonmin,lonmax,latmin,latmax);

function proj = setup_projection(in)                                            %% setup_projection %%

projection = 'Q'; %Cylindrical Equidistant Projection

x = textscan(in.plot.region','%f','delimiter','/');                             % region

if ~isfield(in,'center')
    center = (x{1}(1)+x{1}(2))/2;
else
    center = in.center;
    if center>180, center = center-360;end
    if center < x{1}(1) || center > x{1}(2)
        disp ('You have picked a projection center outside of the plot region')
        disp('Choosing the middle of the region instead')
        center = (x{1}(1)+x{1}(2))/2;
    end
end

if ~isfield(in,'map_width')                                                     % map width
    map_width = 9; %inches
else map_width = in.map_width;
end

proj = sprintf('%s%d/%di',projection,center,map_width);

function a = mkgrid(in)                                                         %% mkgrid %%
% If nothing is given the increment and search radius is loosely based on the
% density of the data points

a.region = in.plot.region;
a.ungriddedfile = in.ungriddedfile;
a.file = in.filename;
a.name = 'nearneighbor';

if ~isfield(in,'increment')
    
    % find the approx density of points
    x = length( unique( floor(in.lat)));
    y = length( unique( floor(in.lon)));
    A = x*y;
    delta = sqrt(numel(in.(in.fieldname)) / A);
    inc = ceil(60/delta *2); % times 2 is to make it a bit bigger
    if inc>60, inc=60; end
    a.increment = sprintf('%dm',inc); %i.e. One degree
elseif isnumeric(in.increment)
    a.increment = sprintf('%dm',in.increment);
else
    a.increment = in.increment;
end

if ~isfield(in,'search')
    sc = ceil( str2double(a.increment(1:end-1)));
    a.search = sprintf('%dm',sc);
elseif isnumeric(in.search)
    a.search = sprintf('%dm',in.search);
else
    a.search = in.search;
end

function a = create_colortables(in)                                             %% create color tables %%
% create color tables %
%
%
%

%% check if a color table file is given and use that one
if isfield(in,'cptfile')
    if isempty(dir(in.cptfile)), error('File: ''%s'' is missing!!',in.cptfile); end
    
    % If you input a cptfile, then these setting are naturally ignored
    if isfield(in,'datarange')
        fprintf('Chosen data range ignored as a preexisting cptfile will be used\n')
    end
    if isfield(in,'ctable')
        fprintf('Chosen color table ignored as a preexisting cptfile will be used\n')
    end
    a.cptfile = in.cptfile;
    return
end

%% Or else generate it

% pick default color table is none is given
if ~isfield(in,'ctable')
    in.ctable = 'myrainbow';
    fprintf('picking the ''%s'' colortable...\n',in.ctable);
end

% generate cpt files
switch in.ctable                                                            
    case 'myrainbow'
        in = setup_cpt(in);
        [tickval,prtstr]=ownctable(in);
        a.cptfile = makerainbow(tickval,prtstr,in.ptype);
    case 'mypolar'
        in = setup_cpt(in);
        [tickval,prtstr]=ownctable(in);
        a.cptfile = makepolar(tickval,prtstr,in);        
    case 'cold2hot'
        in = setup_cpt(in);
        [tickval,prtstr]=ownctable(in);
        a.cptfile = makehot(tickval,prtstr,'cold2hot');
    case 'hot2cold'
        in = setup_cpt(in);
        [tickval,prtstr]=ownctable(in);
        a.cptfile = makehot(tickval,prtstr,'hot2cold');
    otherwise
        disp('processing makecpt')
        in = setup_cpt(in);
        a.cptfile = makecpt(in);
end

% extra legend box for missing values
if isempty(dir('color_nan.cpt')), xtra_nan_legend; end %if it's not there, make it
a.cptnan = 'color_nan.cpt';

function a = mkpltimage(in)                                                     %% mkpltimage %%
% mkpltimage %%

% setup grdimage
a.name = 'grdimage';
a.region = in.plot.region;
a.proj = in.plot.proj;
a.cptfile = in.plot.color.cptfile;
a.file = in.filename;
a.title = in.title;

function a = mkcoast(in)                                                        %% mkcoast %%
%mkcoast
%
% Does some default behaviour for plotting coastlines based on the size of the
% region. Can be overridden by arguments: in.resolution and in.rivers


% set
a.name = 'pscoast';
a.region = in.plot.region;
a.proj = in.plot.proj;
a.file = in.filename;

% Set resolution of coastal features
rg = textscan(a.region','%f','delimiter','/');
ln=rg{1}(2)-rg{1}(1);
lt=rg{1}(4)-rg{1}(3);
if ~isfield(in,'features')
    const = 65;%constant => features ~1000km for full map
    a.features = ln*lt/const;
else a.features = in.features;
end
if ~isfield(in,'resolution')
    if ln < 20
        a.resolution = 'h';
    elseif ln < 45
        a.resolution = 'i';
    elseif ln < 90
        a.resolution = 'l';
    else a.resolution = 'c';
    end
else a.resolution = in.resolution;
end

% default = Large rivers
if ~isfield(in,'rivers')
    a.rivers = '1';
else a.rivers = sprintf('%i',in.rivers);
end

% Width of lines drawing coasts and rivers
if ~isfield(in,'cwidth')
    a.width = 0.3;
else a.width = in.cwidth;
end
if ~isfield(in,'ticks')
    x1=ln/9; x2=x1/(1+(round(ln/lt)>=2));
    x3=lt/9; x4=x3/(1+(round(lt/ln)>=2));
    fac=10^(floor(log10(x1)));
    a.ticks = sprintf('%3.1fg%3.1f/%3.1fg%3.1f',...
        round(x1/fac)*fac,round(x2/fac)*fac,round(x3/fac)*fac,round(x4/fac)*fac);
else a.ticks = in.ticks;
end

function a = mkpscontour(in)                                                    %% mkpscontour %%
% mkpscontour
% just a little setup
a.file = in.filename;
a.region = in.plot.region;
a.proj = in.plot.proj;
a.cptfile = in.plot.color.cptfile;
if ~isfield(in,'ctwidth')
    a.width = 0.5;
else a.width = in.ctwidth;
end

function [a,b] = mklegend(in)                                                   %% mklegend %%
% mklegend

if in.legend
    % append unit
    if ~isfield(in,'unit')
        a.unit = '-?-';
    else a.unit = char(in.unit);
    end
    
    x = textscan(in.plot.region','%f','delimiter','/');
    if ~isfield(in,'sizelegend') && ~isfield(in,'legend_orient')
        % automatically re-orient legend if a vertical legend no longer makes sense
        %(can be overridden by in.legend_orient='h','v')
        
        if ( x{1}(2)-x{1}(1) ) / ( x{1}(4)-x{1}(3) ) > 3
            in.legend_orient='h';
        else in.legend_orient='v';
        end
    end
    
     if strcmp(in.legend_orient,'v')
        %i = inch , c = cm (9.7i/2.3i/4i/0.3i = GMT's default)
        a.legendsize = '25c/5.9c/10c/0.5c';
    end
    if strcmp(in.legend_orient,'h')
        a.legendsize = '12c/0/18c/0.5ch -Ya-1'; %xpos/ypos/length/width
    end
    
    % A little extra legend showig colors of NaNs
    if ~isfield(in,'nanlegend') || ~isempty(in.nanlegend)
        b.sidebar=false;
        b.unit = '';
        b.cptfile = in.plot.color.cptnan;
        b.equalboxsize = '';
        b.file = in.filename;
        if strcmp(in.legend_orient,'v')
            b.legendsize = '25c/-1.3c/0.5c/0.5c';
        end
        if strcmp(in.legend_orient,'h')
            %i = inch , c = cm  (9.7i/-0.5i/0.3i/0.3i = orig)
            b.legendsize = '1c/0/0.5c/0.5ch';
        end
    else b = '';
    end  
    
    % finalize
    if ~exist('a','var'), a='';return, end
    a.cptfile = in.plot.color.cptfile;
    a.sidebar=in.sidebar;
    a.equalboxsize = '';
    a.file = in.filename;
else a = ''; b = '';
end

function [tickval,prtstr] = ownctable(in)                                       %% ownctable %%
% ownctable %%
switch in.ptype
    case 'equal'
        [tickval,prtstr] = ...
            equidistant_contours(in.datarange.min,in.datarange.max,in.plot.nlevels);
    otherwise
        error 'Currently the only available ptype is "equidistant"'
end

function in = setup_cpt(in)                                                     %% Setup color table %%
%% setup_cpt

% I need some sort datarange (min & max)
if ~isfield(in,'datarange')
    fprintf(strcat('No maximum or min values directly .',...
        ' Using default colortable (polar)...\n'));
    fprintf('setting the datarange  to -200:200 as no range is given...')
    in.datarange.min = -200;
    in.datarange.max = 200;
    in.ctable = 'mypolar';
elseif isfield(in.datarange,'max') && ~isfield(in.datarange,'min')
    in.datarange.min = 0;
    fprintf('setting in.datarange.min = %3.1f\n',in.datarange.min)
end

% Set the number of contour levels to use
if in.datarange.max == in.datarange.min %special is so that it works for no data
    in.plot.nlevels=1;
elseif ~isfield(in,'nlevels')
    in.plot.nlevels=15;
else in.plot.nlevels = in.nlevels;
end

% The contour spacing
if ~isfield(in,'ptype')
    in.ptype = 'equal'; %contour spacing (currently the only possibility)
end

function out = setup_psboxpoly(in, field)                                       %% ps box %%
% ps box %%

l = size(in.(field),1);
if isfield(in,[field 'color'])
    if length(in.([field 'color']))~=l
        error('Need same number of colors as boxes')
    end
else in.([field 'color'])(1:l) = {'k'}; %default is black
end

if isfield(in,([field 'thick']))
    if length(in.([field 'thick']))~=l
        error('Need same number of sizes as boxes')
    end
else out.thick(1:l)={10}; %default size=10
end
c = list_colors('colors',in.([field 'color']));
colors = cell(length(c),1);
for i=1:length(c)
    colors{i}=c{i}.*255; % instead of from 0:1
end
out.colors=colors;
out.(field)=in.(field);