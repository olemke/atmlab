function x = plot_empty_regions(data,in)
%% plot_empty_regions
%
% Purpose: To plot regions on an empty map using GMT. The only
%        manditory argument are the coordinates for the regions. The
%        function is especially useful in that it can handle composite
%        regions, i.e. made up of many rectangular regions next to each
%        other.
%
% IN: data = [lat1 lon1 lat2 lon2; lat1 lon1 lat2 lon2; etc]
%     in = struct containing arguments accepted in gmt_plot.m
%
% OUT: Structure of arguments used to plot figure
%
% 13/9 -2009 Salomon Eliasson

out = polygoninize_regions(data);

if exist('in','var')
    for f = fields(in)'
        %% include fields given at input
        x.(f{1}) = in.(f{1});
    end
    if ~isfield(in,'colors')
        x.pspolycolor = list_colors('Ncolors',size(out.psxy,1));
    end
    if ~isfield(in,'filename')
        x.filename = 'blankmap_ofregions';
    end
else
    x.pspolycolor = list_colors('Ncolors',size(out.psxy,1));
    x.filename = 'blankmap_ofregions';
end

x.pspoly = out.psxy;
x.nodata=true;

x.filename = gmt_plot(x);
x=clearfield(x,'nodata');
