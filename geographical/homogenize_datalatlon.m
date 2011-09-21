function [flags,lat,lon,data] = homogenize_datalatlon(lat,lon,data)
% HOMOGENIZE_DATALATLON sort and rearrange data,lat,lon to common format
%
%                  For gridded data.
%   
%  PURPOSE  Makes sure lat lons are ascending, lons are in -180:180 regime, 
%           and makes sure that data has the dimensions data(lat,lon)
%
%  IN       lat      vector
%           lon      vector
%  OPT      data     data(lat,lon,...) or data(lon,lat,...) 
%
%  OUT
%           flags     struct      A structure of flags to indicate which
%                               issue the function addressed.
%           lat       vector      Ascending lats
%           lons      vector      Ascending lons and 0:360 -> -180:180
%           data      matrix      data(lat,lon,....) and rearranged to new
%                               lat/lons
%
%
% USAGE:    [flags,lat,lon,data] = homogenize_datalatlon(lat,lon,data)
%           or
%           [flags,lat,lon] = homogenize_datalatlon(lat,lon)
%
% created by Salomon Eliasson
% $Id$


% -------    CHECK for errors
errID = 'gmtlab:homogenize_datalatlon:badInput';
dexist = exist('data','var');

if dexist
    assert(dexist && ~isequal(size(data),size(lat),size(lon)),....
        errID,'data does not appear to be gridded')
end

assert(isequal(lon,sort(lon,'descend')) || isequal(lon,sort(lon,'ascend')) ,...,
    errID,'Longitudes must be ordered ascending or descending');

assert(isequal(lat,sort(lat,'descend')) || isequal(lat,sort(lat,'ascend')) ,...,
    errID,'Latitudes must be ordered ascending or descending');


% --------  SET FLAGS
if dexist
    sz = size(data);
    
    %undesired dimensions
    flags.permute = (length(lon)==sz(1) && length(lat)==sz(2)) && ...
        length(lat) ~= length(lon);
end

%undesired lon orientation
flags.lon_descend = isequal(lon,sort(lon,'descend')); 

%undesired latorientation
flags.lat_descend = isequal(lat,sort(lat,'descend'));

flags.lon360 = any(lon > 180);

% --------  HOMOGENIZE the input

% PERMUTE data so that dimensions are data(lat,lon)
if dexist
    if flags.permute
        x = 1:ndims(data);
        x(1)=2;x(2)=1;
        data = permute(data,x);
    end
end

% make LONS ASCENDING
if flags.lon_descend
    [lon,index] = sort(lon);
    if dexist
        data = data(:,index,:);
    end
end

% make LATS ASCEND
if flags.lat_descend
    [lat,index] = sort(lat);
    if dexist
        data = data(index,:,:);
    end
end


% make sure LONGITUDES ARE IN -180:180 REGIME
if flags.lon360
    lon = lon-(lon > 180)*360;
    [lon,lnindex] = sort(lon);
    if dexist
        data = data(:,lnindex,:);
    end
    
    % Need to remove duplicate data at zeros and instead introduce duplicate
    % data at lon = -180 and 180
    [sv,index] = unique(lon);
    lon = lon(index);
    if dexist
        data = data(:,index,:);
    end
    
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
end

if dexist
    data = reshape(data,[size(data,1),size(data,2),sz(3:end)]);
end