% ISVECTOR   True for vector variables.
%
%    Determines if a variable is a vector, that is, a numeric of size 1xn or
%    nx1 (1x1 is OK). Empty variables are classified as non-vectors.
%
% FORMAT   bool = isvector(a)
%        
% OUT   bool   1 if vector, else 0.
% IN    a      A variable of any data type.

% 2002-12-11  Created by Patrick Eriksson. 


function bool = isvector( a )


bool = 0;


if isnumeric( a )
  
  s = size( a );

  if length(s) <= 2  &  min(s) == 1

    bool = 1;

  end

end

