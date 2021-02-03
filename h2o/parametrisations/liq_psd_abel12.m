% LIQ_PSD_ABEL12 returns PSD for rain
%
%  This function follows Abel and Boutle 2012
%  "An improved representation of the raindrop
%   size distribution for single-moment microphysics
%   schemes"
%  Given rain water water content a PSD is returned.
%  The PSD follows an exponential distribution.
%
% FORMAT psd = liq_psd_abel12(de, rwc)
%
% OUT   psd         Particle size distribution
% IN    de          Size grid, in De
%       rwc         Rain water content
%

% 2017-10-09  Bengt Rydberg

function psd = liq_psd_abel12(de, rwc)


% x1 and x2 relates N0 to lambda, i.e N0 = x1*lambda^x2
x1 = 0.22;
x2 = 2.20;
c1 = constants('DENSITY_OF_WATER') * pi / 6;
lambda = (c1 / rwc * x1 * gamma(4)).^(1 / (4 - x2));
N0 = x1 * lambda^x2;
psd = mgd_psd( de, N0, 0, lambda, 1 );

