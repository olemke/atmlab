function command = grdcontour(file,in)
%% pscontour
%
% purpose:
%       appends options to a  short script and calls the GMT
%       command pscontour appending options.
%
%
% Author:Salomon Eliasson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%location of file, region and projection
grdcontour = sprintf('grdcontour %s -R -J',in.grdfile);

if isfield(in,'spacing')
    grdcontour = sprintf('%s -A%f',grdcontour,in.spacing);
end

if isfield(in,'fontsize')
    grdcontour = sprintf('%s+s%f',grdcontour,in.fontsize);
end

if isfield(in,'range')
    grdcontour = sprintf('%s -L%f-%f',grdcontour,in.range(1),in.range(2));
end

if isfield(in,'label_placement')
    grdcontour = sprintf('%s -G%s',grdcontour,in.label_placement);
else
    % 4 inches apart, no closer than .5cm from each other in xy plane
    grdcontour = sprintf('%s -Gd4i+r.5c',grdcontour); 
end

if isfield(in,'more') && ~isempty(in.more)
    grdcontour = sprintf('%s %s',grdcontour,in.more);
end

% selects Overlay plot mode and assuming more pscode will be appended
grdcontour = sprintf('%s -O -K',grdcontour);

command = sprintf('%s >> %s.ps',grdcontour,file);