function lon = convert_360_180(lon)
% Convert [0, 360] based to [-180, 180] based longitudes
%
% newlon = convert_360_180(oldlon)
%
% Issues an error if any oldlon is not in [0, 360].

% $Id$

rqre_in_range(lon, 0, 360);
oor = lon>180;
lon(oor) = lon(oor) - 360;

end
