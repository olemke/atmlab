% ATMLAB_VERSION   Atmlab version number. 
%
%    Version number taken from the ChangeLog file.
%
%    If there is no output argument, a message is printed to the screen.
%
% FORMAT   s = atmlab_version
%        
% OUT   s   Version string

% 2002-12-09   Created by Patrick Eriksson.

function s = atmlab_version

% Version information now taken from ChangeLog   

toppath = fileparts( fileparts( which( 'atmlab_version' ) ) );

changelog = fullfile( toppath, 'ChangeLog' );

fid = fopen( changelog, 'r' );

if fid < 0
  s = 'atmlab-?.? (could not locate ChangeLog file)';
  return
end

s = '';
%
while isempty( findstr( s, 'atmlab-' ) )
  s = fgetl( fid );
  if ~ischar(s)
    error( 'Could not find any ''atmlab-'' in ChangeLog' );
  end
end
%
fclose(fid);


s = s( findstr(s,'atmlab-') : end );

ind = find( s == '-' );

s(ind(2:end)) = '.';

if ~nargout
  
  fprintf('This is %s\n',s);
  clear s

end

