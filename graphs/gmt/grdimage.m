function command = grdimage(in)
%%
% purpose:
%       Makecpt creates a short script and calls the GMT
%       command grdimage.
%
%
% Author:Salomon Eliasson

grdimage = sprintf('grdimage');

%location of file
if isfield(in,'file')
    grdimage = sprintf('%s %s.grd',grdimage,in.file);
else error('needs in.file')
end

% selects portrait
grdimage=sprintf('%s -P',grdimage);

%lat lon bounds
if isfield(in,'region')
    grdimage = sprintf('%s -R%s',grdimage,in.region);
else error('needs in.region (plot region)')
end

%projection type
if isfield(in,'proj')
    grdimage = sprintf('%s -J%s',grdimage,in.proj);
else error('needs in.proj (projection)')
end

%title of plot
if isfield(in,'title')
    grdimage = sprintf('%s -B0g0/0g0:."%s":',grdimage,in.title);
end

grdimage = sprintf('%s -Ya5',grdimage);

%colortable
if isfield(in,'cptfile')
    grdimage = sprintf('%s -C%s',grdimage,in.cptfile);
else error('needs colortable (in.cptfile)')
end

% assuming more pscode will be appended later
grdimage = sprintf('%s -K',grdimage);

%Use nearestneigbour interpolation, only use the nearest grid point
%Otherwise the default bicubic interpolation introduces artifacts.
grdimage = sprintf('%s -S-n/0',grdimage);

ut = sprintf('%s.ps',in.file);
command = sprintf('%s >> %s',grdimage,ut);