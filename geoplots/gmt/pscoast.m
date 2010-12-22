function command = pscoast(file,in)
%% pscoast
%
% purpose:
%       appends options to a  short script and calls the GMT
%       command pscoast appending options.
%
%
%
% $Author$
% $Date$

pscoast = sprintf('pscoast -R -J');

% set the minimal area of features to plot
if isfield(in,'features')
    pscoast = sprintf('%s -A%d',pscoast,in.features);
end

if isfield(in,'resolution')
    pscoast = sprintf('%s -D%s',pscoast,in.resolution);
end

if isfield(in,'rivers')
    pscoast = sprintf('%s -I%s',pscoast,in.rivers);
end

%Draw coastlines. Append attributes [Defaults: width = 1, color = black, texture = solid].
if isfield(in,'width')
    pscoast = sprintf('%s -W%dp',pscoast,in.width);
else pscoast = sprintf('%s -W',pscoast);
end

% selects Overlay plot mode and assuming more pscode will be appended
pscoast = sprintf('%s -O -K',pscoast);

command = sprintf('%s >> %s.ps',pscoast,file);