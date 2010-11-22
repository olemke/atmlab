function cptfile = makecpt(se)
%% makecpt
%
% purpose:  
%       Appends options to a short script and calls the GMT
%       command makecpt.
%
% list of colortables found at /usr/lib/gmt/share/cpt/
%
% $Author$
% $Date$

makecpt = sprintf('makecpt');
if isfield(se,'ctable')
  makecpt = sprintf('%s -C%s',makecpt,se.ctable);
else
  makecpt = sprintf('%s -Crainbow',makecpt);
end
if ~isfield(se,'nlevels')
  se.nlevels = 15;
end
if isfield(se,'datarange')
  mi = se.datarange(1);
  mx = se.datarange(2);
  step = (mx-mi)/se.nlevels;
  makecpt = sprintf('%s -T%d/%d/%d',makecpt,mi,mx,step);
 else
   error 'need the the min & max values of the data'
end

cptfile = 'ctable.cpt';
command = sprintf('%s > %s',makecpt,cptfile);

exec_gmt_cmd(command)