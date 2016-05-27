function [corners,extra] = getPredefinedRegions(regionstr)
% GETPREDEFINEDRREGIONS Returns lat/lon corner values of predefined regions
%
% IN:    <none>        If nothing is input the list of currently available
%                      regions are shown. Build on this list in
%                      retrieve_reginfo.m if you want other regions
%        regionstr     {'%s'} Use one or more regions listed in retrieve_reginfo.m
%
% OUT: corners = [blcorner,trcorner;blcorner,trcorner]
%      extra   = structure contianing extra information about the regions
%               1) extra.center = center of the region (e.g. for plotting region labels)
%               2) extra.area   = normalised are of the region [0-1], where 1=global
%               3) extra.longname = a string of the longname of the regions.
%
% NOTE:
% - Regions, including all of the AR4 IPCC regions (ch 11), can be chosen
%   from the set of regions (see list below). The code defining the regions
%   is in the subfunction (retrieve_reginfo) to this function.
%
% current LIST of regions:
%    - Make sure to update this list if you add a region to the subfunction!!
%    Allregions = {'global','total','tropics','boreal_trop','austral_trop',...
%        'sepdz','seadz','ocean_sub','twp','trop_cont','conv_sa','conv_af',...
%        'swl','kurosho','gulfstr','nwl','westerlies','swe','aus','polar',...
%        'waf','eaf','saf','sah','neu','sem','nas','cas','tib','eas','sas',...
%        'sea','ala','cgi','wna','cna','ena','cam','amz','ssa','nau','sau',...
%        'car','ind','med','tne','npa','spa','arc','ant'};
%
% USAGE      [details,N,regionstrings]  = predefinedRegions   %if you want
%                                                               the list of
%                                                               regions
%
%            [corners,nregions,longname] = predefinedRegions(regionstr)
%            % regular use to get corners of a region
%
% Created by Salomon Eliasson
% $Id$

if ~nargin
    corners       = retrieve_reginfo('list');
    fn            = fieldnames(corners);
    longname = cell(1,length(fn)); i =1;
    for F = fn'
        longname{i} = corners.(F{1}).extra.longname;
        i = i+1;
    end
    extra = struct();
    return
end
assert(iscell(regionstr)||ischar(regionstr),...
    'atmlab:predefinedRegions:badInput','input must be a cell of strings (region names)')

if ~iscell(regionstr)
    regionstr = {regionstr};
end

k=1;
corners       = zeros(100*length(regionstr),4);

for i = 1:length(regionstr) % loop over regionstrings
    
    if ~ismember(regionstr{i},Allregions)
        disp(Allregions)
        error('atmlab:predefinedRegions:notFound','region: %s is not in list',regionstr{i})
        
    end
    [blcorner,trcorner,extra{i}]=retrieve_reginfo(regionstr{i});
    len = size(blcorner,1);
    
    corners(k:k+len-1,1:2) = blcorner;
    corners(k:k+len-1,3:4) = trcorner;
    k = k+len;
end

corners = corners(1:k-1,:,:,:);
end

%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
% ||||||||
% VVVVVVVV

function [blcorner,trcorner,extra]=retrieve_reginfo(regionstr)
%% RETRIEVE_REGINFO returns infor required to work with predefined regions
%
% IN: regionstr   %s       Stringname of region. Check list of regions in
%                          Allregions (further down). If regionstr =
%                          'list', the function will list all configured
%                          regions
%
% OUT: 1) bottom left corners of boxes [lat,lon]
%      2) top right corners of boxes   [lat,lon]
%      3) long stringname of the region
%
% Created by Salomon Eliasson
% $Id$

extra.center =  struct('lat',[],'lon',[]);
extra.area   = 0;
extra.riktigArea   = 0;
k = 1;

assert(nargin==1,'atmlab:retrieve_reginfo:badInput','needs input')
if strcmp(regionstr,'list')
    % Make sure to update this list if you add a region!!
    
    for A = Allregions
        [blcorner,trcorner,extra]=retrieve_reginfo(A{1});
        
        Allreg.(A{1}).extra  = extra;
        Allreg.(A{1}).corners   = [blcorner, trcorner];
    end
    
    % abuse the blcorner and dump everything into it
    blcorner=Allreg;trcorner=[];
    return
