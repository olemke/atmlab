% ISWHOLE   True for whole numbers (integers).
%
%    Determines if the elements of an array are integers. The input *n*
%    can be of any type that gives true as input to *isnumeric.
%
%    Note that this functio differs from *isintger* found in newer Matlab,
%    which is a type test. Here also doulbe numbers are accapted, as long
%    they have no decimal part.
%
% FORMAT   bool = iswhole(n)
%        
% OUT   bool   1 if integer, else 0.
% IN    n      A variable of any valid numeric data type.

% 2005-11-22  Renamed to avoid clash in newer Matlab versions (PE).
% 2002-12-10  Adapted to Atmlab from arts/ami.
% 2000-12-18  Created by Patrick Eriksson. 


function bool = iswhole(n)


if ~isnumeric( n )
  error('Only numeric input is allowed.');
end


bool = n - round(n) == 0;
