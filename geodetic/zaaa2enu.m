% ZAAA2ENU   Converts viewing angles to east-north-up
%
%   Converts local zenith and azimuth line-of-sight (LOS) angles to unit
%   vectors in the ENU system (East,North,Up). The LOS angles are defined as in
%   ARTS:
%         za    aa
%         90    0   points towards north
%         90    90  points towards east
%         0     aa  points up 
%
% FORMAT   [dx,dy,dz] = zaaa2enu(za,aa)
%
% OUT     dx   LOS component in x dimension
%         dy   LOS component in y dimension
%         dz   LOS component in z dimension
% IN      za   zenith angle
%         aa   azimuth angle

% 2020-09-11   Patrick Eriksson

function [dx,dy,dz] = zaaa2enu(za,aa)

st = sind( za );

dx = st .* sind(aa);
dy = st .* cosd(aa);
dz = cosd( za );