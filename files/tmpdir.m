% TMPDIR   Get path of temporary directory
%
%    An alternative to Matlab's function *tempdir*. 
%
%    This function checks if there is TMPDIR is defined as an enironment
%    variable. If yes, the value of TMPDIR is returned. Otherwise tempdir is
%    called and that results is returned.
%
%    Note that the function uses an internal persistent variable and TMPDIR
%    must be set before calling this function for the first time of a session.
%
% FORMAT   tdir = tmpdir
%        
% OUT   tdir   String with path of home directory.

% 2016-08-24   Created by Patrick Eriksson.


function tdir = tmpdir

persistent tp;

if isempty(tp)

  tdir = getenv('TMPDIR');
  
  if isempty( tdir )
    tdir = tempdir;
  else
    if (tdir(end) ~= filesep)
        tdir = [tdir filesep];
    end    
  end
  
  tp = tdir;
  
else
  tdir = tp;
end