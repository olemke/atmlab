function values = bin(x, y, xbin)

% bin Bin y according to x in xbin
%
% Bin the contents of y in the bins x according to the values in x.
% E.g. y(i) is binned according to the value of x(i). Binning rules
% as for <a href="matlab:help histc">histc</a>.
%
% FORMAT
%
%   values = bin(x, y, xbin)
%
% IN
%
%   x       numeric array
%               values determine how y is binned
%   y       numeric array
%               values to bin. Must be the same size as x.
%   xbin    numeric array, monotonously increasing
%               bin edges (as for histc)
%
% OUT
%
%   values  cell array
%               Binned values.
%
% $Id$


%% convert to column vectors, if needed
x = vec2col(x);
y = vec2col(y);
%Z = [x y];

[~, bin] = histc(x, xbin);
values = cell(size(xbin));
for i = 1:length(xbin)
    inhere = y(bin==i);
    values{i} = inhere;
end
