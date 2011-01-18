function cptfile = makecpt(se)
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
% $Author$
% $Date$

mkcpt = sprintf('makecpt -C%s',se.ctable);

mi = se.datarange(1);
mx = se.datarange(2);
step = se.stepsize;
mkcpt = sprintf('%s -T%d/%d/%d',mkcpt,mi,mx,step);

if isfield(se,'color_nan')
    mkcpt = sprintf('%s --COLOR_NAN=%s',mkcpt,se.color_nan);
end
if isfield(se,'color_background')
    mkcpt = sprintf('%s --COLOR_BACKGROUND=%s',mkcpt,se.color_background);
end
if isfield(se,'color_foreground')
    mkcpt = sprintf('%s --COLOR_FOREGROUND=%s',mkcpt,se.color_foreground);
end
cptfile = 'ctable.cpt';
command = sprintf('%s > %s',mkcpt,cptfile);

exec_gmt_cmd(command);