% LINEWIDTH     Calculate the FWHM of an absorption line.
%
% FORMAT   lw = linewidth(f, a)
%
% OUT   lw         Linewidth.
% IN    name       Colormap name.
%       f          Frequency grid.
%       a          Absortion cross-sections.

% 2016-12-08   Lukas Kluft: Created.

function lw = linewidth(f, a)
    tmp = fnzeros(spline(f, a - max(a) / 2));
    lw = diff(tmp(1, :));
end
