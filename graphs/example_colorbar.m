% EXAMPLE_COLORBAR
%
% Demonstrate how zerowhite and colorbarf can be used to create a
% filled contour plot with correct colorbar.
%
% 2004-04-07 Stefan Buehler


z = peaks;

[cmap,v] = zerowhite( z, [-8 -6 -4 -2 -1 1 2 4 6 8], 'nzp', .5 );

[cout,H,cf] = contourf(z,v);
clabel(cout,H);
colorbarf(cout,H);
colormap(cmap);

hold on;

[c,h] = contour(z,[0 0],'k--');
clabel(c,h);

hold off;
