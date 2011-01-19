function commands = create_gmt_earth(in)
%%           create_gmt_earth
%
% See gmt_plot for input details
%
% PURPOSE: Create cell strings that will be used in a system call.
%
% $Author$
% $Date$

in = setup_create_gmt_earth(in);                                           

F = in.filename;

% Remove earlier .ps and gmt residules
commands{1} = sprintf('rm -f %s.{ps,eps}',F);                                
commands{end+1} = sprintf('rm -f .gmt{commands4,defaults4} ');

% Set paper size
commands{end+1} = 'gmtset PAPER_MEDIA a0';                                      

% Size of title
if isfield(in,'header_size')                                                    
    commands{end+1} = sprintf('gmtset HEADER_FONT_SIZE %dp',in.header_size);
end

% Annotations of axis
if isfield(in,'basemap_axis')                                                   
    commands{end+1} = sprintf('gmtset BASEMAP_AXES %s',in.basemap_axis);
end

% Verticle distance from plot to title
if isfield(in,'header_offset')                                                  
    commands{end+1} = sprintf('gmtset HEADER_OFFSET %c',in.header_offset);
end

% other gmtset-commands you might have
if isfield(in,'gmtset')
    for i = length(in.gmtset)
        commands{end+1} = in.gmtset{i}; %#ok<*AGROW>
    end
end

% PSBASEMAP (open PS-file)
commands{end+1} = in.plot.basemap;

% NEARNEIGHBOR
if isfield(in,'nearneighbor')                                                   
    commands{end+1} = in.nearneighbor;
elseif ~in.gridded && isfield(in.plot,'grid')
    commands{end+1} = nearneighbor(F,in.plot.grid);
end

% IMAGE
if isfield(in,'grdimage')                                                  
    if ~isempty(in.grdimage)
        commands{end+1} = in.grdimage;
    end
elseif ~in.nodata && strcmp(in.plot.plotimage.name,'grdimage')
    commands{end+1} = grdimage(F,in.plot.plotimage);
end

% COASTLINES
if isfield(in,'pscoast')                                                        
    commands{end+1} = in.pscoast;
else
    commands{end+1} = pscoast(F,in.plot.coast);
end

% LOCATION MARKERS
if isfield(in,'locations')                                                      
    commands = pslocations(F,in,commands);
end

% CONTOURLINES
if isfield(in.plot,'grdcontour') && ~isempty(in.grdcontour)                       
    for i = 1:length(in.plot.grdcontour)
        commands{end+1} = grdcontour(F,in.plot.grdcontour(i));
    end
end

% PSBOX (draw boxes or shapes on map)
if isfield(in,'psxy')                                                           
    commands{end+1} = in.psxy;
elseif isfield(in,'psbox') || isfield(in.plot,'psbox')
    commands = psbox(F,in,commands);
elseif isfield(in.plot,'pspoly')
    commands = pspoly(F,in,commands);
end

% LEGEND
if isfield(in,'psscale')                                                        
    commands{end+1} = in.psscale;
elseif ~isempty(in.plot.legend)
    commands{end+1} = psscale(F,in.plot.legend);
end

% NaN legend
if isfield(in,'psscale_nan')                                                    
    commands{end+1} = in.psscale_nan;
elseif ~isempty(in.plot.nanlegend)
    commands{end+1} = in.plot.nanlegend;
end

% CLOSE PS + GRID
commands{end+1} = in.plot.lastbasemap;

%%%%%%%%%%%%%%%%%
%  SUBFUNCTIONS
%      |||||
%      vvvvv
function in = setup_create_gmt_earth(in)                                        
%% setup_create_gmt_earth %%

if ~isfield(in,'region')                                                        % REGION
    if in.gridded && in.lon(end)+in.lon(end)-in.lon(end-1) == in.lon(1)+360
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

in.plot.basemap = setupbasemap(in);

if ~in.gridded && ~isfield(in,'nearneighbor') && ~in.nodata                        % GRIDDING
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

