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

[s,r] = arts( ['-d ',wsv] );

if s
  g = NaN;
else
   
  i = strfind( r, 'Group = ' );
  
  if isempty(i)
    error( 'Did not manage to locate group information' ); 
  end

  r = r(i+8:end);

  rb = find( double(r) == 10 );

  group = deblank( r(1:rb(1)) );
end