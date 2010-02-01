function command = pscoast(in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% purpose:
%       appends options to a  short script and calls the GMT
%       command pscoast appending options.
%
%
% Author:Salomon Eliasson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pscoast = sprintf('pscoast');

%lat lon bounds
if isfield(in,'region')
    pscoast = sprintf('%s -R%s',pscoast,in.region);
else error('needs in.region')
end

%projection type
if isfield(in,'proj')
    pscoast = sprintf('%s -J%s',pscoast,in.proj);
else error('needs in.proj')
end

% set the minimal area of features to plot
if isfield(in,'features')
    pscoast = sprintf('%s -A%d',pscoast,in.features);
end

% Sets map boundary annotation and tickmark intervals;
pscoast = sprintf('%s -B%s',pscoast,in.ticks);

if isfield(in,'resolution')
    pscoast = sprintf('%s -D%s',pscoast,in.resolution);
end

if isfield(in,'rivers')
    pscoast = sprintf('%s -I%s',pscoast,in.rivers);
end

% selects Overlay plot mode
if ~isempty(dir(sprintf('%s.ps',in.file)))
    pscoast = sprintf('%s -O',pscoast);
end

% set portrait
pscoast=sprintf('%s -P',pscoast);

%Draw coastlines. Append attributes [Defaults: width = 1, color = black, texture = solid].
if isfield(in,'width')
    pscoast = sprintf('%s -W%dp',pscoast,in.width);
else pscoast = sprintf('%s -W',pscoast);
end

% assuming more pscode will be appended later
pscoast = sprintf('%s -K',pscoast);

ut = sprintf('%s.ps',in.file);
command = sprintf('%s >> %s',pscoast,ut);