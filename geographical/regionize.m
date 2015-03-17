function [outdata,outlat,outlon,weights] = regionize(data,lat,lon,corner,opt)
%% regionize
%
% PURPOSE: function that nan's out all data outside a given region bounds (or several regions)
%
% IN: data %2 or more dims starting with (lat,lon,...) or (lon,lat,...)
%     lat  %vector
%     lon  %vector
%     corner = [blcorner,trcorner;blcorner,trcorner] % each corner is [lat,lon]
%
%     opt.trim     = true or false
%                    (1=trim data and lat lons outside the region (default), 0=don't)
%     opt.maskwith = NaN % what to mask the data with
%     opt.includeEdges = 0,1,2 depending on if you don't want (0), do want (1)
%                        to include the regionbounds in the output data. Or (2)
%                        if you want a weight between 0-1 to be given for the
%                        grid boxes where the region boundary cuts through
%
%     NOTE REGARDING corner: If you want to use a predefined region, use
%            e.g. corner = getPredefinedRegion('tropics') %look into function region list
%
%     NOTE REGARDING trim: If you need the size of data matrix to remain unchanged, input trim=0
%
% OUT:    outdata
%         outlat
%         outlon
%         weights % takes care of grids that are overlapping the edges
%         flags =
%
% USAGE: [data,lat,lon,weights,flags] = regionize(data,lat,lon,corner)
%
% NOTE: 1) If the data is gridded the spacing between lats and lon must be
%          equidegree.
%       2) Gridded data that is partly in and partly out of a region is
%          included in outdata. Use the 3rd output argument to weight the
%          data according to how much of the gridbox is in the region
%
%
% Created by Salomon Eliasson
% $Id$

errID = ['atmlab:',mfilename,':badInput'];
assert(nargin>=4,errID,'Not enought input arguments')
if nargin==4, opt = struct(); end

default.trim = true;
default.maskwith = NaN;
default.includeEdges = 0;

opt = optargs_struct(opt,default);


[outdata,outlat,outlon,setopt,flags] = setup(data,lat,lon);
opt  = catstruct(opt,setopt);

if opt.isgridded 
    
    if all(size(corner) == [1,4]) && ...
            (corner(1)==-90 && corner(2)==-180 && corner(3)==90 && corner(4)==180)
        logtext(1,'Global region. no need to regionize\n')
        weights = true(size(outdata));
        return
    end
    sz = size(outdata);
    
    %%%%%%%
    %
    % Trim the data before hand to quicken up the code
    
    % This is not the best way to quicken the code. Quicker to loop over
    % rectangular regions instead. Polar region is a good example
    
    % save these originals
    if ~opt.trim
        origdata = nan(size(outdata(:,:,:)));
        origlat  = outlat;
        origlon  = outlon;
    end
    
    % chop away what we don't need to look through
    indexlat = outlat>= min(corner(:,1)) & outlat<max(corner(:,3));
    indexlon = outlon>= min(corner(:,2)) & outlon<max(corner(:,4));
    outlat   = outlat(indexlat);
    outlon   = outlon(indexlon);
    z.data   = outdata(indexlat,indexlon,:);  %collapse to 3Doutdata;
    %z.data = outdata(:,:,:);
    %%%%%
    
    % for the sake of grids overlapping the edges
    dlt = mean(diff(unique(outlat)));
    dln = mean(diff(unique(outlon)));
    
    % NaN away everything that is not a region
    z.lat = repmat(outlat,1,length(outlon));
    z.lon = repmat(outlon,1,length(outlat))';
    
    [logical_field,periphery] = get_logicalfield(z,corner,dlt,dln,opt);

    %  ==========
    % 
    % Get the weights for the region. 0 outside, 1 inside, and 0,1,or 0<x<1 on
    % the edges depending on the choice. opt.includeEdges = 2 gives weights
    % between 0 and 1. Be aware that this is also the most expensive option
    
    if nargout == 4
        weights = zeros(size(logical_field));
    end
     
    if opt.includeEdges == 0
        
    elseif opt.includeEdges == 1
        
        logical_field(periphery) = true;
        
    elseif opt.includeEdges == 2
        if nargout == 4
            % Find weights for data on periphery of regions
            weights = findWeightsOnPeriphery(z.lat,z.lon,periphery,corner,dlt,dln);
        else
            error(errId,'No point of doing expensive weighting calculation if "weights" is not an output variable')
        end
    end
    
    if nargout == 4
        weights(logical_field) = 1;
    end
    
    % ======================
    %
    % Nan away everything outside region
    %
    tmp =  permute(z.data,[3,1,2]); tsz = size(tmp);
    tmp = tmp(:,:);
    tmp(:,~logical_field&~periphery) = opt.maskwith;
    if ~(isnan(opt.maskwith) && any(strcmp(class(tmp),{'double','single'}))) && ...
            ~isequal(opt.maskwith,cast(opt.maskwith,class(tmp)))
        warning('atmlab:behaviour',['Data class doesn''t match class of opt.maskwith. ',...
            'instead of masking with %d, masking with %d'],...
            opt.maskwith,cast(opt.maskwith,class(tmp)))
    
        tmp(:,~logical_field&~periphery) = cast(opt.maskwith,class(tmp));
    else
        tmp(:,~logical_field&~periphery) = opt.maskwith;
    end
    z.data = permute(reshape(tmp,tsz),[2,3,1]);
    
    % ====================
    %
    % Trim away NaNs outside the region
    %
    if opt.trim
        if nargout == 4
            [z.data,outlon,outlat,weights] = trimAwayNaNs_gridded(z.data,outlon,outlat,corner,[dlt,dln],weights);
        else
            [z.data,outlon,outlat] = trimAwayNaNs_gridded(z.data,outlon,outlat,corner,[dlt,dln]);
        end
    else
        origdata(indexlat,indexlon,:) = z.data;
        z.data = origdata;
        outlat = origlat;
        outlon = origlon;
    end
    
    % Reshape the data array back to the original lat/lon format (first 2 dims)
    if nargout==4
        [outdata,outlat,outlon,weights] = useFlags(z.data,outlon,outlat,flags,weights);
    else
        [outdata,outlat,outlon] = useFlags(z.data,outlon,outlat,flags);
    end
    %resurrect matrix size to the original format
    outdata = reshape(outdata,[size(outdata,1),size(outdata,2),sz(3:end)]);
    
