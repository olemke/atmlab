function pscontour(in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% purpose:
%       appends options to a  short script and calls the GMT
%       command pscontour appending options.
%
%
% Author:Salomon Eliasson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pscontour = sprintf('pscontour');

%location of file
if isfield(in,'asciifile')
    pscontour = sprintf('%s %s',pscontour,in.asciifile);
else
    error 'needs in.asciifile '
end

%lat lon bounds
if isfield(in,'region')
    pscontour = sprintf('%s -R%s',pscontour,in.region);
else
    error 'needs in.region'
end

%projection type
if isfield(in,'proj')
    pscontour = sprintf('%s -J%s',pscontour,in.proj);
else
    error 'needs in.proj'
end

if isfield(in,'cptfile')
    pscontour = sprintf('%s -C%s',pscontour,in.cptfile);
else
    error 'needs in.cptfile'
end

% disable all notations
pscontour = sprintf('%s -A-',pscontour);

% selects Overlay plot mode
pscontour = sprintf('%s -O',pscontour);

%Draw coastlines. Append attributes [Defaults: width = 1, color = black, texture = solid].
if isfield(in,'width')
    pscontour = sprintf('%s -W%dp',pscontour,in.width);
else
    pscontour = sprintf('%s -W',pscontour);
end

% assuming more pscode will be appended later
pscontour = sprintf('%s -K',pscontour);

ut = sprintf('%s.ps',se.file);

command = sprintf('%s >> %s',pscontour,ut);

system(command); fprintf('%s\n',command)
