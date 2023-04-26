% N_LINEAR   Linear varying refractive index
%
%    Models the refractive index as n = 1 + n0 + dn/dh*h
%
%    Standard conditions should roughly match [320e-6, -39e9].
%
% FORMAT  [n,dndh] = n_linear(params, h)
%
% OUT   n       Refractive index at h
%       dndh    Vertical gradient of n
% IN    params  Function parameters. A vector: [n0,dn/dh]
%       h       Height

% 2023-04-11 Patrick Eriksson

function [n,dndh] = n_linear(params, h)

n = 1 + params(1) + params(2)*h;

dndh = repmat(params(2), size(h));