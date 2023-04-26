% N_EXPONENTIAL   Exponentially declining refractive index
%
%    Models the refractive index as n = 1 + n0*exp(-h/hs)
%
% FORMAT  [n,dndh] = n_exponential(params, h)
%
% OUT   n       Refractive index at h
%       dndh    Vertical gradient of n
% IN    params  Function parameters. A vector: [n0,hs]
%       h       Height

% 2023-04-11 Patrick Eriksson

function [n,dndh] = n_exponential(params, h)

N    = params(1) * exp(-h / params(2));
n    = 1 + N;
dndh = -N / params(2);