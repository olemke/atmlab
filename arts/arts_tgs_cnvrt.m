% ARTS_TGS_CNVRT   Convert tag group information 
%
%    The function convert tag groups description between Atmlab and ARTS
%    formats. The ARTS format is a string, with each group inside " " and
%    group items seperated with commas. Tag groups are stored in Atmlab as
%    a nested cell array. The primary length of the array corresponds to the
%    the number of tag groups. The length of the array for each group
%    is determined by the number of items. An example for the Atmlab version:
%       TGS{1}{1} = 'ClO';
%       TGS{2}{1} = 'O3';
%       TGS{3}{1} = 'H2O';
%       TGS{3}{2} = 'H2O-MPM89';
%    which in ARTS is:
%       "ClO","O3","H2O,H2O-MPM89"
%
%    The function performs conversion in both directions, where the input
%    format is determined by the type of the input argument *a*.
%
% FORMAT   b = arts_tgs_cnvrt( a )
%        
% OUT   b   Tag group information in output format.
% IN    a   Tag group information in input format.

% 2004-09-08   Created by Patrick Eriksson.


function b = arts_tgs_cnvrt( a )


if ischar( a )
  %
  ind = find( a == '"' );
  if isodd( length(ind) )
    error('This is not a valid ARTS tag group string (odd number of ")');
  end
  %
  for i = 1 : 2 : length(ind)
    s = a( (ind(i)+1) : (ind(i+1)-1) );
    ind2 = [0 find( s == ',' ) length(s)+1];
    for j = 1 : (length(ind2)-1)
      b{round(0.5+i/2)}{j} = s( (ind2(j)+1) : (ind2(j+1)-1) );
    end
  end

elseif iscell( a )
  %
  if ~iscell( a{1} )
    error( ...
   'Species tags in Atmlab shall be given as a nested cell array of strings.');
  end
  %
  b = '';
  %
  for i = 1 : length( a )
    %
    b = [ b, '"' ];
    %
    for j = 1 : length( a{i} )
      %
      if any( a{i}{j} == ',' )
        error( sprintf( ['Tag definitions like ''H2O,H2O-MPM89'' are not ',...
          'allowed in qarts. Type help arts_tgs_cnvrt and see TGS{3} for ',...
          'the correct way to input such a case. Incorrect choice here ',...
          'is: %s'], a{i}{j} ) );
      end
      b = [ b, a{i}{j} ];
      if j < length( a{i} )
        b = [ b, ',' ];
      end
    end
    %
    b = [ b, '"' ];
    if i < length( a )
      b = [ b, ',' ];     
    end
  end

else
  error('Input must be string or cell array.');
end