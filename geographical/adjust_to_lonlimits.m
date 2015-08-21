% ADJUST_TO_LONLIMITS   Determines if [-180,180] or [0,360] used for lons
%
%   Determines which longitude system is used, based, on values in
%   *lon_limits*. That is, if longitudes are expected to be inside
%   [-180,180] or [0,360]. Output *lon* are the input *lon0* adjusted to
%   found range.  For example:
%     >> [lon,i] = adjust_to_lonlimits([-33 -4  55],[0,350])   
%   gives
%     lon = [ 327 -4 55 ]  and  i = [ 1 0 1 ] 
%
% FORMAT [lons,i] = adjust_to_lonlimits(lons0,lon_limits)
%
% OUT   lons          Adjusted longitudes. 
%       i             Logical, true if longitude is inside inside *lon_limits*.
% IN    lons0         A set of longitudes.
%       lon_limits    Longitude limits. See *chk_lon_limits* for constrain
%                     on this argument.

% 2015-08-20  Patrick Eriksson

function [lons,i] = adjust_to_lonlimits(lons0,lon_limits)


if atmlab( 'STRICT_ASSERT' )
  chk_lon_limits( lon_limits );
end
  
  

%- Just inside overlap region [0,180]?
if lon_limits(1) >= 0  &  lon_limits(2) <= 180
  lons = lons0;  
% [-180,180]
elseif lon_limits(1) < 0
  lons = shift_longitudes( lons0, -180, 180 );
% [0,360]
else
  lons = shift_longitudes( lons0, 0, 360 );
end

%- Find hits
%
i = lons >= lon_limits(1)  &  lons <= lon_limits(2);

