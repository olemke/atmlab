% RQRE_SCALAR   Require that a variable is a scalar
%
%    Issues an error if criterion not fulfilled.
%
% FORMAT   rqre_scalar( name, a [, lowlim, highlim] )
%        
% IN    name     Name on variable, or a descriptive string.
%       a        Variable value.
% OPT   lowlim   It is required that a >= lowlim. Default is -Inf.
%       highlim  It is required that a >= lhighlim. Default is Inf.

% 2004-09-07   Created by Patrick Eriksson.


function rqre_scalar( name, a, lowlim, highlim )

if nargin < 3
  lowlim = -Inf;
end
if nargin < 4
  highlim = Inf;
end

if isnan(a)  |  ~isscalar(a) |  a < lowlim  |  a > highlim
  fprintf('\n%s is required to be a scalar >= %d and <= %d.\n\n', name, lowlim, highlim );
  error('See above');
end