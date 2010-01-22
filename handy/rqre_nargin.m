% RQRE_DATATYPE   Checks if variable is of any expected data type
%
%    The input argument *funchandles* is a cell array with handles to
%    functions performing type checking, such as {@isnumeric}. For example,
%    the following will generate an error message:
%       a = 'a';
%       rqre_datatype( a, {@isnumeric,@iscell} )
%
%    Issues an error if criterion not fulfilled. This error assumes that all
%    functions are named as isxxxx, where xxxx is the name of the data type.
%
% FORMAT   rqre_datatype( a, funchandles [,nonstdname] )
%        
% IN    a             Variable to check.
%       funchandles   Handles to type checking functions.
% OPT   nonstdname    Name of variable to use in error message. Default is
%                     to use the function *inputname* to determine the
%                     variable name.

% 2005-03-16   Created by Patrick Eriksson.


function rqre_nargin( nreq, narg )
                                                                            %&%
                                                                            %&%
%- Checks                                                                   %&%
%                                                                           %&%
assert( istensor0( nreq )  &&  nreq >= 0 );                                 %&%
assert( istensor0( narg )  &&  narg >= 0 );                                 %&%


if narg < nreq
  [st,i] = dbstack;  
  error( 'The function *%s* requires at least %d arguments.', ...
                                                          st(i+1).name, nreq );
end  