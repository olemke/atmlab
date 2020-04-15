function commands = create_gmt_earth(in)
% CREATE_GMT_EARTH Main wrapper to gmt interface
%
% See help gmt_plot for input details
%
% PURPOSE: Create cell strings that will be used in a system call.
%
% Created by Salomon Eliasson
% $Id$

assert(exist('in','var')==1,'gmtlab:badInput',...
    'This is an internal function to be used by gmt_plot.m')

in = setup_create_gmt_earth(in);

i = 1; %counter

% If this directory isn't new (which it should be), you should remove the
% residuals using 'rm gmt.* ps2raster* Test1.ps *~ *.pdf'

commands{i} = sprintf('rm -f gmt.* %s.{ps,pdf}',in.filename);i=i+1;


% debug
%commands{i} = sprintf('gmt set GMT_COMPATIBILITY=4');i=i+1;


commands{i} = 'gmt set PS_MEDIA A0';  i=i+1;
commands{i} = sprintf('gmt set FONT_ANNOT_PRIMARY %s,%s',num2str(in.fontsize_annot_primary),num2str(in.font_annot_primary));i=i+1;
commands{i} = sprintf('gmt set FONT_ANNOT_SECONDARY %s,%s',num2str(in.fontsize_annot_secondary),num2str(in.font_annot_secondary));i=i+1;
commands{i} = sprintf('gmt set MAP_FRAME_AXES %s',in.psbasemap.axes);  i=i+1;
commands{i} = sprintf('gmt set MAP_TITLE_OFFSET=%s',num2str(in.map_title_offset));  i=i+1;
commands{i} = sprintf('gmt set FONT_TITLE %s,%s',num2str(in.fontsize_title),num2str(in.font_title)); i=i+1;
commands{i} = sprintf('gmt set PROJ_LENGTH_UNIT=%s',in.proj_length_unit); i=i+1;
commands{i} = sprintf('gmt set COLOR_FOREGROUND=%s',in.color_foreground);i=i+1;
commands{i} = sprintf('gmt set COLOR_BACKGROUND=%s',in.color_background);i=i+1;

% coastlines
if ~isempty(getenv('DIR_GSHHG'))
    commands{i} = sprintf('gmt set DIR_GSHHG=%s',getenv('DIR_GSHHG'));i=i+1;
end


% other gmtset-commands you might have
if isfield(in,'gmtset')
    for j = length(in.gmtset)
        commands{i} = in.gmtset{j}; i=i+1;
    end
end

% PSBASEMAP (open PS-file)
commands{i} = in.psbasemap.str{1}; i=i+1;

% NEARNEIGHBOR
if isfield(in,'nearneighbor') && ischar(in.nearneighbor)
    commands{i} = in.nearneighbor; i=i+1;
    in.grdfile = in.ungriddedfile;
elseif ~in.gridded && ~in.nodata
    commands{i} = nearneighbor(in); i=i+1;
    in.grdfile = in.ungriddedfile;
end

% IMAGE (plot data)
if isfield(in,'grdimage')
    commands{i} = in.grdimage; i=i+1;
elseif ~in.nodata
    commands{i} = grdimage(in); i=i+1;
end

% LEGEND
if isfield(in,'psscale')
    commands{i} = in.psscale; i=i+1;
elseif isstruct(in.legend)
    commands{i} = psscale(in.legend,in.filename); i=i+1;
end
if isfield(in,'psscale_extra')
    commands{i} = in.psscale_extra; i=i+1;
elseif ~in.nodata && (isfield(in,'extra_legend') && ischar(in.extra_legend))
    commands{i} = in.extra_legend; i=i+1;
end

% COASTLINES
if isstruct(in.pscoast)
    commands{i} = in.pscoast.str; i=i+1;
end

% LOCATION MARKERS
if isfield(in,'locations')
    tmp = pslocations(in);
    for j = 1:length(tmp)
        commands{i} = tmp{j}; i=i+1;
    end
    clear tmp
end

% CONTOURLINES
if isfield(in,'contourline')
    commands{i} = in.contourline.str; i=i+1;
end

% PSBOX & PSPOLY (draw boxes or shapes on map)
if isfield(in,'pspoly')
    tmp = pspoly(in);
    for j =1:length(tmp)
        commands{i} = tmp{j}; i=i+1;
    end
    clear tmp
end

% PSTEXT

if isfield(in,'pstext') && ischar(in.pstext)
    commands{i} = in.pstext; i=i+1;
elseif isfield(in,'pstext')
    count = 1;
    for PT =in.pstext
        % pull out one pstext command at a time
        [commands{i},tmp(count)] = pstext(catstruct(rmfield(in,'pstext'),struct('pstext',PT)),count);
        i=i+1;
        count = count+1;
    end
    % fill in the defaults that where used
    in.pstext = tmp;
    clear count tmp
end

% CLOSE PS + GRID
commands{i} = in.psbasemap.str{2};

end
%%%%%%%%%%%%%%%%%
%  SUBFUNCTIONS
%      |||||
%      vvvvv
function in = setup_create_gmt_earth(in)
%% setup_create_gmt_earth %%

