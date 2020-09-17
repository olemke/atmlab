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
% FORMAT   [de,dn,du] = zaaa2enu(za,aa)
%
% OUT     de   LOS component in e dimension
%         dn   LOS component in n dimension
%         du   LOS component in u dimension
% IN      za   zenith angle
%         aa   azimuth angle

% 2020-09-11   Patrick Eriksson

function [de,dn,du] = zaaa2enu(za,aa)

st = sind( za );

de = st .* sind(aa);
dn = st .* cosd(aa);
du = cosd( za );