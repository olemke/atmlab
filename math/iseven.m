% ISEVEN   True for even integers.
%
%    Determines if the elements of an array are even integers. The input *n*
%    can be of any type that gives true as input to *isnumeric.
%
% FORMAT   bool = iseven(n)
%        
% OUT   bool   1 if even integer, else 0.
% IN    n      A variable of any valid numeric data type.

% 2002-12-10  Created by Patrick Eriksson. 


function bool = iseven(n)


if ~isnumeric( n )
  error('Only numeric input is allowed.');
end


bool = rem(n,2) == 0;
