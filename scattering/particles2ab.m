% PARTICLES2AB   Derives a and b for a set of particles
%
%   Maximum dimension of particles and their mass is often assumed to follow
%   the relation: mass = a * dmax^b
%
%   The function performs a fit to derive a and b for a set of particles.
%
% FORMAT   [a,b] = particles2ab(dmax,mass[,dmax_limit])
%
% OUT   a           Derived a coefficient.
%       b           Derived b coefficient.
% IN    dmax        Maximum diameter of each particle.
%       mass        Mass of each particle.
% OPT   dmax_limit  Exclude particles below this limit from fit.
%                   Default is 100 um.

% 2016-05-22   Patrick Eriksson

function [a,b] = particles2ab(dmax,mass,varargin)
%
[dmax_limit] = optargs( varargin, { 100e-6 } );


% Sort in dmax
%
[dmax,ind] = sort( dmax );
mass       = mass( ind );

% Make fit for particles abobe set limit
%
ind = find( dmax >= dmax_limit );
%
pp  = polyfit( log(dmax(ind)), log(mass(ind)), 1 );

% Extract a and b
%
a   = exp( pp(2) );
b   = min( [ pp(1), 3 ] );

