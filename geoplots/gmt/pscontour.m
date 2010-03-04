function command = pscontour(in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% purpose:
%       appends options to a  short script and calls the GMT
%       command pscontour appending options.
%
%
% Author:Salomon Eliasson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%location of file

error('Doesn''t work yet')
if isfield(in,'file')
    pscontour = sprintf('pscontour %s.grd',in.file);
else
    error 'needs in.file '
end

pscontour = sprintf('%s -bic',pscontour); %for binary input\

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
if ~isempty(dir(sprintf('%s.ps',in.file)))
    pscontour = sprintf('%s -O',pscontour);
end
%Draw coastlines. Append attributes [Defaults: width = 1, color = black, texture = solid].
if isfield(in,'width')
    pscontour = sprintf('%s -W%dp',pscontour,in.width);
else
    pscontour = sprintf('%s -W',pscontour);
end

% assuming more pscode will be appended later
pscontour = sprintf('%s -K',pscontour);

ut = sprintf('%s.ps',in.file);

command = sprintf('%s >> %s',pscontour,ut);