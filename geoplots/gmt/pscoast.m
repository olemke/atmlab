function command = pscoast(in)
% PSCOAST appends options to GMT pscoast
%
% PURPOSE:  Appends options to a short script and calls the GMT
%
% IN
%       in        struct          options here (see help gmt_plot)
%
% OUT   command   %s              string command to be used in system call
%
% Created by Salomon Eliasson
% $Id$

ps_coast = 'gmt pscoast -R -J -X -Y';

C=in.pscoast;

default.features   = 1000;  % nothing smaller than 1000km^2
default.resolution = 'l'; % low
default.rivers     = 'r'; % All major rivers
default.width      = '0.3p';
default.color      = in.color_background;

C = optargs_struct(C,default);
% set the minimal area of features to plot

%Draw shorelines. Append attributes [Defaults: width = 1, color = black, texture = solid].
ps_coast = sprintf('%s -W%s,%s',ps_coast,C.width,C.color);

ps_coast = sprintf('%s -A%g',ps_coast,C.features);
ps_coast = sprintf('%s -D%s',ps_coast,C.resolution);
for i = 1:length(C.rivers)
    % thickness is left empty ('before ',')
    ps_coast = sprintf('%s -I%s/,%s',ps_coast,num2str(C.rivers(i)),C.color);
end

% temporary fix for me
if strcmp(hostname,'c20628')
    ps_coast = sprintf('%s --DIR_GSHHG=/usr/share/gshhg-gmt-nc4/',ps_coast);
end

% selects Overlay plot mode and assuming more pscode will be appended
ps_coast = sprintf('%s -O -K',ps_coast);

command = sprintf('%s >> %s.ps',ps_coast,in.filename);
