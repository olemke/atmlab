% ISINTEGER   True for integers.
%
%    Determines if the elements of an array are integers. The input *n*
%    can be of any type that gives true as input to *isnumeric.
%
% FORMAT   bool = isinteger(n)
%        
% OUT   bool   1 if integer, else 0.
% IN    n      A variable of any valid numeric data type.

% 2000-12-18  Created by Patrick Eriksson. 
% 2002-12-10  Adapted to Atmlab from arts/ami.


function bool = isinteger(n)


if ~isnumeric( n )
  error('Only numeric input is allowed.');
end


bool = n - round(n) == 0;
