function cptfile = makecpt(in)
% MAKECPT appends options to GMT makecpt
%
% PURPOSE: Appends options to a short script and calls the GMT
% 
% IN      struct           options here (see help gmt_plot)
% OUT     %s               filename of colortable/file
%
% NOTE    list of colortables found at /usr/lib/gmt/share/cpt/
%
% Created by Salomon Eliasson
% $Id$ 

mkcpt = sprintf('makecpt -C%s',in.ctable);

if isfield(in,'tickval')
    mkcpt = sprintf('%s -T%s/tickvalues.txt',mkcpt,gmtlab('OUTDIR'));
else
    mi = in.datarange(1);
    mx = in.datarange(2);
    step = in.stepsize;
    mkcpt = sprintf('%s -T%f/%f/%f',mkcpt,mi,mx,step);
end

if isfield(in,'color_nan')
    mkcpt = sprintf('%s --COLOR_NAN=%s',mkcpt,in.color_nan);
end
if isfield(in,'color_background')
    mkcpt = sprintf('%s --COLOR_BACKGROUND=%s',mkcpt,in.color_background);
end
if isfield(in,'color_foreground')
    mkcpt = sprintf('%s --COLOR_FOREGROUND=%s',mkcpt,in.color_foreground);
end
cptfile = sprintf('%s/ctable.cpt',in.outdir);
command = sprintf('%s > %s',mkcpt,cptfile);

exec_gmt_cmd(command,in.verbosity);