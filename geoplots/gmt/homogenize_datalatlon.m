function [data,lat,lon] = homogenize_datalatlon(data,lat,lon)
%% HOMOGENIZE_DATALATLON sort and rearrange data,lat,lon to common format
%
% Purpose: For gridded data.
%          Makes sure lat lons are ascending, lons are in -180:180 regime, 
%          and makes sure that data has the dimensions data(lat,lon)
%
%
% IN:  data,lat,lon
% OUT: data,lat,lon
%
% 'data' may have 2->5 dimensions
%
% created by Salomon Eliasson
% $Id$

assert(~isequal(size(data),size(lat),size(lon)),...
    'gmtlab:homogenize_datalatlon:badInput',...
    'data does not appear to be gridded')

%flip so that dimensions are data(lat,lon)
x = 1:ndims(data);
if (length(lon)==size(data,1) && length(lat)==size(data,2)) && ... %wrong order
        length(lat) ~= length(lon) % if square, do nothing
    x(1)=2;x(2)=1;
    data = permute(data,x);
end

%flip data for ascending order
if max(lon) == lon(1)
    [lon,index] = sort(lon);
    data = data(:,index,:,:,:);
end
if max(lat) == lat(1)
    [lat,index] = sort(lat);
    data = data(index,:,:,:,:);
end

%change all longitudes to -180:180
lon = lon-(lon > 180)*360;
[lon,lnindex] = sort(lon);
data = data(:,lnindex,:,:,:);

% Need to remove duplicate data at zeros and instead introduce duplicate
% data for -180 and 180
[sv,index] = unique(lon);
lon = lon(index);
data = data(:,index,:,:,:);

if lon(1)==-180 && ~lon(end)==180
    lon = [lon 180];
    data = [data data(:,1,:,:,:)];
elseif lon(end)==180 && ~lon(1)==-180
    lon = [-180 lon];
    data = [data(:,end,:,:,:) data];
end