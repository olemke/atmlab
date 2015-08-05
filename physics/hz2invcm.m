% HZ2INVCM   Conversion of frequency to wavenumbers
%
% FORMAT v = hz2invcm(f)
%
% OUT   v   Wavenumber (cm-1).
% IN    f   Frequency (Hz).

% 2015-08-05 Patrick Eriksson

function v = hz2invcm(f)
  
% Conversion factor hard-coded for efficiency (instead of using SPEED_OF_LIGHT)
  
v = f / 29.9792458e9;