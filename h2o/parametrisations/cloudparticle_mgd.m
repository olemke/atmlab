% CLOUDPARTICLE_MGD  returns the concentration of particle
%                    at different sizes or masses for a modified
%                    gamma distribution
%
% A modfied gamma distribution can be written as
% n(x) = N0 * D^mu * exp(-lambda * x^gamma)               (1) 
% 
% FORMAT   y = cloudparticle_mgd(x,N0,mu,lambda,gamma)
%
% OUT      y   number concentration evaluated at x [#/m^3/m] or [#/m^3/Kg]
%               
% IN       x   particle dimension or mass vector
%          N0  modified gamma distribution parameter (see eq. 1) 
%          mu  modified gamma distribution parameter (see eq. 1)
%          lambda  modified gamma distribution parameter (see eq. 1)
%          gamma modified gamma distribution parameter (see eq. 1)
%
% Example usage:
%
% %first get some realistic input parameters
% %predined mgd parameters
% mu     = 2; %mu
% g      = 1; %gamma
% %given parameters from a climate model
% Ntot   = 10000; % number of particles [#/m^3]
% q      = 1e-3; %ice water content [kg/m3]
% m(Dg)=a*Dg^b;
% a      = 206*1e-3;
% b      = 2.25;
% [N0,lambda] = mgd_get_parameter(q,Ntot,a,b,mu,g);
%
% Dg    = 1e-6:1e-6:1e-2; %particle dimension
% y = cloudparticle_mgd(Dg,N0,mu,lambda,g);
% 

% HISTORY created by Bengt Rydberg 2014-09-25

function [y] = cloudparticle_mgd(D,N0,mu,lambda,gamma)

y = N0 * D.^mu .* exp(-lambda * D.^gamma);

