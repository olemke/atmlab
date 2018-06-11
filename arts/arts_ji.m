% ARTS_JI   Calculates "jacobian indices"
%
%   JAcobian indices give the start and end index inside x, for each
%   retrieval quantity. The indices are sored in a format matching the one
%   used inside ARTS.
%
% FORMAT   [y,y_aux,J,jq,ji,y_geo,y_f,y_pol,y_pos,y_los] = arts_y( Q [, workfolder] )
%        
% OUT   ji  Jacobian indices
% IN    jq  Jacobian quantities

% 2018-06-11   Created by Patrick Eriksson.



function ji = arts_ji(jq)

ntot = 0;

for i = 1 : length(jq)

  nnew = 1;
  %
  for j = 1 : length(jq{i}.grids)
    nnew = nnew * length( jq{i}.grids{j} );
  end
  
  ji{i}{1} = ntot + 1;
  ntot     = ntot + nnew;
  ji{i}{2} = ntot;
end