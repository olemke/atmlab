% ISMATRIX   True for matrix variables.
%
%    Determines if a variable is a matrix, that is, a numeric of size mxn 
%    where n or m (or both) can be equal to 1.
%
% FORMAT   bool = ismatrix(a)
%        
% OUT   bool   1 if matrix, else 0.
% IN    a      A variable of any data type.

% 2005-03-16  Created by Patrick Eriksson. 


function bool = ismatrix( a )


bool = 0;


if isnumeric( a )
  
  s = size( a );

  if length(s) <= 2  

    bool = 1;

  end

end

