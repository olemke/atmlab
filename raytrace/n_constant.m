% N_CONSTANT   Constant refractive index
%
%    Models the refractive index as n = 1 + n0
%
% FORMAT  [n,dndh] = n_constant(params, h)
%
% OUT   n       Refractive index at h
%       dndh    Vertical gradient of n
% IN    params  Function parameters. A vector: [n0]
%       h       Height

% 2023-04-11 Patrick Eriksson

function [n,dndh] = n_constant(params, h)

n    = repmat(1 + params(1), size(h));
dndh = zeros(size(h));