%------------------------------------------------------------------------
% NAME:    geomztan2za
%
%          Converts a vector of geometrical tangent altitudes to zenith 
%          angles.
%
% FORMAT:  za = geomztan2za(r_geoid,z_plat,z_tan)
%
% RETURN:  za        Zenith angles corresponding to z_tan.
% IN:      r_geoid   Geoid radius.
%          z_plat    Platform altitude (above geoid).
%          z_tan     Geometrical tangent altitudes. 
%------------------------------------------------------------------------

% HISTORY: 2004-09-11   Adapted from AMI function geomtan2za
%          2000.12.18   Created by Patrick Eriksson. 


function za = geomztan2za(r_geoid,z_plat,z_tan)


za = (pi - asin((r_geoid+z_tan)./(r_geoid+z_plat)) ) * 180/pi;
