% ARTS_TGS2SPECIES  Extracts species name from tag definitions
%
%    Returns species (or isotopomer) name. For example,
%    'H20-161-501e9-505e9' is converted to 'H2O' or 'H2O-161', depending on
%    status of *iso*. 
% 
%    Note that the internal arts format is not handled here (as in 
%    *arts_tgs_cnvrt*). A string input is here interpreted as a single tag.
%
%    Two main ways to call this function:
%       arts_tgs2species(Q.ABS_SPECIES)
%       arts_tgs2species(Q.ABS_SPECIES{1}{1})
%
% FORMAT   species = arts_tgs2species( a, iso )
%        
% OUT   species   Species names. Returned as a cell array with strings or a 
%                 plain string, depending on format of *a*.
% IN    a         Tag group information. A single tag can be given as a
%                 plain string. Output is then also a plain string. 
%                 Multiple tags given in the atmlab format *arts_tgs_cnvrt*.
% OPT   iso       Include isotopomer numbers. Default is false.

% 2007-05-14   Created by Patrick Eriksson.


function species = arts_tgs2species( a, iso )


if nargin < 2
  iso = 0;
end
  

if ischar( a )
  a           = { { a } };
  return_char = 1;
else
  return_char = 0;
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


if return_char
  species = species{1}{1};
end
