% LIQ_PSD_WANG16 returns PSD for rain
%
%  This function follows Wang et al 2016
%     "Investigation of liquid cloud microphysical properties
%     of deep convective systems: 1. Parameterization
%     raindrop size distribution and its application
%     for stratiform rain estimation"
%  Given rain water water content a PSD is returned.
%  The PSD follows an exponential distribution.
%
% FORMAT psd = liq_psd_wang16(de,rwc)
%
% OUT   psd         Particle size distribution
% IN    de          Size grid, in De
%       rwc         Rain water content
%

% 2016-01-19  Bengt Rydberg

function psd = liq_psd_wang16(de, rwc)

% a and b relates N0 to lambda N0 = a*lambda^b
a = 0.000141;
b = 1.49;
c1 = constants('DENSITY_OF_WATER') * pi / 6;
lambda = (c1 / rwc * a * gamma(4)).^(1 / (4 - b));
N0 = a * lambda^b;
psd = mgd_psd( de, N0*1e8, 0, lambda*1e2, 1 );

