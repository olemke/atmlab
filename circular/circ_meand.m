function [mu ul ll] = circ_meand(alpha_deg, varargin)

% [mu ul ll] = circ_meand(...)
%
% As <a href="matlab:help circ_mean">circ_mean</a> but with degrees.
%
% $Id$

alpha_rad = circ_ang2rad(alpha_deg);
[mu_rad ul ll] = circ_mean(alpha_rad, varargin{:});
mu = circ_rad2ang(mu_rad);
ul = circ_rad2ang(ul);
ll = circ_rad2ang(ll);
