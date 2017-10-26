function [Z,Y,X] = binning_fast(in)
%% BINNING_FAST bins ungridded data onto a grid
%
% Purpose:
% Bins UNGRIDDED DATA to a cell grid using d = in.gridsize. Each bin will contain a
% vector of values for that bin.
%
% The structure elements lon,lat,data (or X,Y,Z) must be the same size, and the function
% will preserve the variable class.
%
% IN
%   in       struct containing:
%               MANDITORY:
%                   Z/data         [data matrix]   of any class. data must
%                   have the same geograhical dimensions as X and Y (same 1st
%                   dimension if x, y are vextors, or same first 2 dimension if
%                   X,Y are two dimensionl., but may have more dimensions e.g.
%                   lvls, seasons, etc. Currently works up to 3 extra dimensions
%
%                   X/lon          [lon matrix]      of any class
%                   Y/lat          [lat matrix]      of any class
%
%                 either:
%                   gridsize     [%f] or [%f %f]   scalar for square
%                                                       scaling. 2 values
%                                                       if you want to have
%                                                       separate lat,lon
%                                                       resolutions
%
%
%
%                             or
%                  newY/newlat        [lat vector]      bin into new lat grid using these as centers
%                  newX/newlon        [lon vector]      bin into new lon grid using these as centers
%
%              OPTIONAL
%                  region        [blcorner,trcorner] (lat1,lon1,lat2,lon2)
%
%
%
%                        If region is given, the function will only bin the data within the
%                        given region. Particularily useful if you have high resolution data
%                        in a region. The default grid domain is assumed to be global
%                        otherwise.
%
%                 lonspace    %f     Optional for lat/lon data to indicate the desired longitude format
%                     lonspace = 360 for lon=0:360,
%                     lonspace = 180 for lon=-180:180
%                     lonspace = 0 do nothing (default)
%
%                        If lonspace is not given, the function automatically picks a format
%                        depending on if there are any longitude values larger than 180
%                        (lon>180). This may be important if your input data does not cover both
%                        hemispheres.
%
%                 countsOnly %f (e.g. true=1), Optional logical for if you only want the number of counts per bin, e.g. to see how
%                        often a certain combination of X-Y happens (numel
%                        per box). 
%
%
%                 counts_matrix ... or counts can be a matrix of counts from a
%                       previous run. If you are only this can save up to
%                       20% computational time if you are calling this
%                       function many times based on the same lat/lon.
%
%
%                        
%
% OUT:
%                   1) Z  ( cell (size(Y,X)) or counts) %data
%                   2) Y  ( vector )          %lat
%                   3) X  ( vector )          %lon
%
% USAGE: [Z,Y,X] = binning_fast(struct('data',data,'lat',lat,'lon',lon...
%                             'newlat',[-80+.5:80-.5],'newlon',[-180+.5:180-.5]))
%
%        or
%         [Z,Y,X] = binning_fast(struct('Z',data,'X',x,'Y',y,'newX',[1:10],'newX',[1:10]))
%
% NOTE:
%       - The output (in input) x-grid and ygrid are grid centers!
%
%       - Including newlon and newlat causes the function to ignore: in.gridsize
%                                                                    in.region
%                                                                    in.lonspace
%
%       - binned_statistics.m is a useful function to get statistics
%         (e.g numel, mean, sum, etc) on the binned data is binned_statistics.
%
% See also: bin, bin_nd, binned_statistics
%
% Created by Oliver Lemke and Salomon Eliasson
% $Id$

default.lonspace = 0; % this is only of intrest if you have an in.gridsize
in = optargs_struct(in,default);

in = check_input(in);

in = outputlatlons(in);

in = regionchop(in);

% setup new GRIDSIZE
d(1) = mean(diff(in.newY));
d(2) = mean(diff(in.newX));

%% assign index value
% This assumes a completely regular grid
Yindex = floor( (in.Y - (min(in.newY)-d(1)/2)) /d(1) ) + 1;
Xindex = floor( (in.X - (min(in.newX)-d(2)/2)) /d(2) ) + 1;

% For slightly irregular grids
% make sure Xindex and Yindex don't exceed maximum or minimum. I.e., putting
% values outside the edges into the edge boxes
Yindex(Yindex>length(in.newY))=length(in.newY);
Xindex(Xindex>length(in.newX))=length(in.newX);
Yindex(Yindex==0)=1;
Xindex(Xindex==0)=1;

%% GET COUNTS
Z = cell(length(in.newY), length(in.newX));

if ~isfield(in,'counts_matrix')
    
    counts = zeros (size(Z), 'uint32');
    
    for i = 1:length(in.X)
        counts(Yindex(i), Xindex(i)) = counts(Yindex(i), Xindex(i)) + 1;
    end
    
    
    if in.countsOnly
        % If you only want the counts you can leave now
        Z = counts;
        return
    end
else
    counts=in.counts_matrix;
end

indata = in.Z;

%% PREALLOCATE DATA

