% FIND_LINK2D   Link search algorithm for circular 2D atmosphere
%
%    Determines the link by a very simple iterative algorithm. The iteration
%    is started by testing the geometrical angle to the receiver.
%
% FORMAT  P = find_link2d(S, h_start, h_target, l_target, dh_tol)
%
% OUT   P          Array of path points
% IN    S          Setting structure
%       h_start    Start/transmitter altitude
%       h_target   Target/reciever altitude
%       l_target   Distance to target/reciever along the ground
%       dh_tol     Allowed tolerance in altitude

% 2023-04-11 Patrick Eriksson

function P = find_link2d(S, h_start, h_target, l_target, dh_tol)

% Geometric distance and angles
[theta_g, l_g, alpha_target] = geom_link(S, h_start, h_target, l_target);

% Loop until link found
%
theta = theta_g;
%
while true
    P = raytrace2d(S, h_start, theta, 1.01*l_g);
    P = crop_path_alpha(P, alpha_target);
    dh = P(end).r - S.r_planet - h_target;
    if abs(dh) < dh_tol
        break;
    else
        theta = theta + 180/pi*dh/l_g;
    end
end