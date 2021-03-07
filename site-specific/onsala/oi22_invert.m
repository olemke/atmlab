% Performs a 22 GHz inversion
%
% FORMAT L2 = oi22_invert(P,R,A,O,io)
%
% OUT   L2   Retrieved data.
% IN    P    Project settings structure
%       R    Retrieval settings structure.
%       A    Atmosphere data structure
%       O    Observation data structure
%       io   Index of case in O to do

% 2021-02-10 Patrick Eriksson


function L2 = oi22_invert(P,R,A,O,io)


%- Take forward model part of Q from y-function
%
Q = oi22_y( P, A, O, io, true );


%-------------------------------------------------------------------------
%- Phase 1: Iterate to adjust lower troposphere
%-------------------------------------------------------------------------
%
itest          = [1:R.phase1_ntest size(O.tb,1)+[-R.phase1_ntest+1:0]];
Qy             = Q;
Qy.J           = [];
Qy.WSMS_AT_END = { 'yCalc', '<OUTPUT> y' };
iter           = 1;
%
while R.phase1_do
  U   = qarts3_run( Qy, P.workfolder );
  dtb = mean( U.y(itest) - O.tb(itest,io) );
  if R.show_plots
    figure(1)
    plot( O.freq/1e9, O.tb(:,io), O.freq/1e9, U.y );
    title( sprintf('Case %d: phase 1, iteration %d', io, iter ) );
    xlabel( 'Frequency [GHz]' ), ylabel( 'Tb [K]' ), 
    drawnow
  end  
  %
  if abs(dtb) < R.phase1_dtb
    R.phase1_do = false;
  else
    fac = - dtb / mean(O.tb(itest,io));
    Qy.vmr_field(3,:) = Qy.vmr_field(3,:) .* ( 1 + fac * ...
      ( 1 - linear_transition( R.phase1_bp1, R.phase1_bp2, Q.z_field ) ) )';    
  end
  iter = iter + 1;
end
%
Q.vmr_field = Qy.vmr_field;
clear Qy


%- Remaining part of Q defined in local sub-function
%
Q = set_q_local( Q, P, R, A, O, io );



