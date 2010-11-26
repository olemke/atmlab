function[tickval,prtstr] = equidistant_contours(range,nlevels)
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
% $Author$
% $Date$ 

%necessity
minn = range(1);maxx = range(2);
if minn==maxx,maxx=maxx+1;end

%step sizes
inc = (maxx - minn) /nlevels; 

% determine tickvalues
tickval = minn:inc:maxx;

% determine formatstring
prtstr = '%d';