% FOCUSING2D   Focusing factor for circular 2D atmosphere
%
%    Without refraction the focusing factor is 1. Defocusing comes out as a
%    value of f below 1.
%
% FORMAT  f = focusing2d(S, P)
%
% OUT   f   Focusing factor
% IN    P   Array of path points
%       S   Setting structure

% 2023-04-11 Patrick Eriksson

function f = focusing2d(S, P)

% Shift in theta hard-coded
dtheta = 0.002;

% Length of path
l      = P(end).length;

% Shift upwards and downwards
P1 = raytrace2d(S, ...
                P(1).r - S.r_planet, ...
                P(1).theta - dtheta, ...
                1.01 * l);
P1 = crop_path_length(P1, P(end).length);

P2 = raytrace2d(S, ...
                P(1).r - S.r_planet, ...
                P(1).theta + dtheta, ...
                1.01 * l);
P2 = crop_path_length(P2, P(end).length);

% Focusing factor
f = (pi * dtheta * l / 90) / ...
    hypot(P1(end).x - P2(end).x, P1(end).y - P2(end).y);
