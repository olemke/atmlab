% MOLECULAR_SCATCOEF   Molecular scattering attenuation due to scattering
%
%    Calculates the attenuation coefficient for molecular Rayleigh scattering.
%
%    Work in progress!!! Results agree failrly well with table values in
%    Tomasi et al, but seem to be a bit low in the UV. Due to water vapour
%    is neglected?
%
% FORMAT  k = molecular_scatcoef(wlength,p,t)
%
% OUT  k         Attenuation coefficient [1/m]
% IN   wlength   Wavelength(s)
%      p         Pressure(s)
%      t         Temperature(s)

% 2020-09-22   Patrick Eriksson

function k = molecular_scatcoef(wlength,p,t)

% n-1 according to Eq 8 in Tomasi et al., Improved algorithm for calculations
% of Rayleigh-scattering optical depth in standard atmospheres, Applied optics,
% 2005.
%
la2 = (wlength*1e6).^2;
nm1 = 1e-8*( 5791817./(238.0185-la2) + 167909./(57.362-la2) );

% Scale to air density according to Eq 11 in Tomase et al (assuming
% completely dry air)
%
p0  = 1013e2;
t0  = 288.15;
N   = vmr2nd(1,p,t);  % m^-3 
%
n   = 1 + N./vmr2nd(1,p0,t0)*nm1;

% Eq 1 in Thalman et al., Rayleigh scattering cross-section measurements 
% of nitrogen, argon, oxygen and air, JQSRT, 2005.
% (Eq 4 in Tomasi et al looks identical but has wavelength instead of
% wavenumber, and a scale factor must be misiing!)
%
N       = N * 1e-6;  % Now cm^-3
n2      = n.^2;
wnumber = 0.01/wlength;
sigma   = (24*pi^3./(N.*N)) .* (wnumber.^4 .* ((n2-1)./(n2+2)).^2); % cm^2

% Scattering coefficent (e.g. Eq 2 in Tomasi et al., 1e2 to convert from cm^-1
% to m^-1)
%
k = (1e2*N) .* sigma;