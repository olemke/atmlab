% CHK_LON_LIMITS   Standardised checks of vector giving longitude limits
%
%   The variable *lon_limits* is expected to specificy a longitude range, and
%   must be a sorted vector of length 2. The two elements can be inside
%   [-180,360], but the difference is not allowed to be exceed 360. That is,
%   it is assumed that longitudes spanning [-180,180] or [0,360].
%
%   If atmlab( 'STRICT_ASSERT' ) shall be considered is up to the calling
%   function.
%
% FORMAT chk_lon_limits(lon_limits)
%
% IN   lon_limits   Variable to check.

% 2015-08-20 Patrick Eriksson

function chk_lon_limits(lon_limits)
  
rqre_datatype( lon_limits, @isvector );

if length(lon_limits)~=2;
  error( '*lon_limits* must be a vector of length 2.' );
end
if lon_limits(1) > lon_limits(2);
  error( '*lon_limits* must be sorted.' );
end
if lon_limits(1)<-180 | lon_limits(2)>360
  error( 'Both values in *lon_limits* must be inside -180 to 360.' );
end
if diff(lon_limits)>360
  error( 'The values in *lon_limits* can max differ with 360.' );
end
  