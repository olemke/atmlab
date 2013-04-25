function f = safegetfield(S, field, alt)

% SAFEGETFIELD get field from structure, otherwise return alt
%
% safegetfield(S, field, alt) is short for:
%
% if isfield(S, field)
%   f = S.(field);
% else
%   f = alt;
% end

% $Id$

if isfield(S, field)
  f = S.(field);
else
  f = alt;
end

end
