function utc_datestr = iso_timestamp()

% iso_timestamp Return string with current ISO date-time.
%
% Returns a string representing the full current date/time in UTC
% according to ISO 8601, in connected format. E.g.
% 
% iso_timestamp() = '2012-01-31T10:49:32Z'
%
% FORMAT
%
%    s = iso_timestamp()
%
% IN (none)
%
% OUT s     string (character-array) with ISO time

% $Id$

utc_time = java.lang.System.currentTimeMillis;
[utc_date{1:6}] = unixsecs2date(utc_time/1000);
utc_datestr = sprintf('%04d-%02d-%02dT%02d:%02d:%02dZ', ...
    [utc_date{1:5} round(utc_date{6})]);

end
