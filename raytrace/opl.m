% OPL   Optical path length
%
%    Integrates refracive index along the path by trapz
%
% FORMAT  l = opl(P)
%
% OUT   l   Optical path length
% IN    P   Array of path points

% 2023-04-11 Patrick Eriksson

function l = opl(P)

l = trapz([P.length], [P.n]);