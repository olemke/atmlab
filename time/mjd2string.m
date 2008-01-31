% MJD2STRING   Converts a MJD value to a date string
%
% FORMAT   s = mjd2string( mjd [, onlyday] )
%        
% OUT   s          Date string.
% IN    mjd        Modified julian date.
% OPT   onlydate   Do not include hours, minutes and seconds.


% 2007-12-07   Created by Patrick Eriksson.


function s = mjd2string( mjd, onlyday )

[year,month,day,h,m,s] = mjd2date( mjd );


if nargin == 1  |  ~onlyday
  s = sprintf( '%d-%d-%d %d:%d:%.0f', year,month,day,h,m,s );
else
  s = sprintf( '%d-%d-%d', year,month,day );
end