else
    if ~istensor1(outdata)
        z.data = outdata(:);
        z.lat  = outlat(:);
        z.lon  = outlon(:);
    else
        z.data = outdata;
        z.lat  = outlat;
        z.lon  = outlon;
    end
    logical_field = get_logicalfield(z,corner,0,0,opt); %dlt and dln = 0
    outlat        = z.lat(logical_field);
    outlon        = z.lon(logical_field);
    
    if ~opt.maskonlyUngridded
        outdata       = z.data(logical_field);
    end
    
    if opt.trim
        [outdata,outlon,outlat] = trimAwayNaNs_ungridded(outdata,outlon,outlat,corner,opt);
    end
    if nargout==4
        weights = logical_field;
    end
end

%%%%%%%%%%%%%%%%%
%% SUBFUNCTIONS
%      |||||
%      VVVVV
function [outdata,outlat,outlon,opt,flags] = setup(data,lat,lon)
%% setup

errID = 'atmlab:reginize:badInput';

a = size(data);

opt.isgridded = isequal(a(1:2),[length(lat),length(lon)]) | isequal(a(1:2),[length(lon),length(lat)]);
opt.maskonlyUngridded = isempty(data) & isequal(size(lat),size(lon));


if ~opt.isgridded || opt.maskonlyUngridded
    outlon = lon(:);
    outlat = lat(:);
    outdata = data(:);
    flags = [];
    return
end


assert(isequal(a(1:2),[length(lat),length(lon)]) || isequal(a(1:2),[length(lon),length(lat)]),...
    errID,'Incorrect size dimensions of lat, lon, data')


% make sure conventions are followed
[flags,outlat,outlon,outdata] = standardize_geodata(lat(:),lon(:),data);

function [logical_field,periphery] = get_logicalfield(in,corner,dlt,dln,opt)
%% get_logicalfield

% fit exactly
if opt.maskonlyUngridded
    logical_field=false(size(in.lat));
else
    logical_field=false([size(in.data,1),size(in.data,2)]);
end

for i = 1:size(corner,1)
    lt1 = in.lat >= corner(i,1) + dlt/2;
    lt2 = in.lat <= corner(i,3) - dlt/2;
    ln1 = in.lon >= corner(i,2) + dln/2;
    ln2 = in.lon <= corner(i,4) - dln/2;
    
    logical_field = logical_field | ( ln1&ln2&lt1&lt2 );
end

if ~opt.isgridded
    % there are no pixels partly in and out of the region
    return
end

