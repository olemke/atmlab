% QP2_OEM   Qpack2 OEM retrievals.
%
%    Main function of qpack2. Measurement data are inverted by oem.m (using
%    arts-2). 
%
%    The data fields of the output structure P depends on selected retrieval
%    quantities. In addition, the fields to be included in P can to some
%    extent be controlled by the user. Options and avaliable output fields are
%    described in qpack2.pdf.
%
%    The measurement matching the apriori conditions can be calculated through
%    this function. This can be useful for test retrievals, or comparison with
%    som measurement data. Such calculations are triggered by setting all
%    measurement vectors in Y (that is, Y.Y) to be empty ([]). Note that the
%    field shall be set to [], and not to {} that inside qpack2 and qarts
%    identifies an undefined field.
%
% FORMAT   P = qp2(Q,Y)
%
% IN    Q        Qpack2 setting structure
%       Y        Measurement data.
% OUT   P        Retrieved data. Or possible simulated measurements. 
%                See above.

% 2009-08-10   Created by Patrick Eriksson.


function P = qp2_oem(Q,Y)

  
%-----------------------------------------------------------------------------
%- Initial part
%-----------------------------------------------------------------------------
 
  
%- Basic checks of input
%
if nargin ~= 2
  error( 'The function requires two input arguments.' );
end
%
if isempty( Y )
  out(1,1);out(1,'Y totally empty ([]).');out(1,-1);
  P = [];
  return;
end
  

%- Check Q and force loaded data for some q fields
%
qcheck( @qpack2, Q );  
%
Q = loadQ( Q );


%- Initial check of Y
%
empty_y = checkY( Q, Y );


%- Create a work folder
%
workfolder = create_tmpfolder;


%- Set up fixed part of A and Sx
%
% Q of qarts is here denoted A
%
% This step includes calculation of sensor response data
%
[A,Sx,O] = createAandSxandO( Q, workfolder );


%- Inverse of Sx
%
% Is fixed and should only be calculated once (to save time)
%
Sxinv = Sx \ speye(size(Sx));




%-----------------------------------------------------------------------------
%- Invert measurements
%-----------------------------------------------------------------------------

P = [];
  
for m = 1 : length(Y)
  
  %- Set up data for next measurement
  %
  [A,Ythis] = nextMeasurement( Q, A, Y, m );

  
  %- Simulate a (noise free) measurement if y is empty
  if empty_y
    %
    if isempty(P)
      P    = Y(m);
    else
      P(m) = Y(m);
    end
    %
    fprintf( 'Simulating spectrum %d/%d\n', m, length(Y) );
    %
    P(m).y = arts_y( A, workfolder );
  
    
  %- Inversion
  else
    %- Create Se
    %
    Se = createSe( Q, Ythis.TNOISE );

    %- Perform retrieval
    %
    O.msg = sprintf( 'Inversion case %d (of %d)', m, length(Y) );
    %
    [Aoem,R,xa] = arts_oem_init( A );
    [X,R]       = oem( O, Aoem, R, @arts_oem, Sx, Se, Sxinv, [], xa, Ythis.Y );
    %
    arts_oem( 'clean', R );
    clear Aoem 
    
    %- Fill return structure
    P = fillP( P, Q, A, Ythis, R, xa, X );

  end
end


%- Remove work folder
%
delete_tmpfolder( workfolder );

%- Sort fields of P
%
%P = orderfields( P );
  
return
%------------------------------------------------------------------------------


  


%------------------------------------------------------------------------------
%- Internal sub-functions
%------------------------------------------------------------------------------

% Check and load data into Q
%
function Q = loadQ( Q )
  
  if qarts_isset( Q.F_BACKEND )
    Q.F_BACKEND = qarts_get( Q.F_BACKEND );
  else
    error( 'Q.F_BACKEND must be set' );
  end

  if qarts_isset( Q.TNOISE_C )
    %
    Q.TNOISE_C  = qarts_get( Q.TNOISE_C );
    %
    if ~issparse(Q.TNOISE_C)
      error( 'Q.TNOISE_C is required to be sparse (to save memory).' );
    elseif size(Q.TNOISE_C,1) ~= size(Q.TNOISE_C,2)
      error( 'Q.TNOISE_C must be square.' );
    elseif size(Q.TNOISE_C,1) ~= length(Q.F_BACKEND)
      error( 'Size of Q.TNOISE_C must match length of Q.F_BACKEND.' );
    end
  end
return



