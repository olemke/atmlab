% MJD2MONTH   Conversion of MJD to month  
%
%    Calculates the month by combining *mjd2date* and  *dayofmonth*. 
%    Fractional part of month is kept. Jan 15 is about 1.5.
%
% FORMAT   m = mjd2month(mjd)
%        
% OUT   m     Month number.
% IN    mjd   Modified julian date. Can be a vector.

% 2006-03-31   Created by Patrick Eriksson.

function m = mjd2month(mjd)

[year, month, day, hour, minute, second] = mjd2date( mjd );

%= *dayofyear* does not handle column vectors
%
if isvector(year) & length(year) > 1
  year   = vec2row( year );
  month  = vec2row( month );
  day    = vec2row( day );
  hour   = vec2row( hour );
  minute = vec2row( minute );
  second = vec2row( second );
end

m = monthofyear( year, month, day, hour, minute, second );