function fh = plot_extrema_shaded(x, y, no_min, no_max, varargin)

% Plot shaded area between local minima and maxima
%
% For y(x), plot shaded area between lines connecting extrema.
%
% FORMAT
%
%   plot_extrema_shaded(x, y, no_min, no_max[, ...])
%
% IN
%
%   x
%   y
%   no_min      number of local minima to use
%   no_max      number of local maxima to use
%
%   ... all remaining arguments passed on to fill ...
%
% OUT
%
%   fh          handle to patch returned by fill
%
% See also: find_extrema_with_prominence, fill

% find_extrema_with_prominence guarantees that x is monotonically
% increasing
[local_min, local_max, prom_min, prom_max] = find_extrema_with_prominence(x, y);

mins_with_prom = [find(local_min) prom_min];
maxs_with_prom = [find(local_max) prom_max];

mins_sorted = sortrows(mins_with_prom, [2 1]);
maxs_sorted = sortrows(maxs_with_prom, [2 1]);

% interpolate to draw polygon

xx = linspace(x(1), x(end), 2000);

x_min = [x(1); x(mins_sorted(end-no_min+1:end, 1)); x(end)];
y_min = [y(1); y(mins_sorted(end-no_min+1:end, 1)); y(end)];
x_max = [x(1); x(maxs_sorted(end-no_max+1:end, 1)); x(end)];
y_max = [y(1); y(maxs_sorted(end-no_max+1:end, 1)); y(end)];

% resort according to x_min
[~, i_min] = sort(x_min);
[~, i_max] = sort(x_max);
% TODO: shaded
fh = fill([x_min(i_min); x_max(i_max(end:-1:1))], [y_min(i_min); y_max(i_max(end:-1:1))], [.1 .1 .1], varargin{:});
%plot(x_min(i_min), y_min(i_min), x_max(i_max), y_max(i_max), '-');
%set(fh,'FaceAlpha',.5,'EdgeAlpha',.5);
end
