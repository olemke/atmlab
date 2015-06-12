% MGD_DG2DE  Conversion of MGD PSDs from dg- to de-base
%
%  Analytical conversion of MGD PSDs. The conversion factors are taken from
%  Table 2 in Petty and Huang, JAS, [2011]. See that article also for a
%  description of the de and dg size descriptors. 
%
%  All input arguments can be scalars or tensor1 (as in e.g. *mgd_moment*).
%  That is, a number of PSDs can be convrted in one function call.
%
%  See also *particle_de2dg*. This function can perform the same conversion
%  for an arbitrary PSD.
%
% FORMAT  [n0,mu,la,ga] = mgd_dg2de(n0,mu,la,ga,a,b[,rho])
%
% OUT   n0   As input but valid for dg-based PSD.
%       mu   As input but valid for dg-based PSD.
%       la   As input but valid for dg-based PSD.
%       ga   As input but valid for dg-based PSD.
% IN    n0   See *mgd_psd*.
%       mu   See *mgd_psd*.
%       la   See *mgd_psd*.
%       ga   See *mgd_psd*.
%       a    See *particle_de2dg*.
%       b    See *particle_de2dg*.
% OPT   rho  Reference density. Default is the density of water ice,
%            obtained as constants('DENSITY_OF_ICE').

% 2015-06-12   Created by Patrick Eriksson.

function [n0,mu,la,ga] = mgd_dg2de(n0,mu,la,ga,a,b,varargin)
%
[rho] = optargs( varargin, { constants('DENSITY_OF_ICE') } );

  
[n0,mu,la,ga,a,b,rho] = scalars_vectors2same_size( n0, mu, la, ga, a, b, rho );

a0 = rho * pi / 6;

n0 = ( 3 * n0 .* (a0./a).^((mu+1)/b) ) / b;

mu = 3 .* ( mu + 1 )./b - 1;

la = la .* (a0./a)^(ga/b);

ga = 3 * ga ./ b;