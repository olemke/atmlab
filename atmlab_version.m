% Returns or prints the Atmlab version number. 
%
%    If there is no output argument, a message is printed to the screen.
%
%    This file shall be modified at each commit of Atmlab.
%
% FORMAT   s = atmlab_version
%        
% OUT   s   Version string

% 2002-12-09   Created by Patrick Eriksson.


function s = qpack_version


nr1 = 0;
nr2 = 0;
nr3 = 6;


s = sprintf('atmlab-%d.%d.%d',nr1,nr2,nr3);

if ~nargout
  
  fprintf('This is %s\n',s);
  clear s

end

