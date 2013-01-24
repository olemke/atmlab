% SHIFT_LONGITUDES   Ensures that longitudes are inside defined range
%
%    The function shifts longitudes to match expected longitude range.
%    Longitudes are expected to be in range [lonlow,lonhigh], that must
%    be 360 degrees wide.
%
% FORMAT   lon = shift_longitudes(lon,lonlow,lonhigh)
%        
% OUT   lon       Longitudes, restricted to defined range.
% IN    lon       Original longitudes.
%       lonlow    Lower limit for expected longitude range.
%       lonhigh   Upper limit for expected longitude range.

% 2008-03-17   Created by Patrick Eriksson.


function lon = shift_longitudes(lon,varargin)
%
[lonlow,lonhigh] = optargs( varargin, { 0, 360 } );
                                                                         %&%
                                                                         %&%
if lonhigh - lonlow ~= 360                                               %&%
  error(['atmlab:' mfilename], ...
      'Longitude range (lonhigh-lonlow) must be 360 degrees.' );      %&%
end                                                                      %&%

if any(isnan(lon(:)))
    warning(['atmlab:' mfilename], ...
        'Found nans in longitude!');
end

if nanmax(lon(:)) - nanmin(lon(:)) > 360
    error('atmlab:invalid_data', ...
        'Range in longitudes exceeds 360. Differences up to %g found.', ...
        nanmax(lon(:)) - nanmin(lon(:)));
end

ind = find( lon < lonlow );
%
while ~isempty(ind)
  lon(ind) = lon(ind) + 360;
  ind = find( lon < lonlow );
end

ind = find( lon > lonhigh );
%
while ~isempty(ind)
  lon(ind) = lon(ind) - 360;
  ind = find( lon > lonhigh );
end

end
  