% Creates Sx and fixed parts of A 
%
function [A,Sx,O] = createAandSxandO(Q,workfolder)

  %- Check if needed atmlab settings are found
  %
  arts_includes = atmlab( 'ARTS_INCLUDES' );
  if isnan( arts_includes )
    error('You need to ARTS_INCLUDES to run qpack2.');
  end

  %- Init
  A   = qarts;
  Sx  = [];
  
  %- OEM 
  %
  % User settings
  O.linear    = mandatory_qfield( Q, 'OEM_LINEAR' );
  if ~O.linear
    O.imethod   = mandatory_qfield( Q, 'OEM_IMETHOD', 'OEM_LINEAR' );
    O.stop_dx   = mandatory_qfield( Q, 'OEM_STOP_DX', 'OEM_LINEAR' );
    O.maxiter   = mandatory_qfield( Q, 'OEM_MAXITER', 'OEM_LINEAR' );
  end
  O.yf        = mandatory_qfield( Q, 'OUT_Y' );
                mandatory_qfield( Q, 'OUT_A' );
  %
  % Hard-coded settings
  %
  O.cost      = 1;
  O.e         = 1;
  O.eo        = 1;
  O.es        = 1;
  O.A         = 1;

    
  %- Hard-coded A settings
  %
  A.INCLUDES          = { fullfile( arts_includes, 'general.arts' ), ...
                          fullfile( arts_includes, 'continua.arts' ) };
  %
  A.ATMOSPHERE_DIM       = 1;
  A.STOKES_DIM           = 1;
  A.USE_RAW_ATMOSPHERE   = 0;
  A.CLOUDBOX_DO          = 0;
  %
  A.ABSORPTION           = 'OnTheFly';
  A.ABS_LINESHAPE        = 'Voigt_Kuntz6';
  A.ABS_LINESHAPE_CUTOFF = -1;
  A.ABS_LINESHAPE_FACTOR = 'quadratic'; 
  %
  A.R_GEOID              = constants( 'EARTH_RADIUS' );
  %
  A.SENSOR_POS           = A.R_GEOID + Q.PLATFORM_Z;
  %
  A.J_DO                 = 1;
  A.J                    = qartsJacobian;

  %- Line data
  %
  A.ABS_LINES            = mandatory_qfield( Q, 'ABS_LINES' );
  A.ABS_LINES_FORMAT     = mandatory_qfield( Q, 'ABS_LINES_FORMAT' );
    
  %- Surface and atmosphere
  %
  A.Z_SURFACE            = mandatory_qfield( Q, 'SURFACE_Z' );;

  %- RT variables
  %
  A.PPATH_LMAX           = 200;
  A.PPATH_STEP_AGENDA    = { 'ppath_stepGeometric' };
  %
  if mandatory_qfield( Q, 'CBGR' );
    A.IY_SPACE_AGENDA = { 'Ignore(rte_los)',  'Ignore(rte_pos)', ...
                          'MatrixCBR( iy, stokes_dim, f_grid )' };
  else
    A.IY_SPACE_AGENDA = { 'Ignore(rte_los)',  'Ignore(rte_pos)', ...
                          'nelemGet(nrows,f_grid)', 'Copy(ncols,stokes_dim)', ...
                          'MatrixSetConstant(iy,nrows,ncols,0)' };
  end
  
  %- Add species
  %
  pvalues = [];
  %
  for i = 1 : length( Q.SPECIES )
    if Q.SPECIES(i).RETRIEVE
      A = qarts_abs_species( A, {Q.SPECIES(i).TAG{:}}, 0, 1, [], [], ...
                             {Q.SPECIES(i).GRID}, Q.SPECIES(i).UNIT );
      Sx = covmat_append( Sx, Q.SPECIES(i).SX );
      pvalues = [ pvalues qarts_get(Q.SPECIES(i).GRID) ];
    else
      A = qarts_abs_species( A, {Q.SPECIES(i).TAG} );
    end
  end
  
  %- P_GRID
  %
  % Create by merge all calculation and retrievals grids, with points closer
  % than 50 m removed.
  %
  A.P_GRID = unique( pvalues );
  A.P_GRID = pow10( gridthinning( log10(A.P_GRID), 50/16e3 ) ); 
  A.P_GRID = A.P_GRID(end:-1:1);

  %- Sensor related stuff
  %
  S                 = qartsSensor;
  A.SENSOR_DO       = 1;
  S.SENSOR_NORM     = 1;
  %
  A.Y_UNIT          = mandatory_qfield( Q, 'Y_UNIT' );
  A.ANTENNA_DIM     = 1;
  A.MBLOCK_ZA_GRID  = mandatory_qfield( Q, 'MBLOCK_ZA_GRID' );
  %
  if mandatory_qfield( Q, 'BACKEND_DO' )
    A.F_GRID                   = mandatory_qfield( Q, 'F_GRID', 'BACKEND_DO' );
    S.F_BACKEND                = Q.F_BACKEND;  % Already checked and loaded
    S.BACKEND_CHANNEL_RESPONSE = mandatory_qfield( Q, ...
                                    'BACKEND_CHANNEL_RESPONSE', 'BACKEND_DO' );
  else
    A.F_GRID                   = Q.F_BACKEND;
  end
  %
  S.BEAM_SWITCHING = Q.BEAM_SWITCHING;
  %
  A.SENSOR_RESPONSE = S;
  A = arts_sensor( A, workfolder );
  
  % Polyfit
  %
  if mandatory_qfield( Q, 'POLYFIT_DO' )
    %
    order = mandatory_qfield( Q, 'POLYFIT_ORDER', 'POLYFIT_DO' );
    si    = mandatory_qfield( Q, 'POLYFIT_SI', 'POLYFIT_DO' );
    %
    l = order + 1;
    if length(si) ~= l
      error('Length of *Q.POLYFIT_SI* must be Q.POLYFIT_ORDER + 1.');
    end
    %
    A.J.POLYFIT.DO         = 1;
    A.J.POLYFIT.POLY_ORDER = order;
    %
    Sx = covmat_append( Sx, spdiags(vec2col(si).^2,0,l,l) );
  end
