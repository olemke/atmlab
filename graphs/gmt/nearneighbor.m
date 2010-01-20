function command = nearneighbor(in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% purpose:
%       Appends options to a short script and calls the GMT
%       command nearneighbor.
%
%
% Author:Salomon Eliasson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nearneighbor = sprintf('nearneighbor');

%location of file
if isfield(in,'asciifile')
    nearneighbor = sprintf('%s %s',nearneighbor,in.asciifile);
    nearneighbor = sprintf('%s -F -G%s.grd',nearneighbor,in.file);
else
    error 'needs in.asciifile '
end

%lat lon bounds
if isfield(in,'region')
    nearneighbor = sprintf('%s -R%s',nearneighbor,in.region);
else
    error 'needs se.plotregion'
end

%increment grid
if isfield(in,'increment')
    nearneighbor = sprintf('%s -I%s',nearneighbor,in.increment);
end

%average with adjasent gridpoint GMT default=4
nearneighbor = sprintf('%s -N1',nearneighbor);

%search radius
if isfield(in,'search')
    nearneighbor = sprintf('%s -S%s',nearneighbor,in.search);
else
    error 'needs in.search'
end

command = nearneighbor;