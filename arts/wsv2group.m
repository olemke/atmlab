% WSV2GROUP   Determines the ARTS group of a workspace variable
%
%    The function calls ARTS (with -d) and parse the output to determine the
%    group. 
%
%    For example, wsv2group('p_grid) gives 'Vector'
%
% FORMAT   group = wsv2group(wsv)
%
% IN    wsv     Name of workspace variable, as a string
% OUT   group   Name of group, as a string

% 2020-01-23 Patrick Eriksson


function group = wsv2group(wsv)

try 
  [s,r] = arts( ['-d ',wsv] );
catch
  error( sprintf('*%s* seems not to be a standard ARTS WSV.', wsv) );    
end


i = strfind( r, 'Group' );
  
if isempty(i)
  error( 'Did not manage to locate group information in ARTS output!' ); 
end

r = r( i+5 : end );   % Cuts just after Group
i = strfind( r, '=' );
r = r( i+1 : end );   % Cuts just after first =

rb = find( double(r) == 10 );  % Finds linefeeds

group = strtrim( r(1:rb(1)-1) );