return


% Extraction of mandatory Q field
%
function r = mandatory_qfield( Q, fname, mainfield )
  if qarts_isset( Q.(fname) )
    r = Q.(fname);
  else
    if nargin == 2
      error( sprintf('Q.%s must be set.',fname) );
    else
      error( sprintf('Q.%s is mandatory when %s is true/active.',...
                                                             fname,mainfield) );
    end
  end
return


% Creates observation error matrix, Se
%
function Se = createSe( Q, tnoise_si )

  n    = length( tnoise_si );
  nf   = length( Q.F_BACKEND );       % F_BACKEND and TNOISE_C already checked
  cset = qarts_isset( Q.TNOISE_C );
  
  if n ~= 1  & n ~= nf
    error( 'Length of *tnoise_si* must be 1 or match *Q.F_BACKEND*.' );
  end
  
  if n == 1
    if cset
      Se = (tnoise_si^2) .* Q.TNOISE_C;
    else
      Se = spdiags( repmat(tnoise^2,nf,1), 0, nf, nf );
    end
  else
    if cset
      [i,j,s] = find( Q.TNOISE_C );
      for k = 1 : length(i)
        s(k) = prod( thermal_si([i(k) j(k)]) ) * s(k);
      end
      Se = sparse(i,j,s);
    else
      Se = spdiags( vec2col(tnoise_si.^2), 0, nf, nf );
    end
  end
return


  
% Check if mandatory fields of Y exist
%
function empty_y = checkY( Q, Y )

  qcheck( @qp2_y, Y );  
    
  % All y empty 
  if isempty( Y(1).Y )
    for i = 2 : length(Y)
      if length(Y(i).Y) > 0
        error( [ 'First spectrum in Y is empty. Then all other spectra must '...
                 'also be empty.'] );
      end
    end
    empty_y = 1;
    
  % Standard case
  else
    for i = 1 : length(Y)
      if length(Y(i).Y) ~= length(Q.F_BACKEND)
        error( sprintf(['Length of spectrum %d (at least) does not match ' ...
                        'length of Q.F_BACKEND.'], i ) );
      end
    end
    empty_y = 0;
  end
return



% Jump to next measurement
%
function [A,Ythis] = nextMeasurement( Q, A, Y, i )

  Ythis = Y(i);
  
  %- Observation direction
  %
  A.SENSOR_LOS = Ythis.ZA;

  %- Position set?
  %
  if ~qarts_isset( Ythis.LATITUDE ),  Ythis.LATITUDE  = Q.PLATFORM_LAT; end
  if ~qarts_isset( Ythis.LONGITUDE ), Ythis.LONGITUDE = Q.PLATFORM_LON; end  
  
  %- Non mandatory time data
  %
  if ~qarts_isset( Ythis.HOUR ),   Ythis.HOUR = 12;  end
  if ~qarts_isset( Ythis.MINUTE ), Ythis.MINUTE = 0; end
  if ~qarts_isset( Ythis.SECOND ), Ythis.SECOND = 0; end

  %- Create atmospheric fields
  %
  A.VMR_FIELD = zeros( length(A.ABS_SPECIES), length(A.P_GRID), 1, 1 );
  %
  D   = clmtlgy_define;
  h2o = [];
  %
  for i = 1 : length(A.ABS_SPECIES) 
    A.VMR_FIELD(i,:,1,1) = clmtlgy_interp( D, Q.SPECIES(i).ATMDATA, A.P_GRID,...
                                       Ythis.LATITUDE, Ythis.LONGITUDE, ...
                                       Ythis.YEAR, Ythis.MONTH, Ythis.DAY, ...
                                       Ythis.HOUR, Ythis.MINUTE, Ythis.SECOND );
    if isempty(h2o)
      species = arts_tgs2species( A.ABS_SPECIES{i}{1} );
      if strcmp( species, 'H2O' )
        h2o = A.VMR_FIELD(i,1,1,1);
      end
    end
  end
  %
  A.T_FIELD = clmtlgy_interp( D, Q.T.ATMDATA, A.P_GRID, ...
                              Ythis.LATITUDE, Ythis.LONGITUDE, ...
                              Ythis.YEAR, Ythis.MONTH, Ythis.DAY, ...
                              Ythis.HOUR, Ythis.MINUTE, Ythis.SECOND );
  %
  A.Z_FIELD = pt2z( A.P_GRID, A.T_FIELD, h2o, Ythis.HSE_P, Ythis.HSE_Z, ...
                                                              Ythis.LATITUDE );
