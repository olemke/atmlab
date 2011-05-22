% ARTS_OEM   Interface between *oem* and the ARTS forward model
%
%    See *arts_oem_init* for usage of this function.
%
% FORMAT   [R,y,J] = arts_oem( Q, R, x, iter )
%        
% OUT   R      Retrieval data structure. See above.
%       y      Calculated measurement vector.
%       J      Jacobian.
% IN    Q      Qarts structure, as returned by *arts_oem_init*.
%       R      Retrieval data structure. See above.
%       x      State vector.
%       iter   Iteration number. The case of x = xa is treated as iter=1. If 
%              another initial linearisation point is used, iter must be set
%              to >= 2.

% 2010-01-11   Started by Patrick Eriksson.


function [R,y,J] = arts_oem( Q, R, x, iter )


% Checks done *arts_oem_init* are not repeated here


%--- Map x to variables ----------------------------------------------

if iter > 1
  [Q,R] = arts_x2QR( Q, R, x );
end


%--- Run ARTS --------------------------------------------------------

if nargout == 3
  do_j  = 1;
  cfile = R.cfile_yj;
else
  do_j  = 0;
  cfile = R.cfile_y;
end
%
arts( cfile );
%
y = xmlLoad( fullfile( R.workfolder, 'y.xml' ) );
%
if do_j  
  J = xmlLoad( fullfile( R.workfolder, 'jacobian.xml' ) );
end


%- Add baseline (should be moved to arts)
%
if iter > 1
  y = y + R.bl;
end