in.psbasemap.str{1} = setupbasemap(in,0);

% GRIDDING
if ~in.gridded && ~in.nodata
    in = setup_nearneighbor(in);
end

% COLOR TABLE
if ~in.nodata
    in = create_colortables(in);
end

% COAST
if ~isfield(in,'pscoast') || ...
        ischar(in.pscoast) ||...
        isstruct(in.pscoast) || ...
        (isscalar(in.pscoast) && in.pscoast)
    if ~isfield(in,'pscoast') || (isfield(in,'pscoast') && ~ischar(in.pscoast))
        in = setup_pscoast(in);
        in.pscoast.str = pscoast(in);
    else
        tmp = in.pscoast;
        in = rmfield(in,'pscoast');
        in.pscoast.str = tmp;
        clear tmp
    end
end

% PSPOLY
if isfield(in,'pspoly')
    in.pspoly = setup_pspoly(in);
end

% CONTOUR LINES
if isfield(in,'contourline')
    in.contourline.str = grdcontour(in.filename,in);
end

% LEGEND/S
if isstruct(in.legend) && ~in.nodata
    [in.legend,extra_legend] = mklegend(in);
    if ~islogical(in.extra_legend)
        in.extra_legend = extra_legend;
    end
end


if ~isstruct(in.legend) && ...
        (isfield(in,'extra_legend') && isstruct(in.extra_legend)) && ...
        ~in.nodata
    [~,in.extra_legend] = mklegend(in);
end

% Close file with this
in.psbasemap.str{2} = setupbasemap(in,1);

end

function basemap = setupbasemap(in,last)
%% setupbasemap

basemap = 'gmt psbasemap';
%redirect '>' overwrites and existing file, '>>' appends to one
if ~last
    basemap = sprintf('%s -R%s',basemap,in.region);
    basemap = sprintf('%s -J%s',basemap,in.proj);
    basemap = sprintf('%s %s',basemap,in.plotPlacement);
else
    basemap = sprintf('%s -R -J -X -Y',basemap);
end

basemap = sprintf('%s -B%s',basemap,in.psbasemap.ticks);
if ~isempty(in.title)
    %basemap = sprintf('%s:."%s":',basemap,gmt_unicode_converter(in.title));
    basemap = sprintf('%s:."%s":',basemap,in.title);
end

%set portrait page
basemap = sprintf('%s -P',basemap);

% Allow more plot code to be appended after
if ~last
    basemap = sprintf('%s -K > %s.ps',basemap,in.filename);
else
    basemap = sprintf('%s -O >> %s.ps',basemap,in.filename);
end

end

function in = setup_nearneighbor(in)
%% mkgrid %%
% If nothing is given the resolution and search radius is loosely based on the
% density of the data points.

if isfield(in,'nearneighbor') && ~isstruct(in.nearneighbor)
    % Then it is the string command directly
    return
end

% ----------------------
% AREA

% get number of 1deg boxes in region
x            = sscanf(in.region,'%f/%f/%f/%f');
oneDegRegion = ( x(2)-x(1) )*( x(4)-x(3) );


% ---------------------
% Maximum resolution

% memGB = freeRAM()/1024; % How much RAM is available? TOO LARGE
% some reasonable maximum default
% apparently it costs 1200bytes per point

% hard code some sort of maxium

if ~isfield(in,'nearneighbor')
    in.nearneighbor = struct();
end

default.memGB = 2;
in.nearneighbor = optargs_struct(in.nearneighbor,default);
maxpoints = in.nearneighbor.memGB*1024^3  / 1200;
maxres = oneDegRegion/maxpoints;

% -----------------------------------------------------
% Resolution inferred by data, or by user defined
if isfield(in.nearneighbor,'resolution')
    %user
    res = in.nearneighbor.resolution;
else
    res = max([ abs(max(diff(sort(in.lat))));abs(max(diff(sort(in.lon))))]);
    % this is too much. multiply it
    res=res*3;
end

% check if res is acceptable
if res < maxres
    logtext(atmlab('OUT'), ['Automatically picked the maximum resolution of: ',...
        '%g [deg] instead of %g [deg] defined by measurement density\n'],maxres,res)
    res = maxres;
else
    logtext(atmlab('OUT'), 'Plot resolution: %g [deg]\n',res)
end
in.nearneighbor.increment = sprintf('%gm',60*res); % 60min x resolution

% use increment to decide the search radius, unless given
if ~isfield(in.nearneighbor,'search')
    in.nearneighbor.search = sprintf('%gm', 1.25*str2double(in.nearneighbor.increment(1:end-1)));
end

end

function in = create_colortables(in)
%% create color tables %%

% Pillage it if it is a string
if isfield(in,'ctable')
    if ischar(in.ctable)
        tmp = in.ctable;
        in = rmfield(in,'ctable');
        in.ctable.name = tmp;
        clear tmp
    end
end

