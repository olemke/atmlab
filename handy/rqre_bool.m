% RQRE_BOOL   Require that a variable is a boolean
%
%    Issues an error if criterion not fulfilled.
%
% FORMAT   rqre_bool( name, a )
%        
% IN    name   Name on variable, or a descriptive string.
%       a      Variable value.

% 2004-09-07   Created by Patrick Eriksson.


function rqre_bool( name, a )

if ~( isequal(a,0) | isequal(a,1) )
  fprintf('\n%s is required to be a boolean.\n\n', name );
  error('See above');
end