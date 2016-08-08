function file = makecpt(in)
% MAKECPT appends options to GMT makecpt
%
% PURPOSE: Appends options to a short script and calls the GMT
%
% IN      struct           options here (see help gmt_plot)
%
% NOTE    list of colortables found at /usr/lib/gmt/share/cpt/
%
% Created by Salomon Eliasson
% $Id$

mkcpt = sprintf('gmt makecpt -C%s',in.ctable.name);

if isfield(in,'tickval')
    mkcpt = sprintf('%s -Ttickvalues.txt',mkcpt);
else
    mi = in.datarange(1);
    mx = in.datarange(2);
    step = in.stepsize;
    fstr = sprintf('%s -T%s/%s/%s',mkcpt,...
        getAnnotFormat(mi),getAnnotFormat(mx),getAnnotFormat(step));
    mkcpt = sprintf(fstr,mi,mx,step);
end

if isstruct(in.ctable) & isfield(in.ctable,'reverse') & in.ctable.reverse == 1
    mkcpt = sprintf('%s -I',mkcpt);
end

mkcpt = sprintf('%s --COLOR_NAN=%s',mkcpt,in.color_nan);
mkcpt = sprintf('%s --COLOR_BACKGROUND=%s',mkcpt,in.color_background);
mkcpt = sprintf('%s --COLOR_FOREGROUND=%s',mkcpt,in.color_foreground);

file = 'ctable.cpt';
command = [mkcpt ' > ' file];

exec_system_cmd(command,gmtlab('verbosity'));
