function command = pscontour(file,in)
%% pscontour
%
% purpose:
%       appends options to a  short script and calls the GMT
%       command pscontour appending options.
%
%
% Author:Salomon Eliasson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%location of file

if isfield(in,'file')
    pscontour = sprintf('pscontour %s.grd',file);
else
    error 'needs file '
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

%Draw coastlines. Append attributes [Defaults: width = 1, color = black, texture = solid].
if isfield(in,'width')
    pscontour = sprintf('%s -W%dp',pscontour,in.width);
else
    pscontour = sprintf('%s -W',pscontour);
end

% selects Overlay plot mode and assuming more pscode will be appended
pscontour = sprintf('%s -O -K',pscontour);

command = sprintf('%s >> %s.ps',pscontour,file);