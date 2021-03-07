% Creates *antenna_response*
%
% FORMAT G = oi22_antenna_response
%
% OUT   G   Antenna response as a GriddedField4

% 2021-02-07 Patrick Eriksson


function G = oi22_antenna_response

za = -8 : 0.5 : 8;
r = gauss( za, fwhm2si(6), 0 );

G.name      = 'Antenna response function';
G.gridnames = { 'Polarisation', 'Frequency', 'Zenith angle', 'Azimuth angle' };
G.grids     = { {'1'}, 22.2e9, za, 0 };
G.dataname  = 'Response';
G.data(1,1,:,1) = r;
