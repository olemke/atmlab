% ARTS_TGS2SPECIES  Extracts species name from tag definitions
%
%    Returns species (or isotopomer) name. For example,
%    'H20-161-501e9-505e9' is converted to 'H2O' or 'H2O-161', depending on
%    status of *iso*.
%
% FORMAT   species = arts_tgs2species( a, iso )
%        
% OUT   species   Species names. Returned as a cell array with strings.
% IN    a         Tag group information, either in arts1 or arts format. See
%                 arts_tgs_cnvrt for format descriptions.
% OPT   iso       Include isotopomer numbers. Default is false.

% 2007-05-14   Created by Patrick Eriksson.


function species = arts_tgs2species( a, iso )


if nargin < 2
  iso = 0;
end
  

if ischar( a )
  a = arts_tgs_cnvrt( a );
end



for it = 1 : length(a)
  for is = 1 : length(a{it})

    ind = find( a{it}{is} == '-' );

    % Expand to cover all possible cases
    ind = [ ind repmat(length(a{it}{is})+1,1,2) ];
  
    if ~iso 
      species{it}{is} = a{it}{is}(1:ind(1)-1);
    else
      species{it}{is} = a{it}{is}(1:ind(2)-1);
    end   
  end   
end  
