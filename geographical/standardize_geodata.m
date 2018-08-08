function [flags,out] = standardize_geodata(in,options)
%% STANDARDIZE_GEODATA sort and rearrange lat,lon, data to a format of your liking.
%
%                  For gridded data.
%
%  PURPOSE  Make sure the lat lon [data] are sorted in a way of your choosing.
%  the default behaviour is to do nothing, but just report how the data is
%  arrange. If you want to change the arrangement, includen your choice in 'opt'
%
%
%  IN       in.lat      vector
%           in.lon      vector
%  OPT      in.data     matrix      dims = (lat,lon,...) or (lon,lat,...)
%           options  structure
%                       some options including what you want to do to
%                       homogenise, basically what features you want to allow.
%
%                    dimorder    = 'lonlat'; % Order the data as (lon,lat,....);
%                    lon_descend = true; % order the longitudes in descending order
%                    lat_descend = true; % order the latitudes in descending order
%                    lon360      = true; % fit longitudes (and data if given) to 0:360 regime
%                    dublicate   = true % allow duplicate values (repeat longitudes e.g. at -180 and 180)
%                    silent      = false; % don't be quiet about it
%
%  OUT
%           flags     struct     A structure of flags to indicate how your data is arranged
%           out       struct     Equivalent to 'in', but with the data order as
%                                requested
%
% NOTE: 1) If lat and lon are the same length the first dimesion of data is
%       assumed to correspond to lat.
%
% USAGE:    [flags,out] = standardize_geodata(in,[options])
%
% created by Salomon Eliasson
% $Id$

% -------    CHECK for errors
errID = ['atmlab:' mfilename ':badInput'];
dexist = isfield(in,'data');

lat = in.lat;
lon = in.lon;
if dexist, data = in.data; end

assert(isvector(lat) && isvector(lon),errID,'lat and lons must be vectors')

assert(all(lat>=-90 & lat<=90) && all(lon>=-180 & lon<=360),...
    errID,'Lats and lons must have physical values')

assert(all(lon(2:end)<lon(1:end-1)) || all(lon(2:end)>lon(1:end-1)),...
    errID,'Longitudes must be ordered ascending or descending');

assert(all(lat(2:end)<lat(1:end-1)) || all(lat(2:end)>lat(1:end-1)),...
    errID,'Latitudes must be ordered ascending or descending');

% --------  Check the state of the input data
if dexist
    
    sz = size(data);
    %undesired dimensions
    if (length(lon)==sz(2) && length(lat)==sz(1)) && ...
            length(lat) ~= length(lon)
        
        flags.dimorder = 'latlon';
        
    elseif (length(lon)==sz(1) && length(lat)==sz(2)) && ...
            length(lat) ~= length(lon)
        
        flags.dimorder = 'lonlat';
        
    elseif length(lat) ~= length(lon)
        
        flags.dimorder = 'undetermined';
    elseif sz(1)==sz(2)
        
        fprintf('cannot determine dim order, Assumin dim order is lonlat')
        flags.dimorder = 'lonlat';
    end
    
end

flags.lon_descend = all(lon(2:end)<lon(1:end-1));

flags.lat_descend = all(lat(2:end)<lat(1:end-1));

flags.lon360 = any(lon > 180);

flags.duplicate = (length(unique(lon)) ~= length(lon)) | ...
    (any(lon==-180) & any(lon ==180)) | ...
    (any(lon==0) & any(lon ==360));

% SET the defaults
if ~exist('options','var'); options = struct(); end

% default should be to do nothing
if dexist
    default.dimorder    = flags.dimorder; % Order the data as (lat,lon,....); or else do nothing
end
default.lon_descend = flags.lon_descend; % allow descending order of longitudes
default.lat_descend = flags.lat_descend; % allow descending order of latitudes
default.lon360      = flags.lon360; % allow longitudes go from 0:360 (as opposed to -180:180) globally
default.duplicate   = flags.duplicate; % allow duplicate values (repeat longitudes e.g. at -180 and 180)
default.silent      = false;
options = optargs_struct(options,default);

% --------  Do the work
s=~options.silent;

