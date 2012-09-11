function [h_ax, h_cb] = scatter_density_plot(x, y, varargin)

%% scatter_density_plot Create scatter density plot in style of Eliasson et. al (2012)
%
% Create a scatter-density plot in the style of Eliasson et. al (2012).
% This routine plots a 2-dimensional histogram between the provided
% variables and plots median y(x) and median x(y) in the same graph.
% Adding labels, titles, axes-properties etc. is not done in this function,
% but should be done by the user manually, or by passing the 'axprops'
% option. See below for an example.
%
% IN
%
%   x       vector  data on x-axis
%   y       vector  data on y-axis
%   opts    structure with options:
%       bins        no. bins or vector with all bins (see hist2d)
%       trans       transformation, e.g. @(x)log10(x)
%       invtrans    inverse of trans, e.g. @(x)10.^(x)
%       axprops     structure with axes properties
%       ncolour     number of unique colours
%       medprops    structure with props for median-lines
%       ...
%
% OUT
%
%   h_ax     handle to main axes
%   h_cb     handle to colourbar-axes
%
% EXAMPLE
%
%   To compare IWP products with logarithmic axes, one may use e.g.:
%
%   opts.trans = @(x)log10(x);   % provide transformation
%   opts.invtrans = @(x)10.^(x); % inverse transformation
%   opts.axprops.xscale = 'log'; % logarithmic x-scale
%   opts.axprops.yscale = 'log'; % idem dito
%   [h_ax, h_cb] = scatter_density_plot(x, y, opts);
%
%
% Created by Gerrit Holl based on code from Salomon Eliasson
%
% See also: hist, hist2d, bin, median

% set default values and handle options
defaults = struct(...
    'bins', 50, ...
    'trans', @(x)x, ...
    'invtrans', @(x)x, ...
    'axprops', struct(), ...
    'ncolour', 20, ...
    'medprops', struct('LineWidth', 3, 'LineStyle', '-', 'Color', [0 0 0]));
opts = optargs(varargin, {defaults});
opts = optargs_struct(opts, defaults);

% create the actual 2-d histogram. Apply forward transformation upon data,
% then inverse transformation upon plotting. This allows for e.g.
% logarithmic representations.
[N, BX, BY] = hist2d(opts.trans(x), opts.trans(y), opts.bins, opts.bins);
xbins = BX(1, :);
ybins = BY(:, 1);
pcolor(opts.invtrans(xbins), opts.invtrans(ybins), N);

set(gca(), opts.axprops);
shading('flat');

% use a custom colour-table, most notably with white as the base colour
largecolour = getColourTable(length(unique(N)),opts);
set(gcf(), 'colormap', largecolour);

%% plot medians

%plot_quantiles();
hold('on');
plot_medians(x, y, xbins, opts);
plot_medians(y, x, ybins, opts);

h_ax = gca();
h_cb = colorbar();

%% tweak the looks

axis('square');
grid('on');
set(gca, 'layer', 'top'); % otherwise grid is below everything

end

function plot_medians(x, y, xbins, opts)
binned = bin(opts.trans(x), opts.trans(y), xbins);
medians = cellfun(@median, binned);
plot(opts.invtrans(xbins), opts.invtrans(medians), opts.medprops);

end

function largecolor = getColourTable(Nunique,opt)
%% getColorTable Make custom colourtable with white for 0 
%
% Custom colour-table
% Nunique should be the number of unique values. This is so that every
% thing except 0 gets a colour

% greentoblue
% blue to red
%COLORS
tot = ceil(Nunique);
ncolour = min([opt.ncolour,tot]);
white = [1 1 1];
w2b=[(.93:-.93/(ceil(ncolour/3) -1):0)',...
    (.93:-.93/(ceil(ncolour/3) -1):0)',...
    ones(ceil(ncolour/3),1)]; % white2blue

b2r=[(0:1/(2*ceil(ncolour/3)-1):1)',...
    zeros(2*ceil(ncolour/3),1),...
    (1:-1/(2*ceil(ncolour/3)-1):0)']; %blue2red

colours=[w2b;b2r(2:end,:,:)];
largecolor = zeros(tot,3);
n=0;
step = ceil(tot/ncolour);
for t = 1:size(colours,1)%ncolor
    largecolor(n+1:n+step,:) = ...
        repmat(colours(t,:),length(n+1:n+step),1);
    n = step+n;
end

largecolor(1,:) = white;

end