zeroes = zeros ([max(counts(:)), in.size(2:end)], class(indata));
if isvector(in.Z) % no extra dimensions
    for i = 1:size(counts,1)
        for j = 1:size(counts,2)
            Z{i, j} = zeroes(1:counts(i,j));
        end
    end
elseif ismatrix(in.Z) % one extra dimension
    for i = 1:size(counts,1)
        for j = 1:size(counts,2)
            Z{i, j} = zeroes(1:counts(i,j),:);
        end
    end
elseif length(in.size)==3 % two extra dimensions
    for i = 1:size(counts,1)
        for j = 1:size(counts,2)
            Z{i, j} = zeroes(1:counts(i,j),:,:);
        end
    end
elseif length(in.size)==4 % three extra dimensions
    for i = 1:size(counts,1)
        for j = 1:size(counts,2)
            Z{i, j} = zeroes(1:counts(i,j),:,:,:);
        end
    end
end

%% LOOP DATA
if isvector(in.Z) % no extra dimensions
    for i = 1:size(indata,1)
        Z{Yindex(i), Xindex(i)}(counts(Yindex(i), Xindex(i))) = indata(i);
        counts(Yindex(i), Xindex(i)) = counts(Yindex(i), Xindex(i)) - 1;
    end
elseif ismatrix(in.Z) % one extra dimension
    for i = 1:size(indata,1)
        Z{Yindex(i), Xindex(i)}(counts(Yindex(i), Xindex(i)),:) = indata(i,:);
        counts(Yindex(i), Xindex(i)) = counts(Yindex(i), Xindex(i)) - 1;
    end
elseif length(in.size)==3 % two extra dimensions
    for i = 1:size(indata,1)
        Z{Yindex(i), Xindex(i)}(counts(Yindex(i), Xindex(i)),:,:) = indata(i,:,:);
        counts(Yindex(i), Xindex(i)) = counts(Yindex(i), Xindex(i)) - 1;
    end
elseif length(in.size)==4 % three extra dimensions
    for i = 1:size(indata,1)
        Z{Yindex(i), Xindex(i)}(counts(Yindex(i), Xindex(i)),:,:,:) = indata(i,:,:,:);
        counts(Yindex(i), Xindex(i)) = counts(Yindex(i), Xindex(i)) - 1;
    end
end
   
if ( in.gridprovided && (~(in.flags.lon_descend==in.flags.out.lon_descend) || ...
        ~(in.flags.lat_descend==in.flags.out.lat_descend) || ...
        ~(in.flags.lon360==in.flags.out.lon360)))

    % change back the order of the X, Y if I have changed them

    [~,tmp] = standardize_geodata(struct('lon',in.newX,'lat',in.newY,'data',{Z}),...
        catstruct(in.flags,struct('silent',1)));
    X = tmp.lon;
    Y = tmp.lat;
    Z = tmp.data;
else
    X = in.newX;
    Y = in.newY;
end

end
%% Subfunctions
% ||
% VV

function in = check_input(in)

errId = ['atmlab:' mfilename ':badInput'];

%% because we could be gridding non-geographical data
in.lonlat = all(isfield(in,{'lat','lon'}));

%% did you pass a grid?
if any(isfield(in,{'newlon','newlat','newX','newY'}))
    in.gridprovided = true;
    if in.lonspace ~= 0
        logtext(1,'lonspace makes no sense if you pass a grid to map to. Ignoring lonspace...\n')
        in.lonspace = 0;
    end
    if isfield(in,'region')
        logtext(1,'region makes no sense if you pass a grid to map to. Ignoring region...\n')
        in = rmfeild(in,'region');
    end
else
    in.gridprovided=false;
end

%% you want to do more than just count the number hits in a grid
if ~isfield(in,'countsOnly') 
    in.countsOnly = false;
end

%% If your data is geographical
if in.lonlat
    in.X = in.lon;
    in.Y = in.lat;
    in = rmfield(in,{'lon','lat'});
    if ~in.countsOnly
        in.Z = in.data;
        in = rmfield(in,'data');
    end
    if isfield(in,'newlon') % grid provided is geographical
        in.newX = in.newlon;
        in.newY = in.newlat;
        in = rmfield(in,{'newlon','newlat'});

        assert(~(any([in.newX(:)>360;in.newX(:)<-180;in.newY(:)>90;in.newY(:)<-90])),...
            errId,'lat/lon values are unphysical')
    end
end

%% If fields are missing

