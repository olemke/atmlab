% CHK_LAT_LIMITS   Standardised checks of vector giving latitude limits
%
%   The variable *lat_limits* is expected to specificy a latitude range, and
%   must be a vector of length 2, sorted with both values inside [-90,90].
%
%   If atmlab( 'STRICT_ASSERT' ) shall be considered is up to the calling
%   function.
%
% FORMAT chk_lat_limits(lat_limits)
%
% IN   lat_limits   Variable to check.

% 2015-08-20 Patrick Eriksson

function chk_lat_limits(lat_limits)
  
rqre_datatype( lat_limits, @isvector );

if length(lat_limits)~=2;
  error( '*lat_limits* must be a vector of length 2.' );
end
if lat_limits(1) > lat_limits(2);
  error( '*lat_limits* must be sorted.' );
end
if lat_limits(1)<-90 | lat_limits(2)>90
  error( 'Both values in *lat_limits* must be inside -90 to 90.' );
end
  