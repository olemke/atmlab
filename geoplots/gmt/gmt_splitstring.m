% SPLITSTRING   Splits string into tokens at given separator.
%
% FORMAT   s = gmt_splitstring (p, sep)
%        
% OUT   s   Cell array of strings.

% 2011-01-26   cloned from atmlabs splitstring by Oliver Lemke.


function s = gmt_splitstring (p, sep)

if exist('OCTAVE_VERSION')
  s = strsplit (p, sep, true);
else
  s = regexp (p, sep, 'split');
end

