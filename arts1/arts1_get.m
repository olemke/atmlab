% ARTS1_GET   Resolves qarts1 variable
%
%    This function handles cases where a variable either is given directly,
%    or if it shall be loaded from a file of some ARTS1 format. 
%
%    A file is tried to be loaded if *a* is a string. Otherwise b is just
%    set to a.
%
% FORMAT   b = arts1_get( a, artstype )
%        
% OUT   b          Variable value.
% IN    a          Variable value or file name.
%       artstype   Variable type in ARTS (e.g. 'VECTOR').

% 2004-07-08   Created by Patrick Eriksson.


function b = arts1_get( a, artstype )

if ischar( a )
  b = read_datafile( a, artstype );
else
  b = a;
end