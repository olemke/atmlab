function cptfile = makecpt(se)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% purpose:  
%       Appends options to a short script and calls the GMT
%       command makecpt.
%
% list of colortables found at /usr/lib/gmt/share/cpt/
%
% Author:Salomon Eliasson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  mi = se.datarange.min;
  mx = se.datarange.max;
  step = (mx-mi)/se.nlevels;
  makecpt = sprintf('%s -T%d/%d/%d',makecpt,mi,mx,step);
 else
   error 'need the the min & max values of the data'
end

cptfile = 'ctable.cpt';
command = sprintf('%s > %s',makecpt,cptfile);

fprintf('%s\n',command)

[test,message] = system(command);
if test ~= 0
  error (message)
end

