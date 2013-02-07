function [data,lat,lon] = ungridded2gridded(in,varargin)
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
%                                       in.data or in.field = 'stringname of datafield'                                      
%                                                   e.g. if in.field = 'uth',
%                                                   then in.uth is the data
%                                                   field to grid
%
%                                      data,lat,lon, must be the same size
%
%
%                            usefull extra option
%                                      in.region = [blcorner,trcorner] (lat1,lon1,lat2,lon2)
%                                      This limits the gridding to area of
%                                      interest. If this is not given the
%                                      gridding is global (slower if unnecessary)
%
%               Note:  structure "in" is also passed to binning_fast(). See
%               that function for its options.
% OPT
%
%       grid    cell        containing either
%                           one (degree) scalar or vector to be applies in both
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
%       valid   @fhandle    Throws away all invalid values before apply statistics. This function handle
%                           toggles what you mean by that. To keep all values
%                           valid = ''; By default only keep positive values
%                           i.e., valid = @(x)(x(x>=0))
%
%       noStatistics        If you only want to bin the data and return a 2D
%                           grid cell that contains all the original values
%                           as vectors in the grid boxes, set noStatistics=true;
%                           this also implies that arguments "func" and "valid"
%                           are not used
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
% USAGE  e.g., grid = {[2.5],[1]}; func = @sum; valid = @(x)(x(x>=0));
%        [data,lat,lon] = ungridded2gridded(in,grid,func,valid);    creates rectangular grid with sum per grid of
%                                                                   the values (>0) that were binned into that grid
%
% $Id$
% Salomon Eliasson

errId = ['atmlab:' mfilename,':badInput'];
[grid, func, valid, noStatistics] = optargs(varargin, {{1}, {@mean,@numel},@(x)(x(x>=0)), false});
assert(~isempty(in),errId,'No input')
assert(any(isfield(in,{'data','field'})),errId,'need some way of knowing what "field" to do the gridding on.\nSee doc %s.m\n',mfilename)
if ~isfield(in,'field')
    field = 'data';
else
    field = in.field;
end
assert(isequal(size(in.(field)(:)),size(in.lat(:)),size(in.lon(:))),errId,'data, lat, lon must be the same size')

% ---------------
% Grid
if isscalar(grid{1})
    in.grid = grid{1};
    
elseif isvector(grid)
    in.newlat = grid{1};
    in.newlat = grid{2};
else
    error(errId,'grid is incorrect. See doc %s',mfilename)
end

% ----------------
% BIN THE DATA
logtext(1,'Binning the data\n')
[tmpdata,lat,lon] = binning_fast(catstruct(in,struct('data',in.(field),'lat',in.lat,'lon',in.lon,'gridsize',grid)));

if noStatistics
    % Leave after this if you want
    data = tmpdata;
    return    
end
for F = func
    logtext(1,'Getting the statistic called "%s" within each gridcell\n',func2str(F{1}))
end
% --------------------
% APPLY STATISTICS


if any(cellfun('isempty',tmpdata(:))), 
% If there are empty cells the cell2mat function will fail. Therefore NaNs will
% be put in there place. For this the type of the data is turned to double

  tmpdata = cellfun(@(x)(cast(x,'double')),tmpdata,'uniformOutput',0);
end

out = binned_statistics(tmpdata, func , valid, NaN); % The NaN is to be put in place of empty grids

flds = fieldnames(out);
for i = 1: length(flds)
    % check that the cells only contain scalars
    data.fhandle2fieldname{i} = sprintf('%s = %s',flds{i},func2str(func{i}));
    if any(~cellfun(@isscalar,out.(flds{i})(:)))
        logtext(2,'cell2mat only works on scalars. data.%s will remain a cell\n',flds{i})
        data.(flds{i}) = out.(flds{i});
        continue
    end    
    data.(flds{i}) = cell2mat(out.(flds{i}));
    % Make some key to tie the allocated statistic name to the original function
    % handle

end

end