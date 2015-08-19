% N_AIR_THAYER   Microwave refractive index for Earth's atmosphere
%
%   The parameterisation of Thayer (Radio Science, 9, 803-807, 1974)
%   (with Z values set to 1).
%
%   That is, n = 1 + a*(p-e)/t + b*e/t + c*e/t^2 
%
%   The values of a, b and c are optional arguments. The expression is
%   non-dispersive.
%
% FORMAT: [n,nh] = n_air_thayer(p,t,h2o[,a,b,c])
%
% OUT: n   Refractive index (total, only real part).
%      nh  The "hydrostatic part" of n. That is, the term associated with c
%          is not included.
% IN:  p   Pressure.
%      t   Temperature
%      e   Water vapour partial pressure
% OPT: a   See above. Default is 77.6e-8.
%      b   See above. Default is 64.8e-8.
%      c   See above. Default is 3.776e-3.

function [n,nh] = n_air_thayer(p,t,e,varargin)
%
[a,b,c] = optargs( varargin, { 77.6e-8, 64.8e-8, 3.776e-3 } );


rqre_element_math( p, t );
rqre_element_math( p, e );


% Version used before 2015-08-19
%  n = 1 + ( 77.6e-8 * ( p - e ) + ( 64.8e-8 + 3.776e-3 ./ t) .* e ) ./ t;

nh = 1 + ( a * ( p - e ) + b * e ) ./ t;
n  = nh + c * e ./ (t.^2);
