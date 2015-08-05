% INVCM2HZ   Conversion of wavenumbers to frequency
%
% FORMAT f = invcm2hz(v)
%
% OUT   f   Frequency (Hz).
% IN    v   Wavenumber (cm-1).

% 2015-08-05 Patrick Eriksson

function f = invcm2hz(v)
  
% Conversion factor hard-coded for efficiency (instead of using SPEED_OF_LIGHT)
  
f = 29.9792458e9 * v;