% QPACK2   Main function of Qpack2
%
%    Read qpack2.pdf for an introduction to Qpack2.
%
%    The function can be used in two main ways:
%----------------------------------------------------------------------------
%
%    1: The function defines all Qpack2 fields. Most fields are initiated 
%    to {}, that indicates that no value has been specified. Allowed
%    formats differ between the fields. For information about a specific 
%    field, type e.g.:
%       qinfo( @qpack2, 'BEAM_SWITCHING' );
%    That is, the function is organised in such way that *qinfo*
%    can be applied.
%
% FORMAT   [Q,I] = qpack2
%        
% OUT   Q  Setting structure with default values for all recognised fields.
%       I  Includes same fields as Q, where the content of each field
%          is a description string (used by *qinfo*).
%----------------------------------------------------------------------------
%
%    2. To make OEM type inversions. The measurement data are inverted by 
%    combining the function oem.m and the qarts interface to arts-2. 
%
%    The data fields of the output structure P depends on selected retrieval
%    quantities. In addition, the fields to be included in P can to some
%    extent be controlled by the user. Options and avaliable output fields are
%    described in qpack2.pdf.
%
%    The measurements to be inverted (Y) must all correspond to the same sensor
%    characteristics. The sensor response is calculated before the first
%    inversion is started and it is assumed that the reponse matrix obtained is
%    valid for all cases.
%
%    The measurement matching the apriori conditions can be calculated through
%    this function. This can be useful for test retrievals, or comparison with
%    som measurement data. Such calculations are triggered by setting all
%    measurement vectors in Y (that is, Y.Y) to be empty ([]). Note that the
%    field shall be set to [], and not to {} that inside qpack2 and qarts
%    identifies an undefined field.
%
% FORMAT   P = qpack2(Q,Y)
%
% IN    Q        Qpack2 setting structure
%       Y        Measurement data.
% OUT   P        Retrieved data. Or possibly Y with simulated measurements 
%                attached, see further above.

% 2009-08-14   Created by Patrick Eriksson.


function [P,I] = qpack2(Q,Y)

if nargin ~= 0  &  nargin ~= 2
  error( 'This function must have 0 or 2 input arguments' );
end


%=============================================================================
%=== Definition of O and I
%=============================================================================

