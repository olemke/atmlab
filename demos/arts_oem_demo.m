% ARTS_OEM_DEMO   Demonstration of inversions using ARTS and OEM
%
%    The example treats ground-based measurements of ozone at 110.8 GHz.
%
% FORMAT   arts_oem_demo

% 2006-09-07   Created by Patrick Eriksson.

function X = arts_oem_demo


%- Check if needed atmlab settings are found
%
arts_xmldata_path = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
arts_includes = atmlab( 'ARTS_INCLUDES' );
if isnan( arts_includes )
  error('You need to ARTS_INCLUDES to run this example.');
end



%----------------------------------------------------------------------------
%- Init control structures 
%----------------------------------------------------------------------------
%
Q      = qarts;
Q.J    = qartsJacobian;
Q.J_DO = 1;
SX     = [];
O      = oem;


%----------------------------------------------------------------------------
%- OEM settings
%----------------------------------------------------------------------------
%
O.linear  = 0;
O.imethod = 'GN';
O.stop_dx = 0.01;
O.maxiter = 10;
%
O.cost    = 1;
O.dx      = 1;
O.e       = 1; 
O.eo      = 1;
O.es      = 0;
O.yf      = 0;
O.A       = 0;
O.J       = 0;
O.S       = 0;
O.So      = 0;
O.Ss      = 0;
O.Xiter   = 0;



%----------------------------------------------------------------------------
%- Forward model parameters
%----------------------------------------------------------------------------

Q.INCLUDES          = { fullfile( arts_includes, 'general.arts' ), ...
                        fullfile( arts_includes, 'continua.arts' ) };
Q.ATMOSPHERE_DIM    = 1;
Q.STOKES_DIM        = 1;
Q.ANTENNA_DIM       = 1;
Q.CLOUDBOX_DO       = 0;

%- Atmosphere
%
Q.R_GEOID             = constants( 'EARTH_RADIUS' );
Q.Z_SURFACE           = 0;
Q.P_GRID              = z2p_simple( -250:250:90e3 );
%
Q.USE_RAW_ATMOSPHERE  = 1;
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                              'fascod', 'midlatitude-winter' );

%- Absorption, part 1
%
Q.ABS_LINES_FORMAT    = 'Arts';
Q.ABS_LINES           = fullfile( atmlab_example_data , 'o3line111ghz' );
Q.ABS_NLS             = [];

%- RTE
%
Q.WSMS_BEFORE_RTE    = { 'atm_checkedCalc' };
Q.YCALC_WSMS         = { 'yCalc' };
%
Q.PPATH_LMAX          = 250;
Q.PPATH_STEP_AGENDA   = { 'ppath_stepGeometric' };
Q.Y_UNIT              = 'RJBT';
%
Q.SENSOR_LOS          = 70;
Q.SENSOR_POS          = Q.R_GEOID + Q.Z_SURFACE;

%- Exclude cosmic background radiation. A relative change of the spectrum
%- corresponds then to a relative change of the ozone profile.
%
Q.IY_SPACE_AGENDA = { 'Ignore(rte_los)',  'Ignore(rte_pos)', ...
                      'nelemGet(nrows,f_grid)', 'Copy(ncols,stokes_dim)', ...
                      'MatrixSetConstant(iy,nrows,ncols,0)' };

%- Frequency and spectrometer.
%
% The spectrometer has rectangular response functions
%
Q.F_GRID              = 1.108360400e+11 + linspace(-320e6,320e6,641);
%
H                     = qartsSensor;
H.SENSOR_NORM         = 1;
df                    = 2e6;
H.F_BACKEND           = min(Q.F_GRID)+df : df : max(Q.F_GRID)-df;
%
B.name                = 'Spectrometer channel response function';
B.gridnames           = { 'Frequency' };
B.grids               = { [-df/2 df/2] };
B.dataname            = 'Response';
B.data                = [1 1];
%
H.BACKEND_CHANNEL_RESPONSE{1} = B;
Q.SENSOR_DO                   = 1;
Q.SENSOR_RESPONSE             = H;
Q.MBLOCK_ZA_GRID              = 0;
%
clear B


%----------------------------------------------------------------------------
%- Retrieval quantities
%----------------------------------------------------------------------------

%- Ozone
%
ret_unit = 'rel';
%
%- Definition of Sx
D.FORMAT    = 'param'; 
if strcmp( ret_unit, 'rel' )
  D.SI      = 0.4;
else
  D.SI      = 0.1e-6;
end
D.CCO       = 0.01;  
D.CFUN1     = 'exp';
D.CL1       = [0.2;0.3];      % Must be a column vector
D.CL1_GRID1 = [1100e2 1e-3];  
%
[Q,SX] = qarts_abs_species( ...
                        Q, ...            
                        { 'O3' }, ...                     % Tag group name
                        0, ...                            % Non-linear species?
                        1, ...                            % Do jacobians?
                        SX, ...         
                        D, ...
                        { z2p_simple(0e3:1e3:90e3) }, ... % Retrieval grid(s)
                        ret_unit  ...                     % Retrieval unit
                      );



%----------------------------------------------------------------------------
%- Finish forward model part
%----------------------------------------------------------------------------

%- Absorption, part 2
%
% Water vapour is always needed (no absorption is here included)
Q = qarts_abs_species( Q, { 'H2O' } );
%
Q = qarts_abstable( Q );



%----------------------------------------------------------------------------
%- Create Se
%----------------------------------------------------------------------------
%
si = 0.01;
%
SE.FORMAT    = 'param';
SE.SI        = si;
SE.CCO       = 0;  
SE.CFUN1     = 'drc';
SE.CL1       = 0; 
%
Se = covmat3d( 1, SE, Q.SENSOR_RESPONSE.F_BACKEND );





%----------------------------------------------------------------------------
%- Calculations
%----------------------------------------------------------------------------


%- Calculate a spectrum matching a priori
%
y = arts_y( Q );


%- Crate a test measurement
%
y = 1.1 * y + si*randn(size(Se,1),1);


%- Perform retrieval
%
[Qoem,R,xa] = arts_oem_init( Q );
Sx          = arts_sx( Q, R, SX );
X           = oem( O, Qoem, R, @arts_oem, Sx, Se, [], [], xa, y );
%
arts_oem( 'clean', R );
clear Qoem 



%- Plot
%
if ~nargout
  %
  z = p2z_simple( Q.J.ABS_SPECIES(1).GRID1 );
  %
  if O.e & O.eo
    plot( X.x, z/1e3, repmat(X.x,1,2)+[-X.e X.e], z/1e3, ':', ...
                      repmat(X.x,1,2)+[-X.eo X.eo], z/1e3, '--' )
  else
    plot( X.x, z/1e3 )
  end
  xlabel( 'Retrieved profile' )
  ylabel( 'Approximative altitude [km]' );
end
