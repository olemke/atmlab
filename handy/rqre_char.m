% RQRE_CHAR   Require that a variable is a string
%
%    Issues an error if criterion not fulfilled.
%
% FORMAT   rqre_char( name, a )
%        
% IN    name     Name on variable, or a descriptive string.
%       a        Variable value.

% 2004-09-07   Created by Patrick Eriksson.


function rqre_char( name, a )

if ~ischar(a)
  fprintf('\n%s is required to be a string.\n\n', name );
  error('See above');
end