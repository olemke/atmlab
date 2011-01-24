function command = grdimage(file,cptfile)
%% grdimage
% purpose:
%       Makecpt creates a short script and calls the GMT
%       command grdimage.
%
% $Author$
% $Date$

grdimage = sprintf('grdimage');

%location of file, region and projection
grdimage = sprintf('%s %s.grd -R -J',grdimage,file);

%colortable
grdimage = sprintf('%s -C%s',grdimage,cptfile);

%Use nearestneigbour interpolation, only use the nearest grid point
%Otherwise the default bicubic interpolation introduces artifacts.
grdimage = sprintf('%s -S-n/0',grdimage);

% selects Overlay plot mode and assuming more pscode will be appended
grdimage = sprintf('%s -O -K',grdimage);

command = sprintf('%s >> %s.ps',grdimage,file);