% ISODD   True for odd integers.
%
%    Determines if the elements of an array are odd integers. The input *n*
%    can be of any type that gives true as input to *isnumeric.
%
% FORMAT   bool = isodd(n)
%        
% OUT   bool   1 if odd integer, else 0.
% IN    n      A variable of any valid numeric data type.

% 2000-08-16  Created by Patrick Eriksson. 
% 2002-12-10  Adapted to Atmlab from arts/ami.


function bool = isodd(n)


if ~isnumeric( n )
  error('Only numeric input is allowed.');
end


bool = (rem(n,2) - 1) == 0;
