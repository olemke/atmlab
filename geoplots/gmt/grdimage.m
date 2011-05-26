function command = grdimage(file,in)
% GRDIMAGE appends options to GMT grdimage
%
% purpose: Appends options to a short script and calls the GMT
%
% IN    file      %s              .ps-file created/appened to by command
%       cptfile   %s              .cpt-file used for grdimage from makecpt.m
%
% OUT   command   %s              string command to be used in system call
%
% Created by Salomon Eliasson
% $Id$

grdimage = 'grdimage';

%location of file, region and projection
grdimage = sprintf('%s %s -R -J',grdimage,in.grdfile);

%colortable
grdimage = sprintf('%s -C%s',grdimage,in.plot.color.cptfile);

%Use nearestneigbour interpolation, only use the nearest grid point
%Otherwise the default bicubic interpolation introduces artifacts.
grdimage = sprintf('%s -S-n/0',grdimage);

% selects Overlay plot mode and assuming more pscode will be appended
grdimage = sprintf('%s -O -K',grdimage);

command = sprintf('%s >> %s.ps',grdimage,file);