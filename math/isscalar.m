% ISSCALAR   True for scalar variables.
%
%    Determines if a variable is a scalar, that is, a numeric of size 1x1.
%
% FORMAT   bool = isscalar(a)
%        
% OUT   bool   1 if scalar, else 0.
% IN    a      A variable of any data type.

% 2002-01-03  Created by Patrick Eriksson. 
% 2002-12-10  Adapted to Atmlab from arts/ami.


function bool = isscalar( a )


bool = 0;


if isnumeric( a )
  
  if length(a) == 1

    bool = 1;

  end

end

