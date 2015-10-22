% N_AIR_MWAVES_EARTH   Microwave refractive index for Earth's atmosphere
%
%   This function uses the standard expression for the refractive index of air
%   in the Earth's atmosphere. It considers water vapour, but neglects
%   variation of other minor gases (but those contributions are anyhow normally
%   negligible).
%
%   The expression is: n = 1 + k1*(p-e)/t + k2*e/t + k3*e/t^2 
%
%   The expression is non-dispersive. The values of k1, k2 and k3 are optional
%   arguments. The default values applied here are taken from Bevis et al., GPS
%   meteorology: Mapping ..., JAMC, 1994. More specifically, these value are
%   found in Table 1, listed as "Present study". Note that in ARTS Pa is used
%   for pressure and k1, k2 and k3 must be adjusted accordingly.
%
% FORMAT: n = n_air_mwaves_earth(p,t,h2o[,k1,k2,k3])
%
% OUT: n   Refractive index (total, only real part).
% IN:  p   Pressure.
%      t   Temperature
%      e   Water vapour partial pressure
% OPT: k1  See above. Default is 77.6e-8.
%      k2  See above. Default is 70.4e-8.
%      k3  See above. Default is 3.739e-3.

% 2015-10-22  Patrick Eriksson, renamed a function called n_air_thayer and
%             polished up this version.

function n = n_air_mwawes_earth(p,t,e,varargin)
%
[k1,k2,k3] = optargs( varargin, { 77.6e-8, 70.4e-8, 3.739e-3 } );

rqre_element_math( p, t );
rqre_element_math( p, e );

n = 1 + ( k1 * ( p - e ) + k2 * e ) ./ t + k3 * e ./ (t.^2);