% PERMUTE data so that dimensions are data(lat,lon) or data(lon,lat)
if dexist
    if (strcmp(options.dimorder,'latlon') && strcmp(flags.dimorder,'lonlat')) ||...
            (strcmp(options.dimorder,'lonlat') && strcmp(flags.dimorder,'latlon'))
        
        x = 1:ndims(data);
        x(1)=2;x(2)=1;
        data = permute(data,x);
        flags.out.dimorder = options.dimorder;
        
        if s,logtext(1,'Swapped the 1st and 2nd dimensions\n');end
    else
        flags.out.dimorder = flags.dimorder;
    end
end

% If any of the following flags are true the data matrix will be flattened
% on 3rd dimesion. A reshape at the end of this function will unflatten the
% data again later

% LONS ascending or descending
if (flags.lon_descend && ~options.lon_descend) || ...
        (~flags.lon_descend && options.lon_descend)
    
    lon = lon(end:-1:1);
    
    if dexist
        if strcmp(flags.dimorder,'latlon')
            data = data(:,end:-1:1,:);
        else
            data = data(end:-1:1,:,:);
        end
    end
    flags.out.lon_descend = options.lon_descend;
    if s, logtext(1,'Changed the order of longitudes\n'); end
else
    flags.out.lon_descend = flags.lon_descend;
end

% LATS ascending or descending
if (flags.lat_descend && ~options.lat_descend) || ...
        (~flags.lat_descend && options.lat_descend)
    
    lat = lat(end:-1:1);
    
    if dexist
        if strcmp(flags.out.dimorder,'latlon')
            data = data(end:-1:1,:,:);
        else
            data = data(:,end:-1:1,:);
        end
    end
    flags.out.lat_descend = options.lat_descend;
    if s, logtext(atmlab('OUT'),'Changed the order of latitudes\n'); end
else
    flags.out.lat_descend = flags.lat_descend;
end

% LONGITUDES -180:180 or 0:360 regime
if (flags.lon360 && ~options.lon360) || ...
        (~flags.lon360 && options.lon360)
    
    if flags.lon360 && ~options.lon360
        lon = lon-(lon > 180)*360;
    elseif ~flags.lon360 && options.lon360
        lon = lon+(lon<0)*360;
    end
    [lon,lnindex] = sort(lon);
    
    if dexist
        if strcmp(flags.out.dimorder,'latlon')
            data = data(:,lnindex,:);
        else
            data = data(lnindex,:,:);
        end
    end
    flags.out.lon360 = options.lon360;
    if s, logtext(1,'Changed the longitude regime\n'); end
else
    flags.out.lon360 = flags.lon360;
end


% DUPLICATE data
% Need to remove duplicate data at zeros and instead introduce duplicate
% data at lon = -180 and 180 if either -180 or 180 are amongst the lon
% values (if so).

% Since, by removing duplicate data, I change the size of the lon vector
% and data matrix which is undesireable. By adding either -180 or 180 as
% duplicates the sizes remain the same. The caveat is that if your original lons
% contain both 0 and 360 (duplicate), but don't contain the longitude: 180,
% the lon vector and data matrix will be shortened.

if flags.duplicate && ~options.duplicate
    [~,index] = unique(lon);
    lon = lon(index);
    sz1 = size(lon,1)==length(lon);
    
    if dexist
        if strcmp(flags.out.dimorder,'latlon')
            data = data(:,index,:);
        else
            data = data(index,:,:);
        end
    end
    if lon(end)==180
        
        if sz1
            lon = [-180; lon];
            if dexist
                if strcmp(flags.out.dimorder,'latlon')
                    data = [data(:,end,:); data];
                else
                    data = [data(end,:,:); data];
                end
            end
        else
            
            lon = [-180 lon];
            if dexist
                if strcmp(flags.out.dimorder,'latlon')
                    data = [data(:,end,:) data];
                else
                    data = [data(end,:,:) data];
                end
            end
        end
    else
        warning(sprintf('atmlab:%s:ChangedDataDimensions',mfilename),...
            'Duplicate lons removed changing the size of the lon vector (and data)')
    end
    flags.out.duplicate = options.duplicate;
    if s, logtext(1,'checked for duplicate data and removed if so\n'); end
else
    flags.out.duplicate = flags.duplicate;
end

if dexist
    data = reshape(data,[size(data,1),size(data,2),sz(3:end)]);
end

out.lat = lat;
out.lon = lon;
if dexist, out.data = data; end