function [outdata,outlat,outlon,weights] = regionize(data,lat,lon,corner)
%% regionize
%
% PURPOSE: function that nan's out all data outside a given region bounds (or several regions)
%
% IN: data
%     lat
%     lon
%     corner = [blcorner,trcorner;blcorner,trcorner] % each corner is [lat,lon]
%
% OUT:    outdata
%         outlat
%         outlon
%         weights
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

errID = 'atmlab:reginize:badInput';
assert(nargin==4,errID,'Not enought input arguments')

[outdata,outlat,outlon,ig,flags] = setup(data,lat,lon);

% for the sake of grids overlapping the edges
dlt = mean(diff(unique(lat)));
dln = mean(diff(unique(lon)));

if ig
    sz = size(outdata);

    outdata = outdata(:,:,:);  %collapse to 3D
    
    % Get the box that contains all regions (and then some)
    indexlat = outlat >= min(corner(:,1)) - dlt & outlat <= max(corner(:,3)) + dlt;
    indexlon = outlon >= min(corner(:,2)) - dln & outlon <= max(corner(:,4)) + dln;
    outlon = outlon(indexlon);
    outlat = outlat(indexlat);
    assert(any(indexlat)&&any(indexlon) ,errID,'no data is in the specified region')
    
    % crudely BOX in region
    z.data = outdata(indexlat,indexlon,:);
    
    % NaN away everything that is not a region
    z.lat = repmat(outlat,1,length(outlon));
    z.lon = repmat(outlon,1,length(outlat))';
    
    [logical_field,periphery] = get_logicalfield(z,corner,dlt,dln);
    
    % Find weights for data on periphery of regions
    weights = findWeightsOnPeriphery(z.lat,z.lon,periphery,corner,dlt,dln);
    weights(logical_field) = 1;

    % Nan away everything outside region
    tmp =  permute(z.data,[3,1,2]); tsz = size(tmp);
    tmp = tmp(:,:);
    tmp(:,~logical_field&~periphery) = NaN;
    z.data = permute(reshape(tmp,tsz),[2,3,1]);

    % Reshape the data array back to the original format
    [outdata,outlat,outlon,weights] = useFlags(z.data,outlon,outlat,weights,flags);
    
    outdata = reshape(outdata,[size(outdata,1),size(outdata,2),sz(3:end)]);
    
else
    z.data        = outdata(:);
    z.lat         = outlat(:);
    z.lon         = outlon(:);
    logical_field = get_logicalfield(z,corner);
    
    outlat        = z.lat(logical_field);
    outlon        = z.lon(logical_field);
    outdata       = z.data(logical_field);
end

%%%%%%%%%%%%%%%%%
%% SUBFUNCTIONS
%      |||||
%      VVVVV
function [outdata,outlat,outlon,ig,flags] = setup(data,lat,lon)
%% setup

errID = 'atmlab:reginize:badInput';

a = size(data);
ig = ~isequal(a,size(lat),size(lon));              % is gridded or not

if ~ig
    outlon = lon(:);
    outlat = lat(:);
   outdata = data(:);
   flags = [];
   return
end


assert(isequal(a(1:2),[length(lat),length(lon)]) || isequal(a(1:2),[length(lon),length(lat)]),...
    errID,'Dimensions of data don''t must be data(lat,lon,...) or data(lon,lat,...)')


% make sure conventions are followed
[flags,outlat,outlon,outdata] = homogenize_datalatlon(lat(:),lon(:),data);

function [logical_field,periphery] = get_logicalfield(in,corner,dlt,dln)
%% get_logicalfield

% fit exactly 
logical_field=false([size(in.data,1),size(in.data,2)]);
for i = 1:size(corner,1)
    lt1 = in.lat >= corner(i,1) + dlt/2;
    lt2 = in.lat <= corner(i,3) - dlt/2;
    ln1 = in.lon >= corner(i,2) + dln/2;
    ln2 = in.lon <= corner(i,4) - dln/2;

    logical_field = logical_field | ( ln1&ln2&lt1&lt2 );
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
num     = 1:length(lat(:));
num     = reshape(num,sz);
num     = num(periphery);

% Now loop over remaining points. Loop also over the regions
AREA = 0;
for i = num'
    for j = 1:size(C,1)
        A = [lon(i)-dln/2,lat(i)-dlt/2,dln,dlt];
        B = [C(j,2),C(j,1),C(j,4)-C(j,2),C(j,3)-C(j,1)];
        AREA = AREA + rectint(A,B);
    end
    weights(i) = AREA/(dlt*dln); % normalized area. Max = 1;
    AREA = 0;
end

function [data,lat,lon,weights] = useFlags(data,lon,lat,weights,flags)
%% useFlags

% if the orig lons are in the 0:360 regime. Put them BACK
if flags.lon360
    lon = lon +(lon < 0)*360;
    [lon,lnindex] = sort(lon);
    data    = data(:,lnindex,:);
    weights = weights(:,lnindex);
end
%
if flags.lon_descend
    [lon,lnindex]  = sort(lon,'descend');
    data = data(:,lnindex,:);
    weights = weights(:,lnindex);
end

% If the orig lats are DESCENDING. Put them BACK
if flags.lat_descend
    [lat,ltindex]  = sort(lat,'descend');
    data = data(ltindex,:,:);
    weights = weights(ltindex,:);
end

% If orig data was data(lat,lon,...), Permute BACK
if ~flags.permute
    data = permute(data,[2,1,3]);
    weights = permute(weights,[2,1]);
end 