if nargin == 0
%-----------------------------------------------------------------------------
P.ABS_LINES = {};
I.ABS_LINES = [ ...
'Identical to the qarts field with the same name.', ...
'#For more details: qinfo(@qarts,''ABS_LINES''),', ...
'#Example files are found in: arts/includes', ...
'#Note that absorption is here always calculated ''OnTheFly'' and ', ...
'pre-calculated absorption tables can not be used.'
];
%-----------------------------------------------------------------------------
P.ABS_LINES_FORMAT = {};
I.ABS_LINES_FORMAT = [ ...
'Identical to the qarts field with the same name.', ...
'#For more details: qinfo(@qarts,''ABS_LINES_FORMAT''),'
];
%-----------------------------------------------------------------------------
P.BACKEND_DO = 0;
I.BACKEND_DO = [ ...
'Flag to consider frequency response of backend channels. Default is 0. ', ...
];
%-----------------------------------------------------------------------------
P.BACKEND_CHANNEL_RESPONSE = {};
I.BACKEND_CHANNEL_RESPONSE = [ ...
'Identical to the qarts sensor field with the same name.', ...
'#For more details: qinfo(@qartsSensor,''BACKEND_CHANNEL_RESPONSE'') and ',...
'arts -d backend_channel_response', ...
'#Example cases are found in: arts/includes', ...
];
%-----------------------------------------------------------------------------
P.BEAM_SWITCHING = 0;
I.BEAM_SWITCHING = [ ...
'Flag to include treatment of beam switching. Default is 0. ', ...
'When activated, first angle is given weight -1 and second angle 1. ', ...
'Hints on the set-up below:', ...
'#<NO ANTENNA> The field MBLOCK_ZA_GRID shall hold two angles. Note that ',... 
'final angles are calculated as Y.zenith_angle+MBLOCK_ZA_GRID. For example,',...
' if MBLOCk_ZA_GRID is set to [-65,0] and Y.zenith_angle to 65, this will ',...
'mimic beam switching between zenith and an elevation of 25 deg.', ...
'#<ANTENNA> Treatment of antenna pattern not yet handled (in any way) by qpack2.'
];
%-----------------------------------------------------------------------------
P.CBGR = 1;
I.CBGR = [ ...
'Flag to include cosmic background radiation (1) or not (0). Default is 1.'
];
%-----------------------------------------------------------------------------
P.F_BACKEND = {};
I.F_BACKEND = [ ...
'The centre frequency of each spectrometer (backend) channel.', ...
'#For more details: qinfo(@qartsSensor,''F_BACKEND''),', ...
'#with the exception that this variable must here always be defined.', ...
'#See also: arts -d f_backend'
];
%-----------------------------------------------------------------------------
P.F_GRID = {};
I.F_GRID = [ ...
'Identical to the qarts field with the same name.', ...
'#For more details: qinfo(@qarts,''F_GRID'') and arts -d f_grid', ...
'#Only needed when DO_BACKEND is true. Otherwise automatically set to ',...
'F_BACKEND.'
];
%-----------------------------------------------------------------------------
P.FFIT_DO = 0;
I.FFIT_DO = [ ...
'Flag to include frequency fit(s) among the retrieval quantities. ', ...
'Defualt is false (0).'
];
%-----------------------------------------------------------------------------
P.FFIT_DF = 100e3;
I.FFIT_DF = [ ...
'Size for numerical perturbation when determining frequency jacobians.'
];
%-----------------------------------------------------------------------------
P.FFIT_ORDER = 0;
I.FFIT_ORDER = [ ...
'Order of frequency fit. Default is 0, and maximum value is 1.', ...
'#Order 0 corresponds to a common shift of all frequencies, while order 1 ',...
'can be denoted as a frequency stretch retrieval. See further:',...
'#   arts -d jacobianAddFreqShiftAndStretch'    
];
%-----------------------------------------------------------------------------
P.FFIT_SI = {};
I.FFIT_SI = [ ...
'Standard deviation (1 sigma) for each frequency fit variable. ', ...
'The variation of the different variables is assumed to be uncorrelated, ',...
'and these standard deviations are used to form a (diagonal) covariance ',...
'matrix that is appended to the complete Sx matrix. This vector can contain ',...
'data for stretch even if such a fit is not made.'
];
%-----------------------------------------------------------------------------
P.MBLOCK_ZA_GRID = [0];
I.MBLOCK_ZA_GRID = [ ...
'Identical to the qarts field with the same name. Default is [0].', ...
'#For more details: qinfo(@qarts,''MBLOCK_ZA_GRID'') and ',...
'arts -d mblock_za_grid', ...
'#A setting deviating from default value should only be needed for beam ', ...
'switching calculations.'
];
%-----------------------------------------------------------------------------
P.OEM_IMETHOD = {};
I.OEM_IMETHOD = [ ...
'Matches the field imethod of the O structure used as input to oem.m. ', ...
'Only needed if O.OEM_LINEAR is set to 0.', ...
'#For more details: help oem',
];
%-----------------------------------------------------------------------------
P.OEM_LINEAR = {};
I.OEM_LINEAR = [ ...
'Matches the field linear of the O structure used as input to oem.m.', ...
'#For more details: help oem',
];
%-----------------------------------------------------------------------------
P.OEM_GA_FACTOR_NOT_OK = {};
I.OEM_GA_FACTOR_NOT_OK = [ ...
'Matches the field ga_factor_not_ok of the O structure used as input to oem.m.',...
'#For more details: help oem',
];
%-----------------------------------------------------------------------------
P.OEM_GA_FACTOR_OK = {};
I.OEM_GA_FACTOR_OK = [ ...
'Matches the field ga_factor_ok of the O structure used as input to oem.m.',...
'#For more details: help oem',
];
%-----------------------------------------------------------------------------
P.OEM_GA_MAX = {};
I.OEM_GA_MAX = [ ...
'Matches the field ga_max of the O structure used as input to oem.m.',...
'#For more details: help oem',
];
%-----------------------------------------------------------------------------
P.OEM_GA_START = {};
I.OEM_GA_START = [ ...
'Matches the field ga_start of the O structure used as input to oem.m.', ...
'#For more details: help oem',
];
%-----------------------------------------------------------------------------
P.OEM_MAXITER = {};
I.OEM_MAXITER = [ ...
'Matches the field maxiter of the O structure used as input to oem.m. ', ...
'Only needed if O.OEM_LINEAR is set to 0.', ...
'#For more details: help oem',
];
%-----------------------------------------------------------------------------
P.OEM_STOP_DX = {};
I.OEM_STOP_DX = [ ...
'Matches the field stop_dx of the O structure used as input to oem.m. ', ...
'Only needed if O.OEM_LINEAR is set to 0.', ...
'#For more details: help oem',
];
%-----------------------------------------------------------------------------
P.OUT_A = 0;
I.OUT_A = [ ...
'Flag to inlude averaging kernels in result structure. Default is 0. ', ...
'If set to true, the averging kernel matrix (seperated for each retrieval ' ...
'quantity) is included in the output from qp2_oem (P).'
];
%-----------------------------------------------------------------------------
P.OUT_BASELINE = 0;
I.OUT_BASELINE = [ ...
'Flag to inlude baseline variables in result structure. Default is 0. ', ...
'If set to true, baseline fit variables are included in the output from ',...
'qp2_oem (P). Note that this does not activate any baseline retrieval, it ', ...
'only controls the output.'
];
%-----------------------------------------------------------------------------
P.OUT_F = 0;
I.OUT_F = [ ...
'Flag to inlude frequency fit varaibles in result structure. Default is 0. ',...
'Returned as a vector where firtst element is shift and second is stretch.'
];
%-----------------------------------------------------------------------------
P.OUT_PTZ = 0;
I.OUT_PTZ = [ ...
'Flag to inlude p, t and z in result structure. Default is 0. ', ...
'If set to true, matching vectors for pressure, temperature and geometrical ',...
'altitude are included in the output from qp2_oem (P). These fields in P ',...
'are denoted as p, t and z.'
];
%-----------------------------------------------------------------------------
P.OUT_Y = 0;
I.OUT_Y = [ ...
'Flag to inlude spectra in result structure. Default is 0. ', ...
'If set to true, measured spectrum (y), fitted spectrum (yf) and (backend) ',...
'frequencies (f) are included in the output from qp2_oem (P).'
];
%-----------------------------------------------------------------------------
P.PLATFORM_Z = {};
I.PLATFORM_Z = [ ...
'Altitude (above geoid) of observation platform.'
];
%-----------------------------------------------------------------------------
P.PLATFORM_LAT = {};
I.PLATFORM_LAT = [ ...
'Latitude of observation platform. Used when extracting climatology data, ',...
'if not latitude is included in Y when this field can be left undefined.'
];
%-----------------------------------------------------------------------------
P.PLATFORM_LON = {};
I.PLATFORM_LON = [ ...
'Longitude of observation platform. Used when extracting climatology data, ',...
'if not latitude is included in Ywhen this field can be left undefined.'
];
%-----------------------------------------------------------------------------
P.POLYFIT_DO = 0;
I.POLYFIT_DO = [ ...
'Flag to include polynomial baseline fit among the retrieval quantities. ', ...
'Defualt is false (0).', ...
'#For some more details around the POLYFIT feature: ',...
'arts -d jacobianAddPolyfit', ...
];
%-----------------------------------------------------------------------------
P.POLYFIT_ORDER = {};
I.POLYFIT_ORDER = [ ...
'Identical to the *poly_order* of the arts WSM jacobianAddPolyfit. See ', ...
'further POLYFIT_DO.'
];
%-----------------------------------------------------------------------------
P.POLYFIT_SI = {};
I.POLYFIT_SI = [ ...
'Standard deviation (1 sigma) for each polynomial coefficient of POLYFIT. ', ...
'The variation of the different polynomial coefficients is assumed to be ',...
'uncorrelated, and these standard deviations are used to form a (diagonal) ',...
'covariance matrix that is appended to the complete Sx matrix. This vector ',...
'can contain data for coefficients highe than *POLYFIT_ORDER*.'
];
%-----------------------------------------------------------------------------
P.SPECIES = {};
I.SPECIES = [ ...
'A structure array defining species to consider. These fields must always ', ...
'be set:#<TAG> Tag group data, following *arts_tgs_cnvrt*.', ...
'#<ATMDATA> VMR data for the species. If retrieved, this will be the a ', ...
'priori state. The data shall be given in gformat, matching the definition ',...
'in *clmtlgy_define*.',...
'#<RETRIEVED> If set to 0 the species is not retrieved. Otherwise the ', ...
'species is retrieved.', ...
'#If *RETRIEVED*, the following the fields must be set:', ...
'#<UNIT> Retrieval unit. Allowed choices are ''rel'', ''vmr'', ''nd'', ', ...
'#''logrel'', ''logvmr'' and ''lognd''. ', ...
'For more information: arts -d jacobianAddAbsSpecies', ...
'#<GRID> Pressure retrieval grid for the species. A vector.',...
'#<SX> Covariance matrix of a priori knowledge for the species. Size must ',...
'match the grid field. A matrix. Can be sparse. Data shall match <UNIT>.'
];
%-----------------------------------------------------------------------------
P.SURFACE_Z = {};
I.SURFACE_Z = [ ...
'Matches the qarts field named as *Z_SURFACE*.', ...
'#For more details: qinfo(@qarts,''Z_SURFACE''),'
];
%-----------------------------------------------------------------------------
P.T = {};
I.T = [ ...
'Temperature data and settings. Temperature not yet added as retrieval ', ...
'quantity. This is a structure with the following fields:', ...
'#<ATMDATA> As for species, this should be a gformat climatology.'
];
%-----------------------------------------------------------------------------
P.TNOISE_C = {};
I.TNOISE_C = [ ...
'Correlation of thermal noise. Must be a sparse (and square) matrix, with ', ...
'a size matching F_BACKEND. If not defined, the noise is assumed to be ', ...
'uncorrelated between the channels.'
];
%-----------------------------------------------------------------------------
P.YCALC_WSMS = { 'atm_checkedCalc', 'yCalc' }; 
I.YCALC_WSMS = [ ...
'Identical to the qarts field with the same name. It should be noted that ', ...
'the Qpack2 does not have the field matching qarts''s WSMS_BEFORE_RTE and ',...
'all WSMs calls must be put into this field for Qpack2.'
];
%-----------------------------------------------------------------------------
P.Y_UNIT = {}; 
I.Y_UNIT = [ ...
'Identical to the qarts field with the same name.', ...
'#For more details: qinfo(@qarts,''Y_UNIT''),'
];
%-----------------------------------------------------------------------------
return
end










