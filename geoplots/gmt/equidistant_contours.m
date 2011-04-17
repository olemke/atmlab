function[tickval,prtstr] = equidistant_contours(range,nlevels)
% EQUIDISTANT_CONTOURS equidistant contour levels array and a format string
% 
% Purpose: 
%          Creates an equidistant contour levels array and a format string to
%          be used with makecpt
%
%  In/outdata:
%          IN:
%          minn = minimum data value
%          maxx = maximum data value
%          nlevels = number of contour levels
%
%          OUT:
%          array of contour levels and the format string to use (depends on
%          the size of data values)
%
% Created by Salomon Eliasson
% $Id$


%necessity
minn = range(1);maxx = range(2);
if minn==maxx,maxx=maxx+1;end

%step sizes
inc = (maxx - minn) /nlevels; 

% determine tickvalues
tickval = minn:inc:maxx;

% determine formatstring
prtstr = '%.12d';