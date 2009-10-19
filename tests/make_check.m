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
y0 = [ 4.115 27.94 ];  % Selected to fit all of three first tests
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



%= Qarts1
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




%= Qarts with DOIT
%
y0 = [ 152.52 -0.21 ];
dy = 1e-2;
%
try
  [Q,f,ztan,y_c,y] = qarts_scattering_demo;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_doit_demo* ===\n\n');
  rethrow(lasterror);
end
%
if any( abs( y(end+[-1:0])' - y0 ) > dy )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_scattering_demo* with DOIT.');
end



%= Qarts with MC
%
y0 = [ 150.3 -0.1 ];
%
try
  [Q,f,ztan,y_c,y,dy] = qarts_scattering_demo( [], 1 );
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *qarts_doit_demo* ===\n\n');
  rethrow(lasterror);
end
%
ind = length(y) + [-1:0];
if any( abs( y(ind)' - y0 ) > 3*dy(ind)' )
  reset_verbosity( va, vf );
  error('Unexpected result from *qarts_scatting_demo* with MC');
end


%= OEM
%
try
  X = arts_oem_demo;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *arts_oem_demo* ===\n\n');
  rethrow(lasterror);
end
%
if X.cost(end) > 1.3
  reset_verbosity( va, vf );
  error('Unexpected result from *arts_oem_demo*');  
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