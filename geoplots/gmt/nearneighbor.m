function command = nearneighbor(file,in)
%% nearneighbor
%
% purpose:
%       Appends options to a short script and calls the GMT
%       command nearneighbor.
%
% $Author$
% $Date$

nearneighbor = sprintf('nearneighbor');

nearneighbor = sprintf('%s -bic',nearneighbor); %for binary input

%location of file
if isfield(in,'ungriddedfile')
    nearneighbor = sprintf('%s %s',nearneighbor,in.ungriddedfile);
    nearneighbor = sprintf('%s -F -G%s.grd',nearneighbor,file);
else
    error 'needs in.ungriddedfile '
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

% selects Overlay plot mode and assuming more pscode will be appended
nearneighbor = sprintf('%s -O -K',nearneighbor);

command = sprintf('%s >> %s.ps',nearneighbor,file);