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

pscoast = sprintf('gmt pscoast -R -J %s',in.plotPlacement);

C=in.pscoast;

default.features   = 1000;  % nothing smaller than 1000km^2
default.resolution = 'l'; % low
default.rivers     = 'r'; % All major rivers
default.width      = '0.3p';
default.color      = in.color_background;

C = optargs_struct(C,default);
% set the minimal area of features to plot

%Draw shorelines. Append attributes [Defaults: width = 1, color = black, texture = solid].
pscoast = sprintf('%s -W%s,%s',pscoast,C.width,C.color);

pscoast = sprintf('%s -A%g',pscoast,C.features);
pscoast = sprintf('%s -D%s',pscoast,C.resolution);
for i = 1:length(C.rivers)
    % thickness is left empty ('before ',')
    pscoast = sprintf('%s -I%s/,%s',pscoast,num2str(C.rivers(i)),C.color);
end

% selects Overlay plot mode and assuming more pscode will be appended
pscoast = sprintf('%s -O -K',pscoast);

command = sprintf('%s >> %s.ps',pscoast,in.filename);