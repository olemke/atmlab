% JI2M  Converts ARTS *ji* to a 2 column matrix.
%
% FORMAT   mji = ji2m( ji )
%        
% OUT   mji   Jacobian indexes as a 2 column matrix
% IN    ji    Jacobian indexes as read from ARTS. That is, an 
%             ArrayOfArrayOfIndex.

% 2006-09-29   Created by Patrick Eriksson.


function mji = ji2m( ji )


rqre_datatype( 'cell', ji )

mji = zeros( length(ji), 2 );

for i = 1:length(ji)

  if length(ji{i}) ~= 2
    error( 'Each element of *ji* must hold two values.' );
  end

  mji(i,1) = ji{i}{1};
  mji(i,2) = ji{i}{2};

end


