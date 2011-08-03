function [flags,lat,lon,data] = homogenize_datalatlon(lat,lon,data)
% HOMOGENIZE_DATALATLON sort and rearrange data,lat,lon to common format
%
%  PURPOSE For gridded data.
%          Makes sure lat lons are ascending, lons are in -180:180 regime, 
%          and makes sure that data has the dimensions data(lat,lon)
%
%  IN      lat      vector
%          lon      vector
%  OPT     data     data(lat,lon,...) or data(lon,lat,...) 
%
%  OUT
%         flags     struct      A structure of flags to indicate which
%                               issue the function addressed.
%         lat       vector      Ascending lats
%         lons      vector      Ascending lons and 0:360 -> -180:180
%         data      matrix      data(lat,lon,....) and rearranged to new
%                               lat/lons
%
%
% USAGE:  [flags,lat,lon,data] = homogenize_datalatlon(lat,lon,data)
%         or
%         [flags,lat,lon] = homogenize_datalatlon(lat,lon)
%
%
% created by Salomon Eliasson
% $Id$

errID = 'gmtlab:homogenize_datalatlon:badInput';
dexist = nargin ==3;

if dexist
    assert(dexist && ~isequal(size(data),size(lat),size(lon)),....
        errID,'data does not appear to be gridded')
end

if dexist
    %PERMUTE data so that dimensions are data(lat,lon)
    sz = size(data);
    
    flags.permute = (length(lon)==sz(1) && length(lat)==sz(2)) && ... %wrong order
            length(lat) ~= length(lon);
        
    if flags.permute
        x = 1:ndims(data);
        x(1)=2;x(2)=1;
        data = permute(data,x);
    end
end

% make LONS ASCEND
flags.lon_descend = isequal(lon,sort(lon,'descend'));

if flags.lon_descend
    [lon,index] = sort(lon);
    if dexist
        data = data(:,index,:);
    end
end

assert(isequal(lon,sort(lon,'descend')) || isequal(lon,sort(lon,'ascend')) ,...,
    errID,'Longitudes must be ordered ascending or descending');

% make LATS ASCEND
flags.lat_descend = isequal(lat,sort(lat,'descend'));

if flags.lat_descend
    [lat,index] = sort(lat);
    if dexist
        data = data(index,:,:);
    end
end
assert(isequal(lat,sort(lat,'descend')) || isequal(lat,sort(lat,'ascend')) ,...,
    errID,'Latitudes must be ordered ascending or descending');


%make sure all longitudes are -180:180
flags.lon360 = any(lon > 180);

if flags.lon360

    lon = lon-(lon > 180)*360;
    [lon,lnindex] = sort(lon);
    if dexist
        data = data(:,lnindex,:);
    end
end

% Need to remove duplicate data at zeros and instead introduce duplicate
% data for -180 and 180
[sv,index] = unique(lon);
lon = lon(index);
if dexist, data = data(:,index,:); end
if lon(1)==-180 && ~lon(end)==180
    lon = [lon 180];
    if dexist
        data = [data data(:,1,:)];
    end
elseif lon(end)==180 && ~lon(1)==-180
    lon = [-180 lon];
    if dexist
        data = [data(:,end,:) data];
    end
end

if dexist
    data = reshape(data,[size(data,1),size(data,2),sz(3:end)]);
end