%=============================================================================
%=== Retrieval part
%=============================================================================

%-----------------------------------------------------------------------------
%- Initial part
%-----------------------------------------------------------------------------
 
  
%- Basic checks of input
%
if nargin ~= 2
  error( 'The function requires zedro or two input arguments.' );
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


%- Set up fixed part of A and Sx
%
% Q of qarts is here denoted A
%
[A,Sx,O] = createAandSxandO( Q );


%- Inverse of Sx
%
% Is fixed and should only be calculated once (to save time) if not the option
% of O.sxnorm must be used
%
si = sqrt( diag( Sx ) );
if max(si) / min(si) <= 1e3
  Sxinv    = Sx \ speye(size(Sx));
  O.sxnorm = 0;
else
  Sxinv    = [];
  O.sxnorm = 1;
end




%-----------------------------------------------------------------------------
%- Invert measurements
%-----------------------------------------------------------------------------

P = [];
  
if empty_y
  workfolder = create_tmpfolder;
end

ny = length(Y);

for m = 1 : ny
  
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
    fprintf( 'Simulating spectrum %d/%d\n', m, ny );
    %
    A = qarts_abstable( A );
    % 
    P(m).Y = arts_y( A, workfolder );
  
    
  %- Inversion
  else
    %- Create Se
    %
    Se = createSe( Q, Ythis.TNOISE );

    %- Perform retrieval
    %
    if ny > 1
      O.msg = sprintf( 'Inversion case %d (of %d)', m, ny );
    end
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
if empty_y
  delete_tmpfolder( workfolder );
