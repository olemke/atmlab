% N_SURFACE_DUCT   Switches to positive gradient at specified altitude  
%
%    Works as n_linear, but reverses the sign of the gradient at z_break
%
% FORMAT  [n,dndh] = n_surface_duct(params, h)
%
% OUT   n       Refractive index at h
%       dndh    Vertical gradient of n
% IN    params  Function parameters. A vector: [n0,dn/dh,z_break]
%       h       Height

% 2023-04-26   Yongan Zhou and Patrick Eriksson

function [n,dndh] = n_surface_duct(params,h)

    [n,dndh] = deal(zeros(size(h)));
    
    ind = find(h <= params(3)); 
    n(ind) = 1 + params(1) + params(2)*h(ind);
    dndh(ind) = params(2);
    
    ind = find(h > params(3)); 
    n(ind) = (1 + params(1) + params(2)*params(3)) - params(2)*(h(ind) - params(3));
    dndh(ind) = -params(2);
end
