% APIHELP_TIME   Handling of time formats
%
%    The function converts different input formats, to the format expected
%    by the WebApi. 
%
%    Valid formats are MJD and UTC.
%
%    Exampel on valid UTC strings are '2010-10-01' and '2015-01-04T11:12:13Z'
%
% FORMAT  timestr = apihelp_time( inputtime )
%
% OUT   timestr    A string.
%  IN   inputtime  A valid time, see above. A scalar.

% 2017-08-18  Patrick Eriksson


function timestr = apihelp_time( inputtime )


if ischar( inputtime )
  %
  timestr = inputtime;

elseif isscalar(inputtime)
  %
  timestr = mjd2string( inputtime );
  
else
  %
  error( 'Unrecognised formtat of *inputtime*' );
  
end