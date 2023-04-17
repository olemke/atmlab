% GEOM_LINK   Determines a geomtrical link 
%
%    Calculates the angle and distance from start/transmitter to reach a 
%    target/reciever point.
%
% FORMAT  [theta, l, alpha] = geom_link(S, h_start, h_target, l_target)
%
% OUT   theta      Zenith angle at transmitter
%       l          Geometrical length between transmitter and reciever
%       alpha      Angular distance to target/reciever
% IN    S          Setting structure
%       h_start    Start/transmitter altitude
%       h_target   Target/reciever altitude
%       l_target   Distance at ground level to target/reciever

% 2023-04-11 Patrick Eriksson

function [theta, l, alpha] = geom_link(S, h_start, h_target, l_target)

r1    = S.r_planet + h_start;
r2    = S.r_planet + h_target;

alpha = (180 / pi) * l_target / S.r_planet;

l     = sqrt(r1*r1 + r2*r2 - 2*r1*r2*cosd(alpha));
theta = 180 - asind(r2 * sind(alpha) / l);
