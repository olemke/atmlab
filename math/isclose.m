% ISCLOSE   Element-wise comparison of two arrays.
%
%   Returns a boolean array where two arrays are element-wise equal within
%   a tolerance.
%
%   For finite values, isclose uses the following equation to test whether
%   two floating point values are equivalent.
%
%       absolute(`a` - `b`) <= (`atol` + `rtol` * absolute(`b`))
%
% FORMAT   bool = isclose(a, b, rtol, atol)
%        
% OUT   bool   Returns a boolean array of where `a` and `b` are equal
%              within the given tolerance. If both `a` and `b` are scalars,
%              returns a single boolean value.
% IN    a, b   Input arrays to compare.
%       rtol   The relative tolerance parameter (default 1e-05).
%       atol   The absolute tolerance parameter (default 1e-08).

% 2016-11-14  Created by Lukas Kluft. 


function bool = isclose(a, b, rtol, atol)

if nargin < 4
    atol=1e-08;
end

if nargin < 3
    rtol=1e-05;
end

bool = abs(a - b) <= (atol + rtol * abs(b));

end