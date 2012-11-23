function [data,lat,lon] = ungridded2gridded(in,grid,func)
%% ungridded2gridded
%
%
%
%
% IN
%       in      struct      containing in.(in.field); assumed default = 'data'
%                                      in.lat 
%                                      in.lon
%                                      default field = 'data'.
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
%
%       func    @fhandle    any function handle for the statistic you want
%                           to calculate within each grid box. default = @nanmeam
%
%
% OUT   
%       data, lat, lon              gridded according to 'grid' (degrees)
%
%
% USAGE
%        [data,lat,lon] = ungridded2gridded(in,{[2.5],[1]}); % creates rectangular grid 
%
% $Id$
% Salomon Eliasson

errId = ['atmlab:' mfilename,':badInput'];
assert(any(isfield(in,{'data','field'})),errId,'need some way of knowing what "field" to do the gridding on.\nSee doc %s.m\n',mfilename)
if ~isfield(in,'field')
    field = 'data';
else
    field = in.field;
end
assert(isequal(size(in.(field)(:)),size(in.lat(:)),size(in.lon(:))),errId,'data, lat, lon must be the same size')
if nargin<2
    grid = 1; % default = 1deg
end
if nargin<3
    func = @nanmean;
end

if isscalar(grid{1})
    in.grid = grid{1};
    
elseif isvector(grid)
    in.newlat = grid{1};
    in.newlat = grid{2};
else
    error(errId,'grid is incorrect. See doc %s',mfilename)
end

logtext(1,'Binning the data\n')
[tmpdata,lat,lon] = binning_fast(catstruct(in,struct('data',in.(field),'lat',in.lat,'lon',in.lon,'gridsize',grid)));
logtext(1,'Getting the "%s"-statistic within each gridcell\n',func2str(func))
out = binned_statistics(tmpdata, {func}, @(x)(x(x>=0)));

if isfield(out,'statistic1')
    data = cell2mat(out.statistic1);
else
    data = cell2mat(out.(func2str(func)));
end

end