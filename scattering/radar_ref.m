%   Returns Radar reflectivity.
%
%
%
% FORMAT  [Z,Ze]=radar_ref(sigma,pnd)
%
% OUT     Z          radar reflectivity [m2/m3] (the actual volume
%                    backscattering cross-section)
%         Ze         radar equivalent reflectivity (defined w.r.t. liquid
%                    water) [mm6/m3] (this unit is used normally)
%
% IN      sigma      backscattering cross-section per particle [m2] (vector)
%         pnd        particle number density     [#/m3] (vector)
%         lambda     wavelength  [m] (scalar)
%         
% History: 2010-02-02 Created by Bengt Rydberg

function [Z,Ze]=radar_ref(sigma,pnd,lambda);


rqre_alltypes(sigma,{@isnumeric,@isvector})

rqre_alltypes(pnd,{@isnumeric,@isvector})

rqre_alltypes(lambda,{@isnumeric,@isscalar})


if length(sigma)~=length(pnd)
 error('mismatch in size between sigma and pnd')
end

pnd=vec2col(pnd);

sigma=vec2col(sigma)';

Z=sigma*pnd;
 
%calculate dielectric factor of water
c=constants('SPEED_OF_LIGHT');
nwater=sqrt(eps_water_liebe93(c/lambda,273.15));
Kwater2=( abs( (nwater.^2-1)./ (nwater.^2+2) ) ).^2;

Ze=lambda^4/Kwater2/pi^5*Z*1e18;

