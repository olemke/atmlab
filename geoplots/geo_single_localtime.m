function data = geo_single_localtime(utcvec,localtime,data,lon,lat,method)
% GEO_SINGLE_LOCALTIME creates a matrix of data so that all grids have the same local time
%
% IN
%     utcvec      [%f,...]              utc values covering a day. e.g. 0:3:21
%     localtime   %f                    scalar local time in decimals e.g.1.5=01:30AM
%     data        data(lon,...,time)    data matrix with the dimensions
%                                       data(lat,lon,...,time)
%                                       or
%                                       data(lon,lat,...,time)
%
%                                       size(data,1)= length(lon) &&
%                                       size(data,4)=length(utcvect)
%     lon         [%f,...]              longitudes vector
%     lat         [%f,...]              latitudes vector (needed for function homogenize_datalatlon)
%     method      %s                    The method interp1 will use (default='linear')
%
% OUT
%     out =      data                   Interpolated data values at the
%                                       specified localtime
%
%
%
% NOTE
%     * Assumes input dimensions data(lon,lat,height,time) or data(lon,lat,time)
%     * If your region data spans a square region (length(lat)=length(lon)) make
%       sure
%
% USAGE: out = lcl_time_array(utcvec,localtime,data,lon,lat,method)
%
% Created by Salomon Eliasson 
% Modified by Marston Johnston
%
% $Id$

if nargin < 6
    method = 'linear';
end

N = ndims(data);

assert( ( isequal(size(data,1),length(lon)) || isequal(size(data,2),length(lon))) && ...
    isequal(size(data,N),length(utcvec)),...
    'atmlab:lcl_time_array:badInput','See usage')

% INTERNALLY make lons -180:180 and adjust data accordingly
[flags,lat,lon,data] = homogenize_datalatlon(lat,lon,data);

% Get the SIZE of the original data
sz = size(data);

% PERMUTE so that the data(time,lon,lat...). % data(lat,lon,...) is ensured
% via the homogenize function
data = permute(data,[N,2,1,3:N-1]);

% COLLAPSE it to data(time,lon,lat*height*etc)
data = data(:,:,:);

% locally make utc CYCLIC (covering the whole day)
if ismember(0,utcvec) && ~ismember(24,utcvec)
    utcvec = [utcvec 24];
    data = [data; data(1,:,:)];
end

% get the EQUIVALENT utc timefor each longitude for the local time
utc0 = mod(localtime - 24/360 * lon, 24);

% INTERPOLATE
out = zeros([length(lon),size(data,3)],class(data));
for i = 1:size(data,2) % longitude in the first dimension
    D = squeeze(data(:,i,:));
    out(i,:) = interp1(utcvec, D, utc0(i), method);
end

% if the orig lons are in the 0:360 regime. Put them BACK
if flags.lon360
    lon = lon +(lon < 0)*360;
    [lon,indexlon] = sort(lon);
    out = out(indexlon,:);
end
%
if flags.lon_descend
    out = out(end:-1:1,:);
end

% RECONSTRUCT collapsed dimensions
data = reshape(out,[size(out,1),sz([1,3:N-1])]);

% If the orig lats are DESCENDING. Put them BACK
if flags.lat_descend
    % permute to put lat in first position in order to callapse
    data = permute(data,[2,1,3:N-1]);
    sz = size(data); 
    out = data(:,:);  
    % adjust the lats
    out = out(end:-1:1,:);
    data = reshape(out,sz);
    % the we don't need to permute again
    flags.permute = false; 
end

% If orig data was data(lat,lon,...), Permute BACK
if ~flags.permute
    data = permute(data,[2,1,3:N-1]);
end 
