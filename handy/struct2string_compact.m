function descr = struct2string_compact(S, n)

% struct2string_compact
%
% Return a compact representation of a string. All members should be scalar
% numbers. Whole numbers are represented as such, any others are given N
% digits of precision. This can be useful to add to a filename for storing
% a figure or to use in a plot title or legend.
%
% EXAMPLE
%
% >> disp(struct2string_compact(struct('A', 1, 'B', 2, 'C', pi), 4));
% A=1,B=2,C=3.1416
%
% FORMAT
%
%   descr = struct2string_compact(S, n)
%
% IN
%
%   S   scalar structure, all values should be scalar numbers
%   n   number of digits of precision. Defaults to 3.
%
% OUT
%
%   descr   compact string describing the structure
%
% $Id$

if ~exist('n', 'var')
    n = 3;
end

descr = cellfun(@(v) sprintf('%s=%.*f,', v, n*~iswhole(S.(v)), S.(v)), fieldnames(S), 'UniformOutput', false);
descr = horzcat(descr{:});
descr = descr(1:end-1); % take off final comma