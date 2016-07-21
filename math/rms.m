% RMS Calculate root mean square (RMS)
%
% This function squares all elements of x, sums them up, divides by
% the number of elements, and takes the root.
%
% Input x can be a vector, matrix, or higher order tensor, the
% output is always a scalar
%
% FORMAT y = rms(x, dim)
%
% OUT    y	RMS value
% IN     x      Input vector or matrix
%        dim    Optional argument to compute RMS along one dimension
%
% 2008-09-02 Created by Stefan Buehler
% 2016-07-21 Added dim argument, Oliver Lemke

function y = rms(x, dim)

if nargin == 1
    xs = x(:) .* x(:);

    s  = sum(xs) / length(x(:));

    y  = sqrt(s);
else
    y = sqrt(mean(x .* conj(x), dim));
end