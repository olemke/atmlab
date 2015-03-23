function command = nearneighbor(in)
% NEARNEIGHBOR Appends options to GMT nearneighbor
%
% PURPOSE: Appends options to a short script and calls the GMT
%
% IN    file      %s              .ps-file created/appened to by command
%       in        struct          options here (see help gmt_plot)
%
% OUT   command   %s              string command to be used in system call
%
% Created by Salomon Eliasson
% $Id$

NN = sprintf('gmt nearneighbor -R');

%location of file
NN = sprintf('%s %s',NN,in.ungriddedfile); %stdin
NN = sprintf('%s -G%s',NN,in.ungriddedfile); % overwrite the file

%increment grid
if isfield(in.nearneighbor,'increment')
    NN = sprintf('%s -I%s',NN,in.nearneighbor.increment);
end

%average with adjasent gridpoint GMT default=4
NN = sprintf('%s -N1/1',NN);

%search radius
if isfield(in.nearneighbor,'search')
    NN = sprintf('%s -S%s',NN,in.nearneighbor.search);
else
    error(['gmtlab:',mfilename,':badInput'], 'needs in.search')
end

command = sprintf('%s >> %s.ps',NN,in.filename);