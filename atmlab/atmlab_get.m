% ATMLAB_GET   Extracts personal setting.
%
%    The function returns the value for the personal setting selected.
%    
%    If no *atmplot* function can be found, the output argument is set
%    to be empty if *required* = 0. Otherwise an error is issued.    
%
% FORMAT   value = atmlab_get(field[,required])
%        
% OUT   value       Value of field.
% IN    field       Field name.
%       required    Boolean to require that personal settings exist.
%                   Default is 0.

% 2002-12-19   Created by Patrick Eriksson.


function value = atmlab_get(field,required)


%= Input
%
min_nargin( 1, nargin );
% 
if nargin < 2
  required = 0;
end


if ~exist( 'atmlab.m', 'file' )

  if required
    error( ['You have selected a feature requiring personal settings,', ...
                     'but no *atmplot* function exists in the search path.'] );
  else
    value = [];
    return;
  end

else

  A = atmlab_defs;

  if ~isfield( A, field )
    serr = sprintf( ... 
    'The option ''%s'' is not a personal setting existing in Atmlab.', field );
    error( serr );
  end

  value = atmlab( field );

end
