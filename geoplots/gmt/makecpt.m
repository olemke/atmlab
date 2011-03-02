function cptfile = makecpt(in)
%% makecpt
%
% purpose:  
%       Appends options to a short script and calls the GMT
%       command makecpt.
% 
% se: structure: fields = 'datarange', 'ctable'
%
% list of colortables found at /usr/lib/gmt/share/cpt/
%
% 2011-02-22 created by Salomon Eliasson

mkcpt = sprintf('makecpt -C%s',in.ctable);

mi = in.datarange(1);
mx = in.datarange(2);
step = in.stepsize;
mkcpt = sprintf('%s -T%f/%f/%f',mkcpt,mi,mx,step);

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