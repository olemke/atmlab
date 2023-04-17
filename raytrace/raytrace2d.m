% RAYTRACE2D   Ray tracing with refraction in circular 2D atmosphere
%
%    Basic ray tracing in cylindrical coordinates with refractive index only
%    varying in altitude. For this case the product  r*n*sin(theta) is
%    constant along the ray.
%
% FORMAT  P = raytrace2d(S, h_start, theta_start, l_stop)
%
% OUT   P             Array of path points
% IN    S             Setting structure
%       h_start       Start altitude
%       theta_start   Start zenith angle
%       l_stop        Stop ray tracing when this length has been passed

% 2023-04-11 Patrick Eriksson

function P = raytrace2d(S, h_start, theta_start, l_stop)

% Start point
%
P(1).alpha  = 0;
P(1).length = 0;
P(1).n      = S.n_funct(S.n_params, h_start);
P(1).r      = S.r_planet + h_start;
P(1).theta  = theta_start;
P(1).x      = 0;
P(1).y      = P(1).r;


% Iterate until l_end reached
%
c = P(1).r * P(1).n * sind(P(1).theta);
i = 1;
%
while P(i).length < l_stop
    % Direction in Cartesian coordinates
    as = P(i).theta + P(i).alpha;
    dx = sind(as);
    dy = cosd(as);
    
    % Move forward in Cartesian coordinates
    i = i + 1;
    P(i).x = P(i-1).x + S.l_step * dx;
    P(i).y = P(i-1).y + S.l_step * dy;

    % Update remaining structure members
    P(i).alpha  = atan2d(P(i).x, P(i).y);
    P(i).length = P(i-1).length + S.l_step;
    P(i).r      = hypot(P(i).x, P(i).y);
    P(i).n      = S.n_funct(S.n_params, P(i).r - S.r_planet);
    P(i).theta  = 180 - asind(c / (P(i).r * P(i).n));
    if P(i).theta > P(i-1).theta
        P(i).theta  = 180 - P(i).theta;
    end
end