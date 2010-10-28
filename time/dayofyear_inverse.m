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
% 2010-10-11 Improved by Gerrit
%
% $Id$

if doy > daysinyear(year)
    error('atmlab:dayofyear_inverse', 'too many days')
end

[yr mn day] = jd2date(date2jd(double(year), 1, 0) + double(doy));
out.year = yr;
out.month = mn;
out.day = day;
out.dayofyear = doy;