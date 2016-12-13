% SMRAPI_TIME   Handling of time formats
%
%    The function converts different input formats, to the format expected
%    by the WebApi. The input can contain multiple times, but the output is
%    always a single time. 
%
%    So far only dates can be specified, i.e. hours and minutes are not
%    handled/ignored. 
%
%    Valid formats are
%
%    UTC as a string, e.g. '2010-10-01'
%
%    Multiple UTC are given as an array of strings.
%
%    One or several MJD as a scalar or vector, e.g. 57370.53
%
% FORMAT  timestr = smrapi_time( inputtime, i )
%
% OUT   timestr    A string.
%  IN   inputtime  A valid time, see above.
%       i          What input element to convert. Must always be specified
%                  (shall be 1 for scalar UTC).

% 2016-11-30  Patrick Eriksson


function timestr = smrapi_time( inputtime, i )


if ischar( inputtime )
  %
  assert( i == 1 );
  timestr = inputtime;

elseif iscellstr( inputtime )
  %
  timestr = inputtime{i};
  
else
  %
  timestr = mjd2string( inputtime(i), true );
  
end