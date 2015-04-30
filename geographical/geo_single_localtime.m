function data = geo_single_localtime(utcvec,localtime,data,lon,lat,method)
% GEO_SINGLE_LOCALTIME Interpolates data to a specific local time
%
% IN
%     utcvec      [%f,...]              UTC values covering a day, e.g. 0:3:21
%     localtime   %f                    scalar local time as a decimal number,
%                                       e.g. 1.5 = 01:30AM
%     data        data(lon,...,time)    data matrix with the dimensions
%                                       data(lat,lon,...,time)
%                                       or
%                                       data(lon,lat,...,time)
%     lon         [%f,...]              longitudes vector
%     lat         [%f,...]              latitudes vector (needed for function
%                                                         standardize_geodata)
%     method      %s                    The method interp1 will use. It can be
%                                       one of 'nearest', 'linear' (default),
%                                       'spline' or 'cubic'
%                                       
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
% USAGE: data = geo_single_localtime(utcvec,localtime,data,lon,lat,method)
%
% Created by Salomon Eliasson 
% Modified by Marston Johnston
%
% $Id$

if ~exist('method','var')
    method = 'linear';
end

N = ndims(data);

assert( ( isequal(size(data,1),length(lon)) || isequal(size(data,2),length(lon))) && ...
    isequal(size(data,N),length(utcvec)),...
    ['atmlab:' mfilename ':badInput'],'See help')

assert(ismember(method,{'nearest','linear','cubic','spline'}),...
['atmlab:' mfilename ':badInput'],'method: "%s" not valid',method)

% INTERNALLY make lons -180:180 and adjust data accordingly
sortoptions = struct('dimorder','latlon');
[flags,tmp] = standardize_geodata(struct('lat',lat,'lon',lon,'data',data),sortoptions); %#ok<ASGLU>

lat=tmp.lat;
lon=tmp.lon;
data=tmp.data;

% Get the SIZE of the original data
sz = size(data);

% PERMUTE so that the data(time,lon,lat...). % data(lat,lon,...) is ensured
% via the dimorder input to standardize function
data = permute(data,[N,2,1,3:N-1]);

% COLLAPSE it to data(time,lon,lat*etc)
data = data(:,:,:);

% locally make utc CYCLIC (covering the whole day)
switch method
    case {'nearest','linear'}, n=0;
    case 'cubic', n=1;
    case'spline', n=2;
end

assert(n < length(utcvec),['atmlab:' mfilename ':badInput'],...
    'method: "%s" requires utcvec to have at least %d values',method,n+1)
if n ~= -1
    utcvec = [utcvec(end-n:end)-24, utcvec utcvec(1:n+1)+24];
    data = [data(end-n:end,:,:); data; data(1:n+1,:,:)];
end

% get the EQUIVALENT utc timefor each longitude for the local time
utc0 = mod(localtime - 24/360 * lon, 24);

% INTERPOLATE
out = zeros([length(lon),size(data,3)],class(data));
for i = 1:size(data,2) % longitude in the first dimension
    D = squeeze(data(:,i,:));
    out(i,:) = interp1(utcvec, D, utc0(i), method); %[lon,lat*etc]
end


% RECONSTRUCT collapsed dimensions [lon,lat,...]
data = reshape(out,[size(out,1),sz([1,3:N-1])]);

