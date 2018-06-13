% SET_LON_LIMITS  Determines longitude range that brackets the data
%
%    The function aims at finding the smallest longitude range that covers
%    the data points (*lons*). The input data points can be defined
%    following  either [-180,180] or [0,360].
%
%    If the data points span more than 180 degrees, a 360 degree range is
%    always returned.
%
%    The output *lon_limits* ae inside the range [-180,360]. If
%    *prefer0to360* is set to true, the limits are kept inside [0,369] when
%    possible. But note that e.g. lons=[-1 1] will give lon_limits=[-1 1].
%
%    With *prefer0to360* set to false, the target range is instead
%    [-180,180]. lons=[-1 1] will here also give lon_limits=[-1 1], but e.g.
%    lons=[-179 179] gives lon_limits=[179 181].
%
%    The second and third output argument are set to -180/0 or 180/360,
%    respectively, dependent on what longitude range that has been selected.
%    These arguments can be used as input to *shift_longitudes*.
%
% FORMAT   [lon_limits,lonlow,lonhigh] = set_lon_limits( lons [,prefer0to360,margin] )
%        
% OUT   lon_limits   Found longitude limits
%       lonlow       Matches the OPT of *shift_longitudes* with the same name.
%       lonhigh      Matches the OPT of *shift_longitudes* with the same name.
% IN    lons         Longitude points
% OPT   prefer0to360 See above. Default is true.
%       margin       Add extra margin, in each end. Default is 0.

% 2018-06-01   Created by Patrick Eriksson.


function [lon_limits,lonlow,lonhigh] = set_lon_limits(lons,varargin)
%
[prefer0to360,margin] = optargs( varargin, { true, 0 } );

lon_try     = shift_longitudes( lons(:), 0, 360 );
lon_limits1 = [ min(lon_try)-margin max(lon_try)+margin ];

lon_try     = shift_longitudes( lon_try, -180, 180 );
lon_limits2 = [ min(lon_try)-margin max(lon_try)+margin ];

if diff(lon_limits1) <= diff(lon_limits2)
  lon_limits = lon_limits1;
  [lonlow,lonhigh] = deal( 0, 360 );
else  
  lon_limits = lon_limits2;
  [lonlow,lonhigh] = deal( -180, 180 );
end    

if diff(lon_limits) > 180 
  if prefer0to360
    [lonlow,lonhigh] = deal( 0, 360 );
  else
    [lonlow,lonhigh] = deal( -180, 180 );
  end
  lon_limits = [ lonlow lonhigh ];
else
  if prefer0to360  &  lon_limits(2) <= 0
    lon_limits = lon_limits + 360;
    [lonlow,lonhigh] = deal( 0, 360 );
  elseif ~prefer0to360  &  lon_limits(1) > 180
    lon_limits = lon_limits - 360;    
    [lonlow,lonhigh] = deal( -180, 180 );
  end

end