end

switch lower(regionstr)
    case 'global'
        extra.longname='Global';
        extra.shortname='global';
        blcorner = [-90,-180]; trcorner = [90,180];
        extra.center =  struct('lat',0,'lon',0);
    case 'tropics'
        extra.longname='Tropics';
        [a,b,x(1)] = retrieve_reginfo('boreal_trop');
        [c,d,x(2)] = retrieve_reginfo('austral_trop');
        blcorner = cat(1,a,c);
        trcorner = cat(1,b,d);
    case 'boreal_trop'
        extra.longname='Tropical northern hemisphere';
        blcorner = [0,-180]; trcorner = [30,180];
        extra.center =  struct('lat',15,'lon',0);
    case 'austral_trop'
        extra.longname='Tropical southern hemisphere';
        blcorner = [-30,-180]; trcorner = [0,180];
        extra.center =  struct('lat',-15,'lon',0);
    case 'sepdz'
        extra.longname ='South East Pacific Dry Zone';
        blcorner = [-27,-110;-18,-130]; trcorner = [-18,-72;2,-82];
        extra.center =  struct('lat',-10,'lon',-100);
    case 'seadz'
        extra.longname ='South East Atlantic Dry zone';
        blcorner = [-30,-15;-20,-30]; trcorner = [-5,10;-5,-15];
        extra.center = struct('lat',-16,'lon',-10);
    case 'ocean_sub'
        % this is both seadz and sepdz merged
        extra.longname ='Subsidence zones of the South East Pacific and South East Atlantic';
        [a,b,x(1)] = retrieve_reginfo('sepdz');
        [c,d,x(2)] = retrieve_reginfo('seadz');
        blcorner = cat(1,a,c);
        trcorner = cat(1,b,d);
    case 'sepsc'
        extra.longname ='South east Pacific stratocumulus zone';
        blcorner = [];trcorner = [];
        blcorner(end+1,1:2) = [-7,-100]; trcorner(end+1,1:2) = [-4,-81.5];
        blcorner(end+1,1:2) = [-8.5,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-80];
        blcorner(end+1,1:2) = [-10.5,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-79];
        blcorner(end+1,1:2) = [-12,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-78];
        blcorner(end+1,1:2) = [-14.5,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-77];
        blcorner(end+1,1:2) = [-15.5,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-76];
        blcorner(end+1,1:2) = [-16,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-75];
        blcorner(end+1,1:2) = [-17,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-74];
        blcorner(end+1,1:2) = [-17.5,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-73];
        blcorner(end+1,1:2) = [-18.25,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-72];
        blcorner(end+1,1:2) = [-23,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-70.5];
        blcorner(end+1,1:2) = [-27,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-71];
        blcorner(end+1,1:2) = [-30,-100]; trcorner(end+1,1:2) = [blcorner(end-1,1),-71.5];
        extra.center =  struct('lat',-20,'lon',-85);
    case 'seasc'
        extra.longname ='South east Atlantic stratocumulus zone';
        blcorner = [];trcorner = [];
        w=-10;
        blcorner(end+1,1:2) = [-30,              w]; trcorner(end+1,1:2) = [-29.5,17];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-28.75,16.5];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-28,15.75];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-27,15.25];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-26,15];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-25,14.75];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-22,14.25];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-21,13.5];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-20,13];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-19,12.5];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-18.5,12];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-15,11.5];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-13.5,12.25];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-13,12.5];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-12.5,13];
        blcorner(end+1,1:2) = [trcorner(end,1),  w]; trcorner(end+1,1:2) = [-10,13.5];
        
        extra.center =  struct('lat',-20,'lon',0);
        
    case 'sc_regs'
        % this is both seadz and sepdz merged
        extra.longname ='Stratocumulus regions';
        [a,b,x(1)] = retrieve_reginfo('sepsc');
        [c,d,x(2)] = retrieve_reginfo('seasc');
        blcorner = cat(1,a,c);
        trcorner = cat(1,b,d);
    case 'conv_sa'
        extra.longname ='Continental convection area (South America)';
        blcorner = [-14,-71.9;-5,-79;0,-80];
        trcorner = [-5,-50;0,-56;10,-60];
        extra.center =  struct('lat',-2,'lon',-68);
    case 'conv_af'
        extra.longname ='Continental convection area (Africa)';
        blcorner = [-16,15;-5,11;0,0];
        trcorner = [-5,30;0,33;8,34];
        extra.center =  struct('lat',0,'lon',20);
    case 'trop_cont'
        % this is conv_af and conv_sa merged
        extra.longname ='Tropical convection over continents';
        [a,b,x(1)] = retrieve_reginfo('conv_af');
        [c,d,x(2)] = retrieve_reginfo('conv_sa');
        blcorner = cat(1,a,c);
        trcorner = cat(1,b,d);
    case 'twp'
        extra.longname ='Tropical Warm Pool';
        blcorner = [-12 80;-8 100;-12 155];
        trcorner = [16 100;14 155;10 175];
        extra.center =  struct('lat',2,'lon',120);
    case 'swl'
        extra.longname ='Southern midlatitude Westerlies';
        blcorner = [-60 -180; -60 -50];
        trcorner = [-45  -80; -45 180];
        extra.center =  struct('lat',-52,'lon',{-130,60});
    case 'kurosho'
        extra.longname ='The region surrounding the Kurosho Current';
        % need extra region as passing the dateline causes problems
        blcorner = [33,145;40,160;36,-180;40,-160];
        trcorner = [40,180;50,180;50,-160;55,-135];
        extra.center =  struct('lat',{38,46},'lon',{165,-160});
    case 'gulfstr'
        extra.longname ='The region surrounding the Gulfstream';
        blcorner=[35,-70;45,-55;];
        trcorner=[45,-40;60,-10;];
        extra.center =  struct('lat',52,'lon',-40);
    case 'nwl'
        extra.longname ='Northern midlatitude Westerlies';
        [a,b,x(1)] = retrieve_reginfo('gulfstr');
        [c,d,x(2)] = retrieve_reginfo('kurosho');
        blcorner = cat(1,a,c);
        trcorner = cat(1,b,d);
    case 'westerlies'
        % this is swl and nwl merged
        extra.longname ='Midlatitude westerlies';
        [a,b,x(1)] = retrieve_reginfo('gulfstr');
        [c,d,x(2)] = retrieve_reginfo('kurosho');
        [e,f,x(3)] = retrieve_reginfo('swl');
        blcorner = cat(1,a,c,e);
        trcorner = cat(1,b,d,f);
    case 'aus'
        extra.longname ='Australia';
        blcorner = [-45,100]; trcorner = [0,170];
    case 'swe'
        extra.longname='Sweden';
        blcorner = [54,4];trcorner = [72,32];
    case 'polar'
        extra.longname = 'Polar regions';
        [a,b,x(1)] = retrieve_reginfo('ant');
        [c,d,x(2)] = retrieve_reginfo('arc');
        blcorner = cat(1,a,c);
        trcorner = cat(1,b,d);
    otherwise
        switch regionstr
            
            %%%%%%%%%%%%%%%%%%%%
            % Regions below this line are reserved for AR4 IPCC regions (Ch. 11)
            %{'waf','eaf','saf','sah','neu','sem','nas','cas','tib','eas','sas',...
            % 'sea','ala','cgi','wna','cna','ena','cam','amz','ssa','nau','sau',...
            %'car','ind','med','tne','npa','spa','arc','ant'}
            
            % Africa
            case 'waf'
                extra.longname ='West Africa';
                blcorner = [-12,-20]; trcorner = [22,18];
            case 'eaf'
                extra.longname ='East Africa';
                blcorner = [-12,22]; trcorner = [18,52];
            case 'saf'
                extra.longname ='South Africa';
                %                 disp('WARNING: hard-coded bounding corners dont ')
                %                 disp('         correspond to those on p856 in AR4 IPCC rapport')
                %                 disp('         and have been adjusted to figure 11.26 p923')
                %                 disp('i.e. 35S,10E - 12S,52E has been adjusted to 35S,-10E - 12S,52E')
                blcorner = [-35,-10]; trcorner = [-12,52];
            case 'sah'
                extra.longname ='Sahara';
                %                 disp('WARNING: hard-coded bounding corners dont ')
                %                 disp('         correspond to those on p856 in AR4 IPCC rapport')
                %                 disp('         and have been adjusted to figure 11.26 p923')
                %                 disp('i.e. 18N,20E - 30N,65E has been adjusted to 18N,20W - 30N,65E')
                blcorner = [18,-20]; trcorner = [30,65];
                
                %Europe
            case 'neu'
                extra.longname ='Northern Europe';
                blcorner = [48,-10]; trcorner = [75,40];
            case 'sem'
                extra.longname ='Southern Europe and Mediterranean';
                blcorner = [30,-10]; trcorner = [48,40];
                
                %Asia
            case 'nas'
                extra.longname ='Nothern Asia';
                blcorner = [50,40]; trcorner = [70,180];
            case 'cas'
                extra.longname ='Central Asia';
                blcorner = [30,40]; trcorner = [50,75];
            case 'tib'
                extra.longname ='Tibetan Plateau';
                %                 disp('WARNING: hard-coded bounding corners dont ')
                %                 disp('         correspond to those on p856 in AR4 IPCC rapport')
                %                 disp('         and have been adjusted to figure 11.26 p923')
                %                 disp('i.e. 30N,50E - 75N,100E has been adjusted to 30N,75E - 50N,100E')
                blcorner = [30,75]; trcorner = [50,100];
            case 'eas'
                extra.longname ='East Asia';
                blcorner = [20,100]; trcorner = [50,145];
            case 'sas'
                extra.longname ='South Asia';
                %                         disp('         correspond to those on p856 in AR4 IPCC rapport')
                %                         disp('         and have been adjusted to figure 11.26 p923')
                %                         disp('i.e. 5N,64E - 50N,100E has been adjusted to 5N,64E - 30N,100E')
                blcorner = [5,64]; trcorner = [30,100];
            case 'sea'
                extra.longname ='South East Asia';
                %                 disp('         correspond to those on p856 in AR4 IPCC rapport')
                %                 disp('         and have been adjusted to figure 11.26 p923')
                %                 disp('i.e. 11S,95E - 20N,115E has been adjusted to 11S,95E - 20N,')
                blcorner = [-11,95]; trcorner = [20,155];
                
                % North America
            case 'ala'
                extra.longname ='Alaska';
                blcorner = [60,-170]; trcorner = [72,-103];
            case 'cgi'
                extra.longname ='East Canada, Greenland, Iceland';
                blcorner = [50,-103]; trcorner = [85,-10];
            case 'wna'
                extra.longname ='Western North America';
                %                 disp('WARNING: hard-coded bounding corners dont ')
                %                 disp('         correspond to those on p856 in AR4 IPCC rapport')
                %                 disp('         and have been adjusted to figure 11.26 p923')
                %                 disp('i.e. 30N,50E - 75N,100E has been adjusted to 30N,130W - 60N,103W')
                blcorner = [30,-130]; trcorner = [60,-103];
            case 'cna'
                extra.longname ='Central North America';
                blcorner = [30,-103]; trcorner = [50,-85];
            case 'ena'
                extra.longname ='Eastern North America';
                %                 disp('WARNING: hard-coded bounding corners dont ')
                %                 disp('         correspond to those on p856 in AR4 IPCC rapport')
                %                 disp('         and have been adjusted to figure 11.26 p923')
                %                 disp('i.e. 25N,85W - 50N,50W has been adjusted to 25N,85W - 50N,60W')
                blcorner = [25,-85]; trcorner = [50,-60];
                % Central and South America
            case 'cam'
                extra.longname ='Central America';
                blcorner = [10,-116]; trcorner = [30,-83];
            case 'amz'
                extra.longname ='Amazonia';
                blcorner = [-20,-82]; trcorner = [12,-34];
            case 'ssa'
                extra.longname ='Southern South America';
                blcorner = [-56,-76]; trcorner = [-20,-40];
                
                %Australia and New Zealand
            case 'nau'
                extra.longname ='North Australia';
                blcorner = [-30,110]; trcorner = [-11,155];
            case 'sau'
                extra.longname ='South Australia';
                blcorner = [-45,110]; trcorner = [-30,155];
                %Small islands and oceans
            case 'car'
                extra.longname ='Caribbean';
                blcorner = [10,-85]; trcorner = [25,-60];
            case 'ind'
                extra.longname ='Indian Ocean';
                blcorner = [-35,50]; trcorner = [17.5,100];
            case 'med'
                extra.longname ='Mediterranean Basen';
                blcorner = [30,-5]; trcorner = [45,35];
            case 'tne'
                extra.longname ='Tropical North East Atlantic';
                blcorner = [0,-30]; trcorner = [40,-10];
            case 'npa'
                extra.longname ='North Pacific Ocean';
                blcorner = [0,150]; trcorner = [40,360-120];
            case 'spa'
                extra.longname ='South Pacific Ocean';
                blcorner = [-55,150]; trcorner = [0,360-80];
            case 'arc'
                extra.longname ='Arctic';
                blcorner = [70,-180]; trcorner = [90,180];
                extra.center =  struct('lat',75,'lon',0);
            case 'ant'
                extra.longname ='Antarctica';
                blcorner = [-90,-180]; trcorner = [-70,180];
                extra.center =  struct('lat',-75,'lon',0);
        end
