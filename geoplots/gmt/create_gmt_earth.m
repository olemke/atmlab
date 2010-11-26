function commands = create_gmt_earth(in)
%%           create_gmt_earth
%
% See gmt_plot for input details
%
% PURPOSE: Create cell strings that will be used in a system call.
%
% $Author$
% $Date$

in = setup_create_gmt_earth(in);                                                % Most options are assigned here

file = in.filename;

commands{1} = sprintf('rm -f %s.{ps,eps}',file);                                % Remove earlier .ps files
commands{end+1} = sprintf('rm -f .gmt{commands4,defaults4} ');
commands{end+1} = 'gmtset PAPER_MEDIA a0';                                      % Set paper sizeBASEMAP_AXES

if isfield(in,'headersize')                                                     % Size of title
    commands{end+1} = sprintf('gmtset HEADER_FONT_SIZE %dp',in.headersize);
end
if isfield(in,'basemap_axis')                                                   % Annotations of axis
    commands{end+1} = sprintf('gmtset BASEMAP_AXES %s',in.basemap_axis);
end
if isfield(in,'header_offset')                                                  % Distance from axis to Annotation
    commands{end+1} = sprintf('gmtset HEADER_OFFSET %c',in.header_offset);
end
if isfield(in,'gmtset')
    for i = length(in.gmtset)
        commands{end+1} = in.gmtset{i};
    end
%commands{end+1} = 'gmtset D_FORMAT %3.1e';
end

% APPEND START with empty ps command (P = portrait, K = keep open)
commands{end+1} = sprintf('psxy --HISTORY=FALSE -Rg -JQ1 -T -P -K >> %s.ps',file);

if isfield(in,'nearneighbor')                                                   % Nearneighbor
    commands{end+1} = in.nearneighbor;
elseif ~in.grid && isfield(in.plot,'grid')
    commands{end+1} = nearneighbor(file,in.plot.grid);
end

if isfield(in,'grdimage')                                                       % Image
    commands{end+1} = in.grdimage;
elseif ~in.nodata && strcmp(in.plot.plotimage.name,'grdimage')
    commands{end+1} = grdimage(file,in.plot.plotimage);
end

if isfield(in,'pscoast')                                                        % Coastlines
    commands{end+1} = in.pscoast;
else
    commands{end+1} = pscoast(file,in.plot.coast);
end

if isfield(in,'locations')                                                      % Location markers
    commands = pslocations(file,in,commands); %internally adds several commands
end

if isfield(in.plot,'pscontour') && ~isempty(in.pscontour)                       % Contourlines
    % currently out of order.....
    commands{end+1} = pscontour(file,in.plot.pscontour);
end

if isfield(in,'psxy')                                                           % Psbox
    commands{end+1} = in.psxy;
end
if isfield(in,'psbox') || isfield(in.plot,'psbox')
    commands = psbox(file,in,commands); %internally adds several commands
end

if isfield(in.plot,'pspoly')
    commands = pspoly(file,in,commands); %internally adds several commands
end

if isfield(in,'psscale')                                                        
    commands{end+1} = in.psscale;
elseif ~isempty(in.plot.legend)                                                 % Legend
    commands{end+1} = psscale(file,in.plot.legend);
end

if isfield(in,'psscale_nan')                                                    
    commands{end+1} = in.psscale_nan;
elseif ~isempty(in.plot.nanlegend)
    commands{end+1} = in.plot.nanlegend;                                        % NaN Legend
end

