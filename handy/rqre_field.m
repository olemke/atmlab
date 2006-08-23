% RQRE_FIELD   Require that a structure has a particular field
%
%    Issues an error if criterion not fulfilled.
%
% FORMAT   rqre_field( Q, fieldname [, accept_nan ] )
%        
% IN    Q           The structure.
%       fieldname   Name of field.
% OPT   accept_nan  Flag for treatment of NaNs. Default is 1.
%                   Set to 0 to get an error if any NaN is found.

% 2005-03-15   Created by Patrick Eriksson.


function rqre_field( Q, fieldname, accept_nan )

if ~isfield( Q, fieldname )
  error( sprintf('Structure %s is required to have field %s.', ...
                                                   inputname(1), fieldname ) );
end

if nargin > 3  &  ~accept_nan
  if any( isnan( getfield(Q,fieldname) ) )
    error( sprintf( 'Not allowed NaN found in %s.%s.', inputname(1), ...
                                                                 fieldname ) );
  end
end