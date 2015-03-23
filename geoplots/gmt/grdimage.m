function command = grdimage(in)
% GRDIMAGE appends options to GMT grdimage
%
% purpose: Appends options to a short script and calls the GMT
%
% IN
%       cptfile   %s              .cpt-file used for grdimage from makecpt.m
%
% OUT   command   %s              string command to be used in system call
%
% Created by Salomon Eliasson
% $Id$

grdimage = 'gmt grdimage';

%location of file, region and projection
grdimage = sprintf('%s %s -R -J',grdimage,in.grdfile);

% The default bicubic interpolation introduces artifacts. 
% Nearneighbor to nearest point causes problems for high density data. 
% This is the default anyway
%grdimage = sprintf('%s -nb+t0.5',grdimage);

grdimage = sprintf('%s %s',grdimage,in.plotPlacement);

% selects Overlay plot mode and assuming more pscode will be appended
grdimage = sprintf('%s -O -K',grdimage);

%colortable
grdimage = sprintf('%s -C%s',grdimage,in.cptfile);

command = sprintf('%s >> %s.ps',grdimage,in.filename);