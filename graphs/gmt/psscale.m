function command = psscale(in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% purpose:
%       appends options to a  short script and calls the GMT
%       command psscale appending options.
%
%
% Author:Salomon Eliasson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

psscale = sprintf('psscale');

if isfield(in,'unit')
    psscale = sprintf('%s -B::/:%s:',psscale,in.unit);
end

if isfield(in,'cptfile')
    psscale = sprintf('%s -C%s',psscale,in.cptfile);
else
    error 'needs in.cptfile'
end

if isfield(in,'legendsize')
    psscale = sprintf('%s -D%s',psscale,in.legendsize);
end

if in.sidebar %i.e the triangles bellow the min and above the max values
    psscale = sprintf('%s -E',psscale);
end

% assuming more pscode will be appended later
psscale = sprintf('%s -K',psscale);

% Gives equal-sized color rectangles
if isfield(in,'equalboxsize')
    psscale = sprintf('%s -L',psscale);
end

% selects Overlay plot mode
if ~isempty(dir(sprintf('%s.ps',in.file)))
    psscale = sprintf('%s -O',psscale);
end

ut = sprintf('%s.ps',in.file);
command = sprintf('%s >> %s',psscale,ut);