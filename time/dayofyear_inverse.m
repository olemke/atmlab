function out = dayofyear_inverse(year,doy)
%% day_of_year_inverse
%  
% Purpose: It's just the opposite of dayofyear, i.e. if you have the day of year
% and want the month and day.
%
% IN: 1) year, 2) dayofyear e.g dayofyear_inverse(2006, 300)
%
% OUT: structure containing e.g.
%
%  out =    yr: 2006
%           mn: 10
%          day: 27
%    dayofyear: 300
%
% 27/8-2010 Salomon Eliasson
if doy > daysinyear(year)
    error('too many days')
end

mn=1;
day=1;
k=1;
while k < doy
    if eomday(year,mn)==day
        mn=mn+1;
        day = 1;
    else day = day+1; 
    end
    k = k+1;
end

out.yr = year;
out.mn = mn;
out.day = day;
out.dayofyear = k;