return



% Fill output structure
%
function P = fillP( P, Q, A, Ythis, R, xa, X )

  i = length(P) + 1;

  % Start and stop index for each retrieval quantity  
  I = zeros( length(R.jq), 2 );
  for q = 1 : length(R.jq)
    I(q,:) = [ R.ji{q}{1}  R.ji{q}{2} ];
  end
  
  % Basic diagnostics 
  %
  P(i).cost   = X.cost;
  P(i).cost_x = X.cost_x;
  P(i).cost_y = X.cost_y;

  % Time and position
  P(i).year      = Ythis.YEAR;
  P(i).month     = Ythis.MONTH;
  P(i).day       = Ythis.DAY;
  P(i).hour      = Ythis.HOUR;
  P(i).minute    = Ythis.MINUTE;
  P(i).second    = Ythis.SECOND;
  P(i).latitude  = Ythis.LATITUDE;
  P(i).longitude = Ythis.LONGITUDE;
 
  % More retrieval diagnostics 
  %
  P(i).tnoise = mean( Ythis.TNOISE );
  %
  if Q.OEM_LINEAR 
    P(i).converged = X.converged;
  end 
  %  
  if Q.OUT_A
    As = splitA( X.A, I );
  end
  %
  mresp = mrespA( X.A, I );
  
  % Spectra
  if Q.OUT_Y
    if qarts_isset( Ythis.F )
      P(i).f   = Ythis.F;
    else
      P(i).f   = Q.F_BACKEND;
    end
    P(i).y        = Ythis.Y;
    P(i).yf       = X.yf;
    P(i).baseline = R.bl;
  end
 
  % PTZ (a priori or forward model parameters)
  if Q.OUT_PTZ
    P(i).p = vec2col( A.P_GRID );
    P(i).t = A.T_FIELD;
    P(i).z = A.Z_FIELD;
  end

  % Retrieval quantities
  %
  ispecies = 0;
  tdone    = 0;
  %
  for q = 1 : length(R.jq)

    unitfac = 1;
    include = 1;
    ind     = I(q,1) : I(q,2);
    
    
    if strcmp( R.jq{q}.maintag, 'Absorption species' )
      %------------------------------------------------------------------------
      ispecies = ispecies + 1;
      s        = sprintf( 'species%d', ispecies );
      %
      if strcmp( A.J.ABS_SPECIES(q).UNIT, 'rel' )
        unitfac = R.x_vmr0(ind);
      end
      %
      P(i).([s,'_name'])  = R.jq{q}.subtag;
      P(i).([s,'_p'])     = vec2col( A.J.ABS_SPECIES(ispecies).GRID1 );
    
    
    elseif strcmp( R.jq{q}.maintag, 'Polynomial baseline fit' )
      %------------------------------------------------------------------------
      if Q.OUT_BASELINE
        s = sprintf( 'polyfit%s', R.jq{q}.subtag(end) );
        P(i).baseline = R.bl;
      else
        include = 0;
      end
      
      
    else
      error( sprintf( 'Unknown retrieval quantity: %s', R.jq{q}.maintag ) );
    end

    if include
      P(i).([s,'_x'])  = unitfac .* X.x(ind);
      P(i).([s,'_xa']) = unitfac .* xa(ind);
      P(i).([s,'_e'])  = unitfac .* X.e(ind);
      P(i).([s,'_eo']) = unitfac .* X.eo(ind);
      P(i).([s,'_es']) = unitfac .* X.es(ind);
      P(i).([s,'_mr']) = mresp(ind);
      if Q.OUT_A
        P(i).([s,'_A']) = As{q};
      end
    end
  end
  
return