if isfield(in,'grdcontour')                                                      % Contour lines
    in.plot.grdcontour = mkgrdcontour(in);
end

[in.plot.legend,in.plot.nanlegend] = mklegend(in);                          % Legend/s

in.plot.lastbasemap = last_psbasemap(in);                                       % Close file with this

function proj = setup_projection(in)                                            %% setup_projection %%
%% setup_projection %%

if isempty(in.center) || ~strcmp(in.plot.region(1:9),'-180/180/')
    disp('Data is not cyclic, choosing in.centre for projection from center longitude...')
    x = textscan(in.plot.region','%f','delimiter','/');                         % region
    C = (x{1}(1)+x{1}(2))/2;
else C = in.center;
end

proj = sprintf('%s%d/%di',in.projection,C,in.map_width);

function basemap = setupbasemap(in)

if ~isempty(in.title)
    basemap = sprintf('psbasemap -B:."%s": -R%s -J%s -Ya5 -G -P -K > %s.ps',...
        gmt_unicode_converter(in.title),in.plot.region,in.plot.proj,in.filename);
else
    basemap = sprintf('psbasemap -R%s -J%s -Ya5 -G -P -K > %s.ps',...
        in.plot.region,in.plot.proj,in.filename);
end

function a = mkgrid(in)                                                         %% mkgrid %%
%% mkgrid %%
% If nothing is given the increment and search radius is loosely based on the
% density of the data points

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
prtstr = '%.12f';

% MAKE a custom colour table based on manually input color values
if isfield(in,'ctable_colors')
    in.ctable = 'hardcoded';
elseif isfield(in,'colorrange')
    in.ctable = 'colorrange';
end

% OR use some of the other definded color tables
if any(strcmp(in.ctable,{'hardcoded','mypolar'}))
    tickval=ownctable(in);
elseif isfield(in,'ctable_clevels')
    tickval = in.ctable_clevels;
end

% generate cpt files
switch in.ctable    
    case 'hardcoded'
        a.cptfile = hardcoded_colors(tickval,prtstr,in);
    case 'mypolar'
        a.cptfile = makepolar(tickval,prtstr,in);        
    case 'colorrange'
        cpt_from_colorrange(in.colorrange);
        a.cptfile = makecpt(in);
    otherwise
        disp('processing makecpt')
        if ~isfield(in,'makecpt')
            a.cptfile = makecpt(in);
        else
            exec_gmt_cmd(in.makecpt);
            tmp = regexp(in.makecpt,'> ','split');
            a.cptfile = tmp{2};
        end
end

if isfield(in,'tick_annotations')
    append_tickannotations(a.cptfile,in.tick_annotations);
end
% extra legend box for missing values
if in.nanlegend
    a.cptnan = xtra_nan_legend(in);
end

function a = mkpltimage(in)                                                     %% mkpltimage %%
%% mkpltimage %%

% setup grdimage
a.name = 'grdimage';
a.cptfile = in.plot.color.cptfile;

function a = mkcoast(in)                                                        %% mkcoast %%
%% mkcoast
%
% Does some default behaviour for plotting coastlines based on the size of the
% region. Can be overridden by arguments: in.resolution and in.rivers

% set
a.name = 'pscoast';

% Set resolution of coastal features
rg = textscan(in.plot.region','%f','delimiter','/');
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

function a = mkgrdcontour(in)                                                    %% mkpscontour %%
%% mkgrdcontour

default.cptfile = in.plot.color.cptfile;
default.grdfile = in.grdfile;

for i = 1:length(in.grdcontour)
    a(i) = catstruct(default,in.grdcontour(i));
end


function [a,b] = mklegend(in)                                                   %% mklegend %%
%% mklegend
%
% What I need:
% unit, nticks, legend_orient, legendsize, sidebar, cptfile

if isfield(in,'fieldname') && (in.legend || in.savelegend) %if not field then nodata
    % get what is already in the in-structure
    F = {'xunit','unit','nticks','legend_orient','legendsize','sidebar','cptfile'};
    for f = F(ismember(F,fieldnames(in)))
        if any(strcmp(f{1},{'unit','xunit'}))
            a.(f{1}) = gmt_unicode_converter(in.(f{1}));
        else
            a.(f{1}) = in.(f{1});
        end
    end
    
    % used to determine defaults
    x = textscan(in.plot.region','%f','delimiter','/');
    test  = ( x{1}(2)-x{1}(1) ) / ( x{1}(4)-x{1}(3) ) > 3;
    orient = ['v','h'];
    default.legend_orient = orient(test+1);
    
    % get part of in...
    if ~exist('a','var'), a = struct([]); end
    a = optargs_struct(a,default);
    
    %sz = {'25c/5.9c/10c/0.5c','12c/-1c/18c/0.5ch'};
    szdef = {[9.8 2.3 3.9 .2],[4.7 -0.4 7.1 .2]}; %inches matching map_width = 9i
    
    tmp = sprintf('%.2fi/',szdef{1}*in.map_width/9); sz{1} = tmp(1:end-1);
    tmp = sprintf('%.2fi/',szdef{2}*in.map_width/9); sz{2} = [tmp(1:end-1) 'h'];

    
    default.legendsize = sz{ strcmp(a.legend_orient,'h') +1 };
    a = optargs_struct(a,default);
    
    % A little extra legend showig colors of NaNs
    if in.nanlegend
        nandef = {[9.84 -.2 .2 .2],[.4 -.4 .2 2]};
        tmp = sprintf('%.2fi/',nandef{1}*in.map_width/9); nsz{1} = tmp(1:end-1);
        tmp = sprintf('%.2fi/',nandef{2}*in.map_width/9); nsz{2} = [tmp(1:end-1) 'h'];
        lsize = nsz{ strcmp(a.legend_orient,'h') +1 };
        b = sprintf('psscale -Bs/:NaN: -Ccolor_nan.cpt -D%s -O -K >> %s.ps',lsize,in.filename);
    end
    
    % get xtra options
    xtra ={'tickspacing','tick_annotations','shift_tick_annotations','tick_annotation_format',...
        'annot_font_size_primary','tick_length','legendbox_spacing','tickcentering','equalboxwidth'};
    
    for F = xtra
        if isfield(in,F{1})
            a.(F{1}) = in.(F{1});
        end
    end
    
    % fixed vaules
    a.cptfile = in.plot.color.cptfile;
    a.sidebar = in.sidebar;
    a.tickspacing = in.tickspacing;
    
end
if ~exist('b','var'), b = struct([]);end
if ~exist('a','var'), a = struct([]);end


function tickval = ownctable(in)                                       %% ownctable %%
%% ownctable %%

minn = in.datarange(1);maxx = in.datarange(2);
if minn==maxx
    maxx=maxx+1;
end
tickval = minn:in.stepsize:maxx;

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

function basemap = last_psbasemap(in)
%% last_psbasemap

% default.ticks = '60g60/30g30' (global)
% in.plot.region has this format: 'lon1/lon2/lat1/lat2'
x = cellfun(@(x)(str2double(x)),regexp(in.plot.region,'/','split'));
lon=x(2)-x(1);
lat=x(4)-x(3);

% for nice step lengths

% lons
as   = [240 180 120 90 60 30 15];
step = [60 40 30 20 15 10 5];
a = step(~(as>lon));
if isempty(a), a = lon/6; end

%lats
bs   = [120 60 90 40 30 20 15];
step = [60 40 30 20 10 5 2.5];
b = step(~(bs>lat));
if isempty(b), b = lat/3; end

default.ticks = sprintf('%.2fg%.2f/%.2fg%.2f',a(1),b(1),a(1)/2,b(1)/2);
in = optargs_struct(in,default);

basemap = sprintf('psbasemap -B%s -R -J -O >> %s.ps',in.ticks,in.filename);