% APPEND EOF with empty ps command (O = overlay (don't write header))
commands{end+1} = sprintf('psxy --HISTORY=FALSE -Rg -JQ1 -T -O >> %s.ps',file);

%%%%%%%%%%%%%%%%%
%  SUBFUNCTIONS
%      |||||
%      vvvvv
function in = setup_create_gmt_earth(in)                                        
%% setup_create_gmt_earth %%

if ~isfield(in,'region')                                                        % REGION
    if in.grid && in.lon(end)+in.lon(end)-in.lon(end-1) == in.lon(1)+360
        in.plot.region = sprintf('-180/180/%d/%d',in.lat(1),in.lat(end));
    else
        in.plot.region = sprintf('%d/%d/%d/%d',...
            min(min(in.lon)),max(max(in.lon)),...
            min(min(in.lat)),max(max(in.lat)));
    end
else in.plot.region = in.region;
end

if ~isfield(in,'proj')                                                          % PROJECTION
    in.plot.proj = setup_projection(in);
else in.plot.proj = in.proj;
end

if ~in.grid && ~isfield(in,'nearneighbor') && ~in.nodata                        % GRIDDING
    in.plot.grid = mkgrid(in);
end

if ~in.nodata
    in.plot.color = create_colortables(in);                                     % COLOR TABLE
end

if ~isfield(in,'plotimage') && ~in.nodata                                       % PLOT IMAGE
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

if ~in.nodata
    [in.plot.legend,in.plot.nanlegend] = mklegend(in);                          % Legend/s
end

function proj = setup_projection(in)                                            %% setup_projection %%
%% setup_projection %%

if isempty(in.center) || ~strcmp(in.plot.region(1:9),'-180/180/')
    disp('Data is not cyclic, choosing in.centre for projection from center longitude...')
    x = textscan(in.plot.region','%f','delimiter','/');                         % region
    C = (x{1}(1)+x{1}(2))/2;
else C = in.center;
end

proj = sprintf('%s%d/%di',in.projection,C,in.map_width);

function a = mkgrid(in)                                                         %% mkgrid %%
%% mkgrid %%
% If nothing is given the increment and search radius is loosely based on the
% density of the data points

a.region = in.plot.region;
a.ungriddedfile = in.ungriddedfile;
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
%% create color tables %%
%
% What I need from here:
% cptfile, cptnan, nlevels



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

% generate cpt files
switch in.ctable                                                            
    case 'myrainbow'
        [tickval,prtstr]=ownctable(in);
        a.cptfile = makerainbow(tickval,prtstr,in.ptype);
    case 'mypolar'
        [tickval,prtstr]=ownctable(in);
        a.cptfile = makepolar(tickval,prtstr,in);        
    case 'cold2hot'
        [tickval,prtstr]=ownctable(in);
        a.cptfile = makehot(tickval,prtstr,'cold2hot');
    case 'hot2cold'
        [tickval,prtstr]=ownctable(in);
        a.cptfile = makehot(tickval,prtstr,'hot2cold');
    otherwise
        disp('processing makecpt')
        a.cptfile = makecpt(in);
end

% extra legend box for missing values
if isempty(dir('color_nan.cpt')), xtra_nan_legend; end %if it's not there, make it
a.cptnan = 'color_nan.cpt';
a.nlevels = in.nlevels;

function a = mkpltimage(in)                                                     %% mkpltimage %%
%% mkpltimage %%

% setup grdimage
a.name = 'grdimage';
a.region = in.plot.region;
a.proj = in.plot.proj;
a.cptfile = in.plot.color.cptfile;
a.title = in.title;

function a = mkcoast(in)                                                        %% mkcoast %%
%% mkcoast
%
% Does some default behaviour for plotting coastlines based on the size of the
% region. Can be overridden by arguments: in.resolution and in.rivers

% set
a.name = 'pscoast';
a.region = in.plot.region;
a.proj = in.plot.proj;

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
%% mkpscontour

a.region = in.plot.region;
a.proj = in.plot.proj;
a.cptfile = in.plot.color.cptfile;
if ~isfield(in,'ctwidth')
    a.width = 0.5;
else a.width = in.ctwidth;
end

function [a,b] = mklegend(in)                                                   %% mklegend %%
%% mklegend
%
% What I need:
% unit, nticks, legend_orient, legendsize, sidebar, cptfile

if in.legend
    % get what is already in the in-structure
    F = {'unit','nticks','legend_orient','legendsize','sidebar','cptfile'};
    for f = F(ismember(F,fieldnames(in)))
        a.(f{1}) = in.(f{1});
    end
    
    % used to determine defaults
    x = textscan(in.plot.region','%f','delimiter','/');
    test  = ( x{1}(2)-x{1}(1) ) / ( x{1}(4)-x{1}(3) ) > 3;
    orient = ['v','h'];
    default.legend_orient = orient(test+1);
    
    % get part of in...
    if ~exist('a','var'), a = struct([]); end
    a = optargs_struct(a,default);
    
    sz = {'25c/5.9c/10c/0.5c','12c/0/18c/0.5ch -Ya-1'};
    default.legendsize = sz{ strcmp(a.legend_orient,'h') +1 };
    a = optargs_struct(a,default);
    
    % A little extra legend showig colors of NaNs
    if in.nanlegend
        if strcmp(a.legend_orient,'v')
            lsize = '25c/-1.3c/0.5c/0.5c';
        elseif strcmp(a.legend_orient,'h')
            lsize = '1c/0/0.5c/0.5ch';
        end
        b = sprintf('psscale -Bs/:NaN: -Ccolor_nan.cpt -D%s -O -K >> %s.ps',lsize,in.filename);
    end
    
    if isfield(in,'shift_tick_annotations')
        a.shift_tick = in.shift_tick_annotations;
    end
    if isfield(in,'tick_annotation_format')
        a.tick_format = in.tick_annotation_format;
    end
    
    % fixed vaules
    a.cptfile = in.plot.color.cptfile;
    a.sidebar = in.sidebar;
    a.tickspacing = in.tickspacing;
    
end
if ~exist('b','var'), b = struct([]);end

function [tickval,prtstr] = ownctable(in)                                       %% ownctable %%
%% ownctable %%

switch in.ptype
    case 'equal'
        [tickval,prtstr] = ...
            equidistant_contours(in.datarange,in.nlevels);
    otherwise
        error ('atmlab:input','Currently the only available ptype is "equidistant"')
end

function out = setup_psboxpoly(in, field)                                       %% ps box %%
%% ps box 

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