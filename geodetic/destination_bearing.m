% DESTINATION_BEARING     Destination given distance and bearing
%
%    Given a start point, initial bearing, and distance, the destination 
%    point  travelling along a great circle arc is calculated.
%
% FORMAT   [lat_end,lon_end] = destination_bearing(lat_start,lon_start,b,d,r)
%        
% OUT   lat_end     Latitude of destination
% OUT   lon_end     Longitude of destination
% IN    lat_start   Latitude of start position.
%       lon_start   Longitude of start position.
%       b           Bearing
%       d           Distance
%       r           Planet radius (common for both points).

% 2018-05-22   Created by Patrick Eriksson.

function [lat_end,lon_end] = destination_bearing(lat_start,lon_start,b,d,r)

% Equations taken from http://www.movable-type.co.uk/scripts/latlong.html

dd = d / r;

cosdd = cos( dd );
sindd = sin( dd );

lat_end = asind( sind(lat_start)*cosdd + cosd(lat_start)*sindd*cosd(b) );

lon_end = lon_start + atan2d( sind(b)*sindd*cosd(lat_start), ...
                              cosdd-sind(lat_start)*sind(lat_end) ); 