end

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
  O   = oem;
  
  %- OEM 
  %
  % User settings
  O.linear    = mandatory_qfield( Q, 'OEM_LINEAR' );
  if ~O.linear
    O.imethod   = mandatory_qfield( Q, 'OEM_IMETHOD', 'non-linear OEM' );
    O.stop_dx   = mandatory_qfield( Q, 'OEM_STOP_DX', 'non-linear OEM' );
    O.maxiter   = mandatory_qfield( Q, 'OEM_MAXITER', 'non-linear OEM' );
    if strcmp( upper(O.imethod), 'ML' )  |  strcmp( upper(O.imethod), 'LM' )
      O.ga_start         = mandatory_qfield( Q, 'OEM_GA_START', 'OEM ML' );
      O.ga_factor_ok     = mandatory_qfield( Q, 'OEM_GA_FACTOR_OK', 'OEM ML' );
      O.ga_factor_not_ok = mandatory_qfield( Q, 'OEM_GA_FACTOR_NOT_OK', 'OEM ML' );
      O.ga_max           = mandatory_qfield( Q, 'OEM_GA_MAX', 'OEM ML' );
    end
  end
  O.yf          = mandatory_qfield( Q, 'OUT_Y' );
                  mandatory_qfield( Q, 'OUT_A' );
  %
  % Hard-coded settings
  %
  O.cost      = 1;
  O.dx        = 1;
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
  A.ABSORPTION           = 'CalcTable';
  A.ABS_NLS              = [];
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
  A.Z_SURFACE            = mandatory_qfield( Q, 'SURFACE_Z' );

  %- RT variables
  %
  A.YCALC_WSMS           = mandatory_qfield( Q, 'YCALC_WSMS' );
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
      %
      grid = qarts_get(Q.SPECIES(i).GRID);
      n    = length( grid );
      %
      if diff( size(Q.SPECIES(i).SX) )
        error( [ 'SX is not a square matrix for species ', int2str(i) ] );
      end
      if n ~= size(Q.SPECIES(i).SX,1)
        error( [ 'Inconsistency in size between GRID and SX for species ', ...
                                                               int2str(i) ] );
      end
      %
      A = qarts_abs_species( A, Q.SPECIES(i).TAG{1}, 0, 1, [], [], ...
                             {Q.SPECIES(i).GRID}, Q.SPECIES(i).UNIT );
      Sx = covmat_append( Sx, Q.SPECIES(i).SX );
      pvalues = [ pvalues grid ];
    else
      A = qarts_abs_species( A, Q.SPECIES(i).TAG{1} );
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
  
  % Frequency
  %
  if mandatory_qfield( Q, 'FFIT_DO' )
    %
    si    = mandatory_qfield( Q, 'FFIT_SI', 'FFIT_DO' );
    order = mandatory_qfield( Q, 'FFIT_ORDER', 'FFIT_DO' );
    %
    if length(si) < 1  |  length(si) > 2
      error('Length of *Q.FFIT_SI* must be 1 or 2.');
    end
    %
    A.J.FREQUENCY.DO    = 1;
    A.J.FREQUENCY.ORDER = order;
    A.J.FREQUENCY.DF    = mandatory_qfield( Q, 'FFIT_DF', 'FFIT_DO' );
    %
    Sx = covmat_append( Sx, spdiags(vec2col(si).^2,0,order+1,order+1) );
  end

  % Polyfit
  %
  if mandatory_qfield( Q, 'POLYFIT_DO' )
    %
    order = mandatory_qfield( Q, 'POLYFIT_ORDER', 'POLYFIT_DO' );
    si    = mandatory_qfield( Q, 'POLYFIT_SI', 'POLYFIT_DO' );
    %
    l = order + 1;
    if length(si) < l
      error('Length of *Q.POLYFIT_SI* must be at least Q.POLYFIT_ORDER + 1.');
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
      Se = spdiags( repmat(tnoise_si^2,nf,1), 0, nf, nf );
    end
  else
    if cset
      [i,j,s] = find( Q.TNOISE_C );
      for k = 1 : length(i)
        s(k) = prod( tnoise_si([i(k) j(k)]) ) * s(k);
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
  if ~Q.OEM_LINEAR 
    P(i).converged = X.converged;
    P(i).dx        = X.dx;
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
  i_asj   = find( [ A.J.ABS_SPECIES.DO ] );  % Index of retrieval absorption
  %
  for q = 1 : length(R.jq)

    unitfac = 1;
    include = 0;
    do_log  = 0;
    ind     = I(q,1) : I(q,2);
    
    
    if strcmp( R.jq{q}.maintag, 'Absorption species' )
      %------------------------------------------------------------------------
      ispecies = i_asj(q);
      s        = sprintf( 'species%d', ispecies );
      include  = 1;
      %
      if strcmp( A.J.ABS_SPECIES(q).UNIT, 'logrel' )
        do_log  = 1;
        unitfac = R.x_vmr0(ind);
      elseif strcmp( A.J.ABS_SPECIES(q).UNIT, 'rel' )
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
        include = 1;
      end

    elseif strcmp( R.jq{q}.maintag, 'Frequency' )
      %------------------------------------------------------------------------
      if Q.OUT_F
        s       = 'ffit';
        include = 1;
      end
      
    else
      error( sprintf( 'Unknown retrieval quantity: %s', R.jq{q}.maintag ) );
    end

    if include
      if ~do_log
        P(i).([s,'_x'])  = unitfac .* X.x(ind);
        P(i).([s,'_xa']) = unitfac .* xa(ind);
      else
        P(i).([s,'_x'])  = unitfac .* exp( X.x(ind) );
        P(i).([s,'_xa']) = unitfac .* exp( xa(ind) );
      end
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

