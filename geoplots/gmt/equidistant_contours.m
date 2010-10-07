function[tickval,prtstr] = equidistant_contours(minn,maxx,nlevels)
%%  equidistant_contours
% 
% Purpose: 
%          Creates an equidistant contour levels array, an array
%          of equidistant color values and a format string
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
%  $Id$

%necessity
if minn==maxx,maxx=maxx+1;end

%step sizes
inc = (maxx - minn) /nlevels; 

% determine tickvalues
tickval = minn:inc:maxx;

% determine formatstring
prtstr = sprintf('%s',sprintf('%%3.%1.0ff',testsize(maxx))); % currently just using the maximum

function out  = testsize(val)
% crude test the size of the value to determine string
% 

if val >10^2
    out = 0;
elseif val >10^1
    out = 1;
elseif val >10^0
    out = 2;
else
    out = 3;
end