% on the periphery of the region
periphery=false([size(in.data,1),size(in.data,2)]);
for i = 1:size(corner,1)
    lt1 = in.lat >= corner(i,1) - dlt/2;
    lt2 = in.lat <= corner(i,3) + dlt/2;
    ln1 = in.lon >= corner(i,2) - dln/2;
    ln2 = in.lon <= corner(i,4) + dln/2;
    
    periphery = periphery | ( ln1&ln2&lt1&lt2 );
end
periphery(logical_field)=false;

function weights = findWeightsOnPeriphery(lat,lon,periphery,C,dlt,dln)
%% findWeightsOnPeriphery
%
% First NaNs away grids that are not on the perifery
% Then loops over these points to find out how how they overlap the
% region boundaries
%
% C = corners ([blcorner,trcorner;blcorner,trcorner]), dlt & dln are the gridsizes

sz      = size(lat);
weights = zeros(sz);
index     = 1:length(lat(:));
index     = reshape(index,sz);
index     = index(periphery);

% Now loop over remaining points
AREA = 0;
for i = index'
    for j = 1:size(C,1)
        A = [lon(i)-dln/2,lat(i)-dlt/2,dln,dlt];
        B = [C(j,2),C(j,1),C(j,4)-C(j,2),C(j,3)-C(j,1)];
        AREA = AREA + rectint(A,B);
    end
    weights(i) = AREA/(dlt*dln); % normalized area. Max = 1;
    AREA = 0;
end

function [data,lon,lat,weights] = trimAwayNaNs_gridded(data,lon,lat,corner,gsize,weights)
%% Trim dataset to get rid of NaNs outside the regions
% If you don't need weights, make the 4th argument empty []
% gsize is the size of the grid [dlat,dlon]

gh = gsize/2; %half boxwidth

% Use the corner input to trim away the data
if ismatrix(data)
    data = data(lat>=min(corner(:,1))-gh(1) & lat<=max(corner(:,3))+gh(1),...
        lon>=min(corner(:,2))-gh(2) & lon<=max(corner(:,4))+gh(2));
elseif ndims(data)==3
    data = data(lat>=min(corner(:,1))-gh(1) & lat<=max(corner(:,3))+gh(1),...
        lon>=min(corner(:,2))-gh(2) & lon<=max(corner(:,4))+gh(2),:);
end

if nargout == 4
    weights = weights(lat>=min(corner(:,1))-gh(1) & lat<=max(corner(:,3))+gh(1),...
        lon>=min(corner(:,2)) -gh(2) & lon<=max(corner(:,4))+gh(2));
end
lat = lat(lat>=min(corner(:,1))-gh(1) & lat<=max(corner(:,3))+gh(1));
lon = lon(lon>=min(corner(:,2))-gh(2) & lon<=max(corner(:,4))+gh(2));

function [data,lon,lat] = trimAwayNaNs_ungridded(data,lon,lat,corner,opt)
%% Trim dataset to get rid of NaNs outside the regions


% Use the corner input to trim away the data
if ~opt.maskonlyUngridded
    if ismatrix(data)
        data = data(lat>=min(corner(:,1)) & lat<=max(corner(:,3)) &...
            lon>=min(corner(:,2)) & lon<=max(corner(:,4)));
    elseif ndims(data)==3
        data = data(lat>=min(corner(:,1)) & lat<=max(corner(:,3)) &...
            lon>=min(corner(:,2)) & lon<=max(corner(:,4)),:);
    end
end
lat = lat(lat>=min(corner(:,1)) & lat<=max(corner(:,3)));
lon = lon(lon>=min(corner(:,2)) & lon<=max(corner(:,4)));

function [data,lat,lon,weights] = useFlags(data,lon,lat,flags,weights)
%% useFlags
%
% This function will only be called if the data is gridded
%
%
% if the orig lons are in the 0:360 regime. Put them BACK

w = nargout == 4;

if flags.lon360
    lon = lon +(lon < 0)*360;
    [lon,lnindex] = sort(lon);
    data    = data(:,lnindex,:);
    if w; weights = weights(:,lnindex);end
end
%
if flags.lon_descend
    [lon,lnindex]  = sort(lon,'descend');
    data = data(:,lnindex,:);
    if w; weights = weights(:,lnindex);end
end

% If the orig lats are DESCENDING. Put them BACK
if flags.lat_descend
    [lat,ltindex]  = sort(lat,'descend');
    data = data(ltindex,:,:);
    if w; weights = weights(ltindex,:); end
end

% If orig data was data(lon,lat,...), Permute BACK
if flags.permute
    data = permute(data,[2,1,3]);
    if w; weights = permute(weights,[2,1]); end
end
