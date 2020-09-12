% ENU2ZAAA   Converts  east-north-up to viewing angles
%
%   Converts unit vectors in the ENU system (East,North,Up) to local  
%   zenith and azimuth line-of-sight (LOS) angles to . The LOS angles are 
%   defined as in ARTS:
%         za    aa
%         90    0   points towards north
%         90    90  points towards east
%         0     aa  points up 
%
%   Note that it does not matter how "up" here is defined, can be e.g. both
%   geocentric and geodetic. 
%
% FORMAT   [za,aa] = zaaa2enu(dx,dy,dz)
%
% OUT     za   zenith angle
%         aa   azimuth angle
% IN      dx   LOS component in x dimension (norm([dx,dy,dz]) must be 1)
%         dy   LOS component in y dimension
%         dz   LOS component in z dimension

% 2020-09-12   Patrick Eriksson

function [za,aa] = enu2zaaa(dx,dy,dz)

za = acosd( dz );
aa = atan2d( dx, dy );