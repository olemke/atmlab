% RQRE_DATATYPE   Checks if variable is of expected data type
%
%    Issues an error if criterion not fulfilled.
%
%    The input argument *datatypes* can either be a string with a
%    single data type, or cell array of strings with a set of types.
%
%    There must be a function named *isDATATYPE* for each accapted
%    data type.
%
% FORMAT   rqre_datatype( datatypes, a )
%        
% IN    datatypes   Accepted datatypes
%       a           Variable to check.

% 2005-03-16   Created by Patrick Eriksson.


function rqre_datatype( datatypes, a )

if ischar( datatypes )
  datatypes = { datatypes };
end

ok = 0;

for i = 1:length(datatypes)
  if eval(['is',datatypes{i},'(a)'])
    ok = 1;
    break;
  end
end

if ~ok
  fprintf('Accepted data types:\n');
  for i = 1:length(datatypes)
    fprintf('   %s\n', datatypes{i} );
  end
  error( '%s is not of any accepted type (see above)', inputname(2) );
end