end

if ~exist('x','var')
    corner = zeros(size(blcorner,1),4);
    corner(:,1:2) = blcorner;
    corner(:,3:4) = trcorner;
    
    % get the area and mask
    [extra.riktigArea,extra.area,extra.mask] = find_regionArea(corner,regionstr);
    extra.shortname = regionstr;
else
    % In that case it is an assembled regionstr
    
    extra.shortname=regionstr;
    extra.riktigArea = sum([x.riktigArea]);
    extra.area = sum([x.area]);
    extra.mask.lat = x(1).mask.lat;
    extra.mask.lon = x(1).mask.lon;
    extra.mask.mask = false(length(extra.mask.lon),length(extra.mask.lat));
    for i = 1:length(x)
        extra.mask.mask = extra.mask.mask | x(i).mask.mask;
        
        L=length(x(i).center);
        extra.center(k:k+L-1)   = x(i).center;
        extra.partial_riktigArea(i)   = x(i).riktigArea;
        extra.partial_area(i)   = x(i).area;
        extra.partial_region{i} = x(i).longname;
        extra.partial_region_short{i} = x(i).shortname;
        k = k+L;
    end
end
clear x

end
function Allregions = Allregions

Allregions = {'global','tropics','boreal_trop','austral_trop',...
    'sepdz','seadz','ocean_sub','sepsc','seasc','sc_regs','twp','trop_cont','conv_sa','conv_af',...
    'swl','kurosho','gulfstr','nwl','westerlies','swe','aus','polar',...
    'waf','eaf','saf','sah','neu','sem','nas','cas','tib','eas','sas',...
    'sea','ala','cgi','wna','cna','ena','cam','amz','ssa','nau','sau',...
    'car','ind','med','tne','npa','spa','arc','ant'};

end

function [latWeightedArea,area,mask] = find_regionArea(corner,regstr)

% Find the area of the region in relation to the Earth. Also, provide a region
% mask easy to apply to data in order to single out a region
%
% latWeightedArea  = is the actual fractional area of the region
% area = is the area of the region if the world is flat (i.e., not taking
% latitudes into account)

step = .1; %deg
lat =-90+step:step:90-step;
lon =-180+step:step:180-step;
mask = true(length(lon),length(lat));

if strcmp(regstr,'global')
    clear mask
    mask.lat=lat;
    mask.lon=lon;
    mask.data=true(length(lon),length(lat));
    latWeightedArea=1;
    area=1;
    return
end

mask = regionize(mask,lat,lon,corner,struct('maskwith',false,'trim',0));

latweights=repmat(cosd(lat),length(lon),1);
regweights = latweights(mask);
latWeightedArea = nansum(regweights(:))/sum(latweights(:));
area = sum(mask(:))/sum(~mask(:));
tmp = mask;
clear mask
mask.lat = lat;
mask.lon = lon;
mask.mask = tmp;

end