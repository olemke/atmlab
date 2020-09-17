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
% FORMAT   [za,aa] = zaaa2enu(de,dn,du)
%
% OUT     za   zenith angle
%         aa   azimuth angle
% IN      de   LOS component in e dimension (norm([de,dn,du]) must be 1)
%         dn   LOS component in n dimension
%         du   LOS component in u dimension

% 2020-09-12   Patrick Eriksson

function [za,aa] = enu2zaaa(de,dn,du)

za = acosd( du );
aa = atan2d( de, dn );