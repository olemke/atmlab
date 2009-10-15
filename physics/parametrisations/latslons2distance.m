% LATSLONS2DISTANCE   Approximative distance between two positions
%
%   The distance is calculated assuming a spherical Earth and that the two
%   positions are at surface level. The angular difference between the two
%   positions is converted to a distance following the fact that a north-south
%   movement of 1 degree corresponds to 60 nautical miles.
%
% FORMAT   l = latslons2distance( lat1, lon1, lat2, lon2 )
%        
% OUT   l
% IN    lat1   Latitude for position 1
%       lon1   Longitude for position 1
%       lat2   Latitude for position 2
%       lon2   Longitude for position 2

% 2009-10-15   Created by Patrick Eriksson.

function l = latslons2distance( lat1, lon1, lat2, lon2 )
  
[dx1,dy1,dz1] = arts_zaaa2cart( 90-lat1, lon1 );
[dx2,dy2,dz2] = arts_zaaa2cart( 90-lat2, lon2 );

l = ( constants('NAUTICAL_MILE') * 60 * constants('RAD2DEG') ) * ...
                                                acos( dx1*dx2+dy1*dy2+dz1*dz2 );
