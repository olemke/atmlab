function r = circ_distd(x, y)

% circ_distd Degree-version of circ_dist
%
% As <a href="matlab:help circ_dist">circ_dist</a> but with degrees.
%
% $Id$

r = circ_rad2ang(circ_dist(circ_ang2rad(x), circ_ang2rad(y)));
