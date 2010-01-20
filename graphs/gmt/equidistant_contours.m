function[tickval,prtstr] = equidistant_contours(minn,maxx,nlevels)
%%  equidistant_contours
% 
% Purpose: 
%          Creates an equidistant contour levels array, an array
%          of equidistant color values and a format string
%  In/outdata:
%          IN:
%          minn = minimum field value
%          maxx = maximum field value
%          nlevels = number of contour levels
%
%          OUT:
%          array of contour levels and the format string to use (depends on
%          the size of the steps)
%
%  Author: Salomon Eliasson

if minn==maxx,maxx=maxx+1;end
inc = (maxx - minn) /nlevels; %step sizes
smalltest = 0;
while smalltest >= 0 % the whileloop is for determining the format
    x = minn;
    brk = 0;
    for ii = 1:nlevels +1
        tickval(ii) = x;
        x = x + inc;
        if ii > 1
            if round(tickval(ii)*10^smalltest ) - round(tickval(ii-1)*10^smalltest) < 1
                smalltest = smalltest + 1;
                brk = 1;
                break
            end
        end
    end
    if brk == 0
        % the final format
        prtstr = strcat('%3.',num2str(smalltest),'f');
        smalltest = -1; %if it makes it here
    end
end %while