% RQRE_FIELD   Require that a structure has a particular field
%
%    Issues an error if criterion not fulfilled.
%
% FORMAT   rqre_field( Q, qname, fieldname [, accept_nan ] )
%        
% IN    Q           The structure.
%       qname       Name of structure (for possible error message).
%       fieldname   Name of field.
% OPT   accept_nan  Flat for treatment of NaNs. Default is 1.
%                   Set to 0 to get an error if any NaN is found.

% 2005-03-15   Created by Patrick Eriksson.


function rqre_field( Q, qname, fieldname, accept_nan )

if ~isfield( Q, fieldname )
  error( sprintf('Structure %s qname is reuired to have field %s.', ...
                                                          qname, fieldname ) );
end

if nargin > 3  &  ~accept_nan
  if any( isnan( getfield(Q,fieldname) ) )
    error( sprintf( 'Not allowed NaN found in %s.%s.', qname, fieldname ) );
  end
end