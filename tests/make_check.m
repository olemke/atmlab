% MAKE_CHECK   Performs a check of Atmlab - ARTS
%
% FORMAT   make_check

% 2005-06-21   Created by Patrick Erikssom.


function make_check


%= Handle verbosity
%
va = atmlab( 'VERBOSITY' );
vf = atmlab( 'FMODEL_VERBOSITY' );
%
atmlab( 'VERBOSITY', 0 );
atmlab( 'FMODEL_VERBOSITY', 0 );





%= Qarts
%
y0 = [ 4.107 27.918 ];
dy = 1e-2;
%
try
  [Q,f,y] = qarts_demo;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_demo* ===\n\n');
  rethrow(lasterror);
end
%
if any( abs( [min(y) max(y)] - y0 ) > dy )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_demo*');
end
%
try
  [Q,f,y] = qarts_demo2;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_demo* ===\n\n');
  rethrow(lasterror);
end
%
if any( abs( [min(y) max(y)] - y0 ) > dy )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_demo2*');
end



%= Qarts with DOIT
%
y0 = [ 152.47 -0.21 ];
dy = 1e-2;
%
try
  [Q,f,ztan,y_c,y,dy] = qarts_scattering_demo;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_doit_demo* ===\n\n');
  rethrow(lasterror);
end
%
if any( abs( y(end+[-1:0])' - y0 ) > dy )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_doit_demo*');
end



%= Qarts with MC
%
y0 = [ 152.47 -0.21 ];
%
try
  [Q,f,ztan,y_c,y,dy] = qarts_scattering_demo([],1);
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_doit_demo* ===\n\n');
  rethrow(lasterror);
end
%
if any( abs( y(end+[-1:0])' - y0 ) > dy )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_doit_demo*');
end




% Parts not updated
if 0

%= Qarts1
%
y0 = [ 4.119 27.914 ];
dy = 1e-3;
%
try
  [Q,f,y] = qarts1_demo;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts1_demo* ===\n\n');
  rethrow(lasterror);
end
%
if any( abs( [min(y) max(y)] - y0 ) > dy )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts1_demo*');
end



%= Jacobian calculations
%
try
  [Q,f,y,J,ji] = qarts_jacobian_demo( 30e3, 1 );
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_jacobian_demo* ===\n\n');
  rethrow(lasterror);
end
%
yj = J*ones(size(J,2),1);
yj = yj + mean(y) - mean(yj);
%
if any( abs( (yj-y)./y ) > 0.06 )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_jacobian_demo*');
end

end


%== Finished
%
reset_verbosity( va, vf );
%
fprintf('\n=== OK ===\n\n'); 
%
return




%-----------------------------------------------------------------------------

function reset_verbosity( va, vf )
  atmlab( 'VERBOSITY', va );
  atmlab( 'FMODEL_VERBOSITY', vf );
return