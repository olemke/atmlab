% N_CONSTANT   Constant refractive index
%
%    Models the refractive index as n = 1 + n0
%
% FORMAT  n = n_constant(params, h)
%
% OUT   n       Refractive index at h
% IN    params  Function parameters. A vector: [n0]
%       h       Height

% 2023-04-11 Patrick Eriksson

function n = n_constant(params, h)

n = 1 + params(1);