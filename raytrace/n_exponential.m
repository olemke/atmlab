% N_EXPONENTIAL   Exponentially declining refractive index
%
%    Models the refractive index as n = 1 + n0*exp(-h/hs)
%
% FORMAT  n = n_exponential(params, h)
%
% OUT   n       Refractive index at h
% IN    params  Function parameters. A vector: [n0,hs]
%       h       Height

% 2023-04-11 Patrick Eriksson

function n = n_exponential(params, h)

n = 1 + params(1) * exp(-h/params(2));