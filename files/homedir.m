% HOMEDIR   Returns users home directory
%
% FORMAT   d = homedir
%        
% OUT   d   String with path of home directory.

% 2009-05-24   Created by Patrick Eriksson.


function d = homedir

persistent dp;

if isempty(dp)

  d = getenv('HOME');

  if isempty(d)
    error('atmlab:homedir', 'No home-directory defined');
  end

  dp = d;
  
else
  d = dp;
end