assert(all(isfield(in,{'Y','X','Z'})) || all(isfield(in,{'Y','X','countsOnly'})),...
    errId,'''lat'',''lon'',''data'' (or ''X'',''Y'',''Z'') are required input fields')

assert(isfield(in,'gridsize') || all(isfield(in,{'newX','newY'})),...
    errId,'Either field ''gridsize'' or fields ''newY/newlat'' and ''newX/newlon'' are required' )

%% Dimension checks
if ~in.countsOnly
    if isequal(numel(in.Z),numel(in.Y),numel(in.X))
        in.Z = in.Z(:); in.Y = in.Y(:); in.X = in.X(:);
    end
    
    assert(isequal(size(in.X,1),size(in.Y,1),size(in.Z,1)),...
        errId, ['data,Y,X must all have the same first dimension. Found: ' ...
        'data %d, Y %d, X %d. It seems your data is not "ungridded" '], size(in.Z, 1), size(in.Y, 1), size(in.X, 1));

    assert(ndims(in.Z)<=4,errId,...
        [mfilename,' currently only supports 3 extra dimensions'])
else
    if isequal(numel(in.Y),numel(in.X))
        in.Y = in.Y(:); in.X = in.X(:);
    end
    assert(isequal(size(in.X,1),size(in.Y,1)),...
        errId, ['data,Y,X must all have the same first dimension. Found: ' ...
        ' Y %d, X %d'], size(in.Y,1), size(in.X, 1));
end



%% Some general warnings
if in.gridprovided
    if ~(max(diff(in.newY))-min(diff(in.newY))<1e-2 && ...
            max(diff(in.newX))-min(diff(in.newX))<1e-2)
        warning(['atmlab:' mfilename, ':WonkyNewgrid'],[...
            'vectors in fields: ''newY'' and ''newX'' are not monotonously spaced. ',...
            'The output grid will be monotonously spaced, ',...
            'based on mean(diff(newY)) and  mean(diff(newX))'])
    end

    if isfield(in,'gridsize')
        warning(errId,'fields ''newX'' and ''newY'' cancel ''gridsize''')
    end

    %%%%%
    % Need to confirm the requested grid with this function

    [in.flags,tmp] = standardize_geodata(struct('lon',in.newX,'lat',in.newY),...
        struct('lon_descend',false,'lat_descend',false,'silent', true));
    in.newX = tmp.lon;
    in.newY = tmp.lat;
end

end

function in = outputlatlons(in)
%% fix the latlons
% Sets up lat lon and adjusts in.X to the requested (if requested)
% longitude regime (0:360 or -180:180)
%
errId = ['atmlab:' mfilename ':badInput'];



if in.lonlat % it is a geographical grid

    if ~any(isfield(in,{'newX','newY'}))
        d = in.gridsize;
        assert(numel(d)<=2,errId,'''gridsize'' should contain 1 or 2 values')
        
        if isscalar(d), d = [d,d]; end
        
        if ~isfield(in,'region')
            % assume global
            if min(in.X)<0
                in.region=[-90,-180,90,180];
            else
                in.region=[-90,0,90,360];
            end
        end
        
        in.newY = in.region(1)+0.5*d(1):d(1):in.region(3)-0.5*d(1);
        in.newX = in.region(2)+0.5*d(2):d(2):in.region(4)-0.5*d(2);
    end

    % the grid might be in 0:360 deg space and the data in -180:180; Match the
    % data to the new grid
    if any(in.newX>180), in.lonspace = 360; end
    
    if in.lonspace==360
        testless = in.X<0;   %logical for any lons < 0
        in.X(testless) = in.X(testless)+360;
        in.f360=true;
    elseif in.lonspace==180
        testmore = in.X>180; %logical for any lons > 180
        in.X(testmore) = in.X(testmore)-360;
        in.f360=false;
    elseif in.lonspace==0
        testmore = in.X>180; %logical for any lons > 180
        in.f360 = any(testmore);
    else
        error(errId,...
            'in.lonspace must be 180, 360 , or 0 (default (do nothing))')
    end
    
    if in.f360 && ~isfield(in,'region')
        in.region = [-90 0 90 360];
    elseif ~in.f360 && ~isfield(in,'region')
        in.region = [-90 -180 90 180];
    end
else
    % If it is not geographical
    if in.gridprovided
        dy  = mean(diff(in.newY)); dx = mean(diff(in.newX));
        dlt = dy/2;  dln = dx/2;
        in.region = [min(in.newY)-dlt,min(in.newX)-dln,max(in.newY)+dlt,max(in.newX)+dln];
    else
        dlt = in.gridsize(1)/2;  dln = in.gridsize(end)/2;
        in.region = [min(in.Y)-dlt,min(in.X)-dln,max(in.Y)+dlt,max(in.X)+dln];
    end
end

end

function in = regionchop(in)
% Get rid of all data outside of region

lt1 = in.Y >= in.region(1);
ln1 = in.X >= in.region(2);
lt2 = in.Y <= in.region(3);
ln2 = in.X <= in.region(4);

index = ln1 & ln2 & lt1 & lt2;


in.Y = in.Y(index);
in.X = in.X(index);

if ~in.countsOnly
    % I need to collapse the data in all cases
    in.size = size(in.Z);
    
    if ~all(index)
        in.Z = in.Z(index,:);
        if length(in.size)>2
            if ~isequal(size(in.Z),in.size)
                % there where more than 2 dimensions in the orginal data
                in.Z = reshape(in.Z,in.size(2:end));
            end
        end
    end
end

end