%-------------------------------------------------------------------------
%- Phase 2: Run OEM with Guass-Newton
%-------------------------------------------------------------------------
%
U = qarts3_run( Q, P.workfolder );
%
if R.show_plots
  %
  l  = length( R.h2o.grid );
  z  = interpp( A.p, A.z, R.h2o.grid );
  p0 = interpp( A.p, A.h2o, R.h2o.grid );
  p1 = interpp( A.p, Q.vmr_field(3,:)', R.h2o.grid );
  p2 = U.x(1:l) .* p1;
  %
  figure(2)
  subplot(2,1,1)
  plot( 1e6*p0, z/1e3, '--', 1e6*p2, z/1e3, '-' );
  axis([0 11 20 90]);
  title( sprintf('Case %d: phase 2, convergence %d', io, U.oem_diagnostics(1) ) );
  xlabel( 'H2O VMR [ppm]' ), ylabel( 'Altitude [km]' );
  %
  subplot(2,1,2)
  semilogx( p0, z/1e3, '--', p1, z/1e3, '-.' , p2, z/1e3, '-' );
  axis([1e-4 0.03 0 9]);
  xlabel( 'H2O VMR [-]' ), ylabel( 'Altitude [km]' );
  legend( 'ERA5+Fascod', 'Phase 1', 'Phase 2', 'Location', 'North' );
  drawnow
end  


%-------------------------------------------------------------------------
%- Phase 3: If not converged, rerun with ML
%-------------------------------------------------------------------------
%
if R.phase3_do & U.oem_diagnostics(1)
  Q.METHOD_String_WSV      = 'ml';
  Q.LM_SETTINGS_Vector_WSV = R.phase3_lm_ga_settings;
  U                        = qarts3_run( Q, P.workfolder );
  %
  if R.show_plots
    %
    p3 = U.x(1:l) .* p1;
    %
    figure(3)
    subplot(2,1,1)
    plot( 1e6*p0, z/1e3, '--', 1e6*p3, z/1e3, '-' );
    axis([0 11 20 90]);
    title( sprintf('Case %d: phase 2, convergence %d', io, U.oem_diagnostics(1) ) );
    xlabel( 'H2O VMR [ppm]' ), ylabel( 'Altitude [km]' );
    %
    subplot(2,1,2)
    semilogx( p0, z/1e3, '--', p2, z/1e3, '-.' , p3, z/1e3, '-' );
    axis([1e-4 0.03 0 9]);
    xlabel( 'H2O VMR [-]' ), ylabel( 'Altitude [km]' );
    legend( 'ERA5+Fascod', 'Phase 2', 'Phase 3', 'Location', 'SouthWest' );
    drawnow
  end  
end


%- Fill L2
%
L2.convergence     = U.oem_diagnostics(1);
L2.cost            = U.oem_diagnostics(3);
L2.cost_y          = U.oem_diagnostics(4);
L2.niter           = U.oem_diagnostics(5);
L2.yfitted         = U.yf;
L2.baseline        = U.y_baseline;
%
L2.h2o_p           = R.h2o.grid;
L2.h2o_z           = interpp( A.p, A.z, L2.h2o_p );
L2.h2o_t           = interpp( A.p, A.t, L2.h2o_p );
L2.h2o_apriori     = interpp( A.p, A.h2o, L2.h2o_p );
L2.h2o_vmr         = U.x(1:l) .* L2.h2o_apriori;
L2.h2o_eo          = U.retrieval_eo(1:l) .* L2.h2o_apriori;
L2.h2o_es          = U.retrieval_ss(1:l) .* L2.h2o_apriori;
L2.h2o_mresp       = sum( U.avk(1:l,1:l), 2 );
L2.h2o_fwhm        = fwhm( L2.h2o_z, U.avk(1:l,1:l) );
%
if R.polyfit.n >= 0
  L2.polyfit_x     = U.x(l+1:end);
  L2.polyfit_eo    = U.retrieval_eo(l+1:end);
  L2.polyfit_es    = U.retrieval_ss(l+1:end);
  L2.polyfit_mresp = diag( U.avk(l+1:end,l+1:end) );
end


%- Plot residual?
%
if R.show_plots
  figure(4)
  plot( O.freq/1e9, L2.yfitted-O.tb(:,io) )
  hold on
  plot( O.freq/1e9, L2.baseline, 'LineWidth', 2 )
  hold off
  xlabel( 'Frequency [GHz]' );
  ylabel( 'Tb [K]' );
  legend( 'Residual', 'Baseline' );
end

return





%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

function Q = set_q_local(Q,P,R,A,O,io);


%- Iteration agenda
%
Q.inversion_iterate_agenda{1} = 'Ignore(inversion_iteration_counter)';
Q.inversion_iterate_agenda{2} = 'x2artsAtmAndSurf';
Q.inversion_iterate_agenda{3} = 'x2artsSensor';
Q.inversion_iterate_agenda{4} = 'yCalc( y = yf )';
Q.inversion_iterate_agenda{5} = 'VectorAddVector( yf, yf, y_baseline )';
Q.inversion_iterate_agenda{6} = 'jacobianAdjustAndTransform';


%- Start description of retrieval quantities
%
Q.J{end+1}               = '#################';
Q.J{end+1}               = 'retrievalDefInit';

%- H2O
%
Q.RGRID_H2O_Vector_WSV   = R.h2o.grid;
Q.J{end+1}               = 'retrievalAddAbsSpecies(';
Q.J{end+1}               = sprintf('  species="%s", unit="rel",', ...
                                   Q.GAS_SPECIES(3).TAG{1} );
Q.J{end+1}               = '  g1=rgrid_h2o, g2=lat_grid, g3=lon_grid )';
%
Q.SX_H2O_Sparse_WSV      = R.h2o.sx;
Q.J{end+1}               = 'covmat_sxAddBlock( block = sx_h2o )';
%
if isfield( R.h2o, 'sxinv' )
  Q.SXINV_H2O_Sparse_WSV = R.h2o.sxinv;
  Q.J{end+1}             = 'covmat_sxAddInverseBlock( block = sxinv_h2o )';
end

%- Polyfit
%
if R.polyfit.n >= 0
  %
  Q.J{end+1} = sprintf( 'retrievalAddPolyfit(poly_order = %d)', R.polyfit.n );
  %
  for i = 0 : R.polyfit.n
    Q.(sprintf('SX_POLY%d_Sparse_WSV',i)) = R.polyfit.sx{i+1};
    Q.J{end+1} = sprintf( 'covmat_sxAddBlock( block = sx_poly%d )', i );
    if isfield( R.polyfit, 'sxinv' )
      Q.(sprintf('SXINV_POLY%d_Sparse_WSV',i)) = R.polyfit.sxinv{i+1};
      Q.J{end+1} = sprintf('covmat_sxAddInverseBlock( block = sxinv_poly%d )',i);
    end   
  end
end

%- Close description of retrieval quantities
%
Q.J{end+1}               = 'retrievalDefClose';
Q.J{end+1}               = '#################';


% Se
%
m                        = size( O.tb, 1 );
cov                      = O.rms(io)^2;
%
Q.SE_Sparse_WSV          = spdiags( repmat(cov,m,1), 0, m, m );
Q.SEINV_Sparse_WSV       = spdiags( repmat(1/cov,m,1), 0, m, m );
%
Q.WSMS_AT_END{end+1}     = 'covmat_seAddBlock( block = se )';
Q.WSMS_AT_END{end+1}     = 'covmat_seAddInverseBlock( block = seinv )';


% OEM
%
Q.METHOD_String_WSV      = 'gn';
Q.DISPLAY_PROGRESS_Index_WSV = R.show_oem;
Q.STOP_DX_Numeric_WSV    = R.phase2_stop_dx;
Q.MAX_ITER_Index_WSV     = R.phase2_max_iter;
Q.LM_SETTINGS_Vector_WSV = zeros(6,1);  % Dummy values
%
Q.y                      = O.tb(:,io);
Q.WSMS_AT_END{end+1}     = 'xaStandard';
Q.WSMS_AT_END{end+1}     = 'VectorSet( x, [] )';
Q.WSMS_AT_END{end+1}     = 'VectorSet( yf, [] )';
Q.WSMS_AT_END{end+1}     = 'MatrixSet( jacobian, [] )';
Q.WSMS_AT_END{end+1}     = 'OEM(         method = method,';
Q.WSMS_AT_END{end+1}     = '   display_progress = display_progress,';
Q.WSMS_AT_END{end+1}     = '            stop_dx = stop_dx,';
Q.WSMS_AT_END{end+1}     = '           max_iter = max_iter,';
Q.WSMS_AT_END{end+1}     = '     lm_ga_settings = lm_settings )';
Q.WSMS_AT_END{end+1}     = 'x2artsSensor';
Q.WSMS_AT_END{end+1}     = 'avkCalc';
Q.WSMS_AT_END{end+1}     = 'covmat_soCalc';
Q.WSMS_AT_END{end+1}     = 'covmat_ssCalc';
Q.WSMS_AT_END{end+1}     = 'retrievalErrorsExtract';
Q.WSMS_AT_END{end+1}     = '<OUTPUT> yf';
Q.WSMS_AT_END{end+1}     = '<OUTPUT> y_baseline';
Q.WSMS_AT_END{end+1}     = '<OUTPUT> x';
Q.WSMS_AT_END{end+1}     = '<OUTPUT> oem_diagnostics';
Q.WSMS_AT_END{end+1}     = '<OUTPUT> retrieval_eo';
Q.WSMS_AT_END{end+1}     = '<OUTPUT> retrieval_ss';
Q.WSMS_AT_END{end+1}     = '<OUTPUT> avk';

return
