function [data,lat,lon] = ungridded2gridded(in,opt)
%% ungridded2gridded
%
% PURPOSE
%       Puts statistics of ungridded data onto a grid. e.g by default the nan-removed mean
%       and numel are given for each user defined grid box
%
%
% IN
%       in      struct      containing 
%                                       in.lat 
%                                       in.lon
%                                       in.(field)
%                                       e.g. if in.field = 'uth',
%                                       then in.uth is the data
%                                       field to grid
%
%                                       data,lat,lon, must be the same size
%
%
%
%      opt   structure 
%
%       field   string      'stringname of datafield'
%
%       grid    cell        containing either
%                           one (degree) scalar or vector to be applied in both
%                           directions {[%f]} or {[%f %f]}
%                                              or
%                           two (degree) scalars or vectors to be appllied
%                           to the lat and lon dimensions
%                             {[latdim],[londim]} = {[%f],[%f]} or {[%f %f],[%f %f]}
%
%                           Default grid is a 1x1 deg
%
%       func    {@fhandle/s}    Any function handle for the statistic you want
%                               to calculate within each grid box. default =
%                               {@mean,@numel}
%
%       valid   @fhandle    Throws away all invalid values before apply
%                           statistics. This function handle 
%                           toggles what you mean by "valid". To keep all values
%                           valid = ''; By default only keep positive values
%                           i.e., valid = @(x)(x(x>=0))
%         
%
%       noStatistics        If you only want to bin the data and return a 2D
%                           grid cell that contains all the original values
%                           as vectors in the grid boxes, set noStatistics=true;
%                           this also implies that arguments "func" and "valid"
%                           are not used
%
%      region               [blcorner,trcorner] (lat1,lon1,lat2,lon2)
%                           This limits the gridding to area of
%                           interest. If this is not given the
%                           gridding is global (slower if unnecessary)
%
%      replace              val (e.g., NaN) 
%                           replace empty cells with in.replace
%
% OUT   
%      
%      data                Structure containing the gridded statistics, and the
%                          corresponding lat lons.
%                          OR
%                          if noStatistic = true; data is a cell grid.
%      lat
%      lon                 lat and lon are also included in the data structure
%                          (if it is a structure)
%
%
% USAGE  e.g., [data,lat,lon] = ungridded2gridded(in,struct('field','something','grid',1,'func',@sum,'valid',@(x)(x(x>0)));
%              %creates rectangular grid with sum per grid of the values (>0) that were binned into that grid
%
% $Id$
% Salomon Eliasson

errId = ['atmlab:' mfilename,':badInput'];

if nargin==1, opt = struct(); end

assert(any([isfield(in,'data'),isfield(opt,'field')]),...
    errId,'need some way of knowing what "field" to do the gridding on.\nSee doc %s.m\n',mfilename)


default.grid            = {1};
default.func            = {@mean,@numel};
default.valid           = @(x)(x(x>=0));
default.noStatistics    = false;
default.field           = 'data';
default.replace         = NaN;
opt = optargs_struct(opt,default);

if ~iscell(opt.func), opt.func={opt.func}; end

assert(isequal(size(in.(opt.field)(:)),size(in.lat(:)),size(in.lon(:))),...
        errId,'data, lat, lon must be the same size')

% ---------------
% Grid
if isscalar(opt.grid{1})
    in.gridsize = opt.grid{1};
    
elseif isvector(grid)
    in.newlat = opt.grid{1};
    in.newlat = opt.grid{2};
else
    error(errId,'grid is incorrect. See doc %s',mfilename)
end

% ----------------
% BIN THE DATA
logtext(1,'Binning the data\n')
[tmpdata,lat,lon] = binning_fast(catstruct(in,struct('data',in.(opt.field))));

if opt.noStatistics
    % Leave after this if you want
    data = tmpdata;
    return    
end
data.lat = lat;
data.lon = lon;
for F = opt.func
    logtext(1,'Getting the statistic called "%s" within each gridcell\n',func2str(F{1}))
end
% --------------------
% APPLY STATISTICS


if any(cellfun('isempty',tmpdata(:))), 
% If there are empty cells the cell2mat function will fail. Therefore NaNs will
% be put in there place. For this the type of the data is turned to double

  tmpdata = cellfun(@(x)(cast(x,'double')),tmpdata,'uniformOutput',0);
end

out = binned_statistics(tmpdata, opt.func , opt.valid, opt.replace); % The NaN is to be put in place of empty grids

flds = fieldnames(out);
for i = 1: length(flds)
    % check that the cells only contain scalars
    data.fhandle2fieldname{i} = sprintf('%s = %s',flds{i},func2str(opt.func{i}));
    if any(~cellfun(@isscalar,out.(flds{i})(:)))
        logtext(atmlab('OUT'),'Not doing cell2mat(x) since it only works on scalars. data.%s will remain a cell\n',flds{i})
        data.(flds{i}) = out.(flds{i});
        continue
    end    
    data.(flds{i}) = cell2mat(out.(flds{i}));
    % Make some key to tie the allocated statistic name to the original function
    % handle

end

end