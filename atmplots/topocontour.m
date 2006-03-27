% COASTLINES   Adds coast lines to your plot.
%
%    The resolution is on the 1 degree level. Thus only suitable for global 
%    plots.
%
%    Note that this function will affect the color map and a colorbar should
%    be placed before calling this function.
%
% FORMAT   coastlines([lcolor,lwidth])
%        
% OPT   lcolor   Line color. Default is [0 0 0].
%       lwidth   Line width. Default is 1.

% 2006-03-27   Created by Patrick Eriksson (code from Mattias Ekstrom).


function coastlines(lcolor,lwidth)

%= Default arguments
%
lcolor_DEFAULT = [0 0 0];
lwidth_DEFAULT = 1;
%
set_defaults;


load topo

contour(0.5:359.5,-89.5:89.5,topo,[0 0],'LineColor',lcolor,'LineWidth',lwidth);



