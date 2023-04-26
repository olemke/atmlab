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
P(1).r      = S.r_planet + h_start;
P(1).theta  = theta_start;
P(1).x      = 0;
P(1).y      = P(1).r;
%
[n, dndh_o] = S.n_funct(S.n_params, h_start);
P(1).n      = n;


% Iterate until l_end reached
%
i = 1;
f = 180 * S.l_step / pi;
%
while P(i).length < l_stop
    % Make sure to not move below ground
    l_step   = S.l_step;
    surf_hit = false;
    if P(i).theta > 90
        k        = S.r_planet / sind(P(i).theta);
        l2ground = k * sind(P(i).theta + asind(P(i).r/k) - 180);
        % l2ground gets imaginary if no intersection with ground!
        if isreal(l2ground) && l2ground <= S.l_step
            l_step   = l2ground;
            surf_hit = true;
        end
    end
    
    % Direction in Cartesian coordinates
    as = P(i).theta + P(i).alpha;
    dx = sind(as);
    dy = cosd(as);
    
    % Move forward in Cartesian coordinates
    i = i + 1;
    P(i).x = P(i-1).x + l_step * dx;
    P(i).y = P(i-1).y + l_step * dy;
    P(i).alpha  = atan2d(P(i).x, P(i).y);
    P(i).length = P(i-1).length + l_step;
    P(i).r      = hypot(P(i).x, P(i).y);

    % Update n and theta   
    [n, dndh_n] = S.n_funct(S.n_params, P(i).r - S.r_planet);
    dndh        = 0.5 * (dndh_o + dndh_n);
    P(i).theta  = P(i-1).theta - (P(i).alpha - P(i-1).alpha) - ...
        f * sind(P(i-1).theta) * dndh_n / n;
    P(i).n      = n;
    dndh_o      = dndh_n;
    
    % Above surface
    if surf_hit
        P(i).theta = 180 - P(i).theta;
    end
end

% Code for setting theta after path constant. Does not working for trapping
% layers.
%
%    P(i).r      = hypot(P(i).x, P(i).y);
%    P(i).n      = S.n_funct(S.n_params, P(i).r - S.r_planet);
%    if c / (P(i).r * P(i).n) < 1
%        P(i).theta  = 180 - asind(c / (P(i).r * P(i).n));
%        if P(i).theta > P(i-1).theta
%            P(i).theta  = 180 - P(i).theta;
%        end
%    else
%        P(i).theta = 90;
%    end
