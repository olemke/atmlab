% MAKE_CHECK   Performs a check of different parts of Atmlab and arts-2
%
%    The function runs some of the scripts in atmlab/demo and perform some
%    special tests (placed in atmlab/tests). The scripts perform tests of atmlab,
%    but make also some additional tests of arts-2. For example, that different
%    jacobian calculation/retrieval options give consistent results.
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
y0 = [ 4.115 27.94 ];  % Selected to fit both tests
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
y0 = [ 152.52 -0.21 ];
dy = 1e-2;
%
try
  [Q,f,ztan,y_c,y] = qarts_scattering_demo( [], 'doit' );
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
  [Q,f,ztan,y_c,y,dy] = qarts_scattering_demo( [], 'mc' );
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



%= Jacobian tests
%
try
  test_arts_jacobians;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *test_arts_jacobians* ===\n\n');
  rethrow(lasterror);
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



%= Qpack2
%
try
  test_qpack2;
catch
  reset_verbosity( va, vf );
  fprintf('\n=== Error while running *test_qpack2* ===\n\n');
  rethrow(lasterror);
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