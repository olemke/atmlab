% ALLCLOSE   Element-wise comparison of two arrays.
%
%   Returns true if two arrays are element-wise equal within a tolerance.
%
%   For finite values, isclose uses the following equation to test whether
%   two floating point values are equivalent.
%
%       absolute(`a` - `b`) <= (`atol` + `rtol` * absolute(`b`))
%
% FORMAT   bool = allclose(a, b, rtol, atol)
%
% OUT   bool   Returns true if the two arrays are equal within the given
%              tolerance; false otherwise.
% IN    a, b   Input arrays to compare.
%       rtol   The relative tolerance parameter (default 1e-05).
%       atol   The absolute tolerance parameter (default 1e-08).

% 2016-11-14  Created by Lukas Kluft. 

function bool = allclose(a, b, rtol, atol)

if nargin < 4
    atol=1e-08;
end

if nargin < 3
    rtol=1e-05;
end

bool = all(isclose(a, b, rtol, atol) == 1);

end
