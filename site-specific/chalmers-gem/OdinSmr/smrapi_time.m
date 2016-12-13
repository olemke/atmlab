% SMRAPI_TIME   Handling of time formats
%
%    The function converts different input formats, to the format expected
%    by the WebApi.
%
%    So far only dates can be specified, i.e. hours and minutes are not
%    handled/ignored. 
%
%    Valid formats are
%
%    UTC as a string, e.g. '2010-10-01'
%
%    MJD as a scalar, e.g. 57370.53
%
% FORMAT  timestr = smrapi_time( inputtime )
%
% OUT   timestr    A string.
%  IN   inputtime  A valid time, see above.

% 2016-11-30  Patrick Eriksson


function timestr = smrapi_time( inputtime )


if ischar( inputtime )
  %
  timestr = inputtime;

else
  %
  timestr = mjd2string( inputtime, true );
  
end