% MAKE a custom colour table based on manually input color values
if isfield(in,'colorrange')
    if isfield(in,'ctable')
        warning(['atmlab:',mfilename,':badInput'],...
            'in.ctable is defined but so is in.colorrange which has precedence')
    end
    in.ctable.name = 'colorrange';
end

if isfield(in,'tickval')
    % make temporary tickval file
    fid=fopen('tickvalues.txt','w');
    if isfield(in,'tick_annotation_format')
        fprintf(fid,sprintf('%s ',in.tick_annotation_format),in.tickval);
    else
        fprintf(fid,sprintf('%s ',getAnnotFormat(in.tickval)),in.tickval);
    end
    fclose(fid);
end

% generate cpt files
%
% Using makecpt it is not possible to append tick_annotations here. This has to
% be done at a later step on an existing cpt-file
%
switch in.ctable.name
    case 'mypolar'
        if ~isfield(in,'tickval')
            tickval = ownctable(in);
        else
            tickval = in.tickval;
        end
        in.cptfile = makepolar(tickval,in);
    case 'colorrange'
        % make ctable to be input to makecpt -C%s
        if isfield(in.colorrange,'colors')
            cpt_from_colorrange(in.colorrange);
            in.cptfile = makecpt(in);
        end
        
    otherwise
        logtext(1,'Processing makecpt\n')
        if ~isfield(in,'makecpt')
            in.cptfile = makecpt(in);
        else
            exec_system_cmd(in.makecpt);
            tmp = splitstring(in.makecpt,'> ');
            in.cptfile = tmp{2};
        end
end

% extra legend box for missing values
if isfield(in,'extra_legend') && isstruct(in.extra_legend)
    in.extra_legend.cptfile = extra_legend(in);
end

end

function [a,b] = mklegend(in)
%% mklegend

a = in.legend;

if isstruct(a)
    
    % get what is in the in-structure, i.e one level up from in.legend
    % structure where they really belong
    F = {'cptfile','plotPlacement'};
    for f = F(ismember(F,fieldnames(in)))
        
        a.(f{1}) = in.(f{1});
    end
end
if isfield(in.legend,'tick_annotations')
    assert(in.nlevels == length(in.legend.tick_annotations),...
    ['gmtlab:' mfilename ':input'],'Number of annotations must match number of ticks')
    append_tickannotations(in.cptfile,in.legend.tick_annotations);
end

% Also needed
if isfield(in,'extra_legend') && isstruct(in.extra_legend)
    b = psscale(in.extra_legend,in.filename);
end

if ~exist('b','var'), b = struct([]);end
if ~exist('a','var'), a = struct([]);end

end

function tickval = ownctable(in)
%% ownctable %%

minn = in.datarange(1);maxx = in.datarange(2);
if minn==maxx
    maxx=maxx+1;
end
tickval = minn:in.stepsize:maxx;

end

function PP = setup_pspoly(in)
%% set defaults for pspoly

PP = in.pspoly;
el = length(PP.coord);

default.color = repmat({[0,0,0]},el,1);
default.thick = repmat({'10p'},el,1);

PP = optargs_struct(PP,default);


if isfield(PP,'color')
    assert(length(PP.color)==el,...
        ['atmlab:' mfilename,':badInput'],'Need same number of colors as pspoly regions')
end

if isfield(PP,'thick')
    assert(length(PP.thick)==el,...
        ['atmlab:' mfilename,':badInput'],'Need same number of ''in.pspoly.thick'' as pspoly regions')
    
end

end

function in = setup_pscoast(in)

if ~isfield(in,'pscoast'), in.pscoast = struct(); end

% width of the coast
default.width = '.3p';   

% features, resolution and rivers
if strcmp(in.region,'g')
    if in.lon360
        rg = [0 360 -90 90];
    else
        rg = [-180 180 -90 90];
    end
else
    rg=sscanf(in.region,'%f/%f/%f/%f');
end
ln1=rg(1); 
ln2=rg(2); 
lt1=rg(3);
lt2=rg(4);

% It may wrap around the world and give a shorter distance than
% I want so ...
dist1 = sphdist((lt2+lt1)/2,ln1,(lt2+lt1)/2,ln1+(ln2-ln1)/2,constants('EARTH_RADIUS'));
dist2 = sphdist((lt2+lt1)/2,ln1+(ln2-ln1)/2,(lt2+lt1)/2,ln2,constants('EARTH_RADIUS'));

%constant is a scaling factor applied to get a features size of 1000km^2
%for a global map. The number comes from a spherical Earth
const = 40074.7842077221;
default.features = (dist1+dist2)/const; %km^2

% resolution

if default.features < 50 
    default.resolution = 'h'; % high
    default.rivers = 'a';
elseif default.features < 150
    default.resolution = 'i'; % intermediate
    default.rivers = 0:1;
elseif default.features < 500
    default.resolution = 'l'; % low
    default.rivers = 0;
else
    default.resolution = 'c'; %crude
    default.rivers = 0;
end
default.color = in.color_background;

in.pscoast = optargs_struct(in.pscoast,default);

end
