function [command,PT] = pstext(in,count)
% PSTEXT Make text to overlay GMT plot
% (x, y, size, angle, fontno, justify, text) see help gmt_plot
% IN      file     %s       file to append to
%         in       struct   options here (see help gmt_plot)
%         placement %s      string command about where to pu the map
%         (common to all commands)
%
% OUT     command str     string command for systemcall of pstext
%
% Created by Salomon Eliasson
% $Id$

assert(all(isfield(in.pstext,{'text','lat','lon'})),['gmtlab:' mfilename ':BadInput'],...
    '''text'',''lat'',''lon'' are the minimum input requirements for in.pstext')

if nargin==1, count = 1; end

% set some defaults
default.fontsize= '20p';   % text size in points
default.angle   = 0;       % degrees counter-clockwise from horizontal
default.font = 1;          % sets the font type
default.justify = 'CM';     % sets the alignment
default.color   = '0/0/0'; % textcolor (black)

PT = optargs_struct(in.pstext,default);

txtfile = ['pstextfile' num2str(count)];
fid=fopen(txtfile,'w');
cleanup = onCleanup(@() fclose(fid));
    
% Create an intermediate file that contains the required input per
fprintf(fid,'%g\t%g\t%s,%s,%s\t%g\t%s\t%s',...
    PT.lon,PT.lat,PT.fontsize,num2str(PT.font),PT.color,PT.angle,num2str(PT.justify),PT.text);

% -N means don't clip the text
command = sprintf('gmt pstext %s -F+f+a+j -N -R -J -K -O %s >> %s.ps',txtfile,in.plotPlacement,in.filename);

end