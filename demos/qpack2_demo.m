% Q_ONSALA_H2O   Definition of Q and O for Onsala water vapour inversions
%
%    This function sets Q and O for inversion of the standard ground-based 
%    measurements of water vapour performed at Onsala Space Observatory. 
%    The calculations are done in a straightforward way and are not 
%    optimised for calculation speed (there is no pre-calculation of 
%    absorption).
%
%    This file is used for operational retrievals, but serves inside atmlab
%    just as an example (input files used are not part of atmlab). 
%
% FORMAT   [Q,O] = q_onsala_h2o( [width] )
%        
% OUT   Q       Qpack2 setting structure. See *qpack2*.
%       O       OEM setting structure. See *oem*.
% OPT   width   Observation mode, in terms of observed frequency range.
%               A text string. Default is '20MHz'

% 2009-07-01   Created by Patrick Eriksson.

function [Q,O,specdesc] = qpack2_demo(varargin)
%
width = optargs( varargin, { '20MHz' } );

error( 'Not yet active' );

%- Atmlab settings
%
arts_xmldata_path = atmlab( 'ARTS_XMLDATA_PATH' );
arts_includes     = atmlab( 'ARTS_INCLUDES' );
if isnan( arts_xmldata_path )                                               %&%
  error( 'You need to set ARTS_XMLDATA_PATH to run this file.' );           %&%
end                                                                         %&%
if isnan( arts_includes )                                                   %&%
  error( 'You need to ARTS_INCLUDES to run this file.' );                   %&%
end                                                                         %&%


%- Input folders
%
data    = fullfile( pwd, 'SensorData' );
atmdata = fullfile( pwd, 'AtmData' );


%- Init Q
%
Q = qarts;


%- General 
%
Q.INCLUDES            = { fullfile( arts_includes, 'general.arts' ), ...
                          fullfile( arts_includes, 'continua.arts' ) };
Q.ATMOSPHERE_DIM      = 1;
Q.USE_RAW_ATMOSPHERE  = false;
Q.STOKES_DIM          = 1;
Q.J_DO                = true;


%- Radiative transfer
%
Q.Y_UNIT              = 'RJBT'; 
Q.WSMS_BEFORE_RTE     = { 'atm_checkedCalc' };
Q.YCALC_WSMS          = { 'yCalc' };
%
Q.PPATH_LMAX          = 250;
Q.PPATH_STEP_AGENDA   = { 'ppath_stepGeometric' };
%
% Exclude cosmic background radiation:
Q.IY_SPACE_AGENDA     = { 'Ignore(rte_los)',  'Ignore(rte_pos)', ...
                          'nelemGet(nrows,f_grid)', 'Copy(ncols,stokes_dim)',...
                          'MatrixSetConstant(iy,nrows,ncols,0)' };


%- Surface
%
% Measurement data are corrected for tropospheric attenuation and the
% retrievals are performed assuming observations from tropopause level. Exact
% choice of observation altitude is not critical (confirmed by simulations).
% The altitude is set to 10 km.
%
Q.R_GEOID            = constants( 'EARTH_RADIUS' );
Q.Z_SURFACE          = 10e3;


%- Absorption
%
Q.ABS_LINES           = fullfile( data, 'linedata_22ghz.xml' );
Q.ABS_LINES_FORMAT    = 'Arts';
%
Q.ABSORPTION          = 'CalcTable';
Q.ABS_NLS             = [];

%- GRIDS
%
z_toa                 = 105e3;
%
Q.P_GRID              = z2p_simple( Q.Z_SURFACE-2e3:250:z_toa )';
Q.F_GRID              = fullfile( data, ['f_grid_h2o_',width,'.xml'] );


%- Sensor variables
%
H                     = qartsSensor;
%
H.SENSOR_NORM         = true;
H.FILL_FGRID          = [ 5 4 ];
Q.ANTENNA_DIM         = 1;
%
H.F_BACKEND                = fullfile( data, ['f_backend_h2o_',width,'.xml'] );
H.BACKEND_CHANNEL_RESPONSE = fullfile( data, ['backend_channel_',width,'.xml']);
%
% Measurements performed as beam switching. Provided data are corrected and
% match throughout beam switching between elevation angles of 25 and
% 90 degrees, without any "zenith load"
H.BEAM_SWITCHING      = true;
Q.MBLOCK_ZA_GRID      = [-65 0]';
%  
Q.SENSOR_DO           = true;
Q.SENSOR_RESPONSE     = H;


%- Correlation of thermal noise 
%
f    = qarts_get(H.F_BACKEND);
cl   = 1.4 * ( f(2) - f(1) );
cfun = 'gau';
cco  = 0.05;
%
Q.TNOISE_C = covmat1d_from_cfun( f, [], cfun, cl, cco );
%
clear H f


%- Define L2 structure (beside retrieval quantities above)
%
Q.L2_EXTRA = { 'cost', 'dx', 'xa', 'y', 'yf', 'bl', 'ptz', 'mresp', ...
               'e', 'eo', 'es', 'date' };


%- Temperature
%
Q.T_ATMDATA = gf_artsxml( fullfile( arts_xmldata_path, 'climatology', ...
                        'msis90', 'msis90.t.xml' ), 'Temperature', 't_field' );


%- Species
%
% Only water vapour is retrieved here
%
Q.ABS_SPECIES(1).TAG      = { 'H2O' };
Q.ABS_SPECIES(1).RETRIEVE = true;
Q.ABS_SPECIES(1).L2       = true;
Q.ABS_SPECIES(1).GRIDS    = { z2p_simple(Q.Z_SURFACE-2e3:2e3:z_toa)', [], [] };
Q.ABS_SPECIES(1).UNIT     = 'vmr';
Q.ABS_SPECIES(1).SX       = ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 1.5e-6, ...
                                               'lin', 0.2, 0.00, @log10 ) + ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 0.3e-6, ...
                                               'lin', 0.5, 0.00, @log10 );
Q.ABS_SPECIES(1).ATMDATA  = fullfile( atmdata, ...
                                             'mls_retriveved_total_mean_h2o' );


%- FREQUENCY
%
Q.FFIT.RETRIEVE           = true;
Q.FFIT.DF                 = 50e3; 
Q.FFIT.ORDER              = 0;
Q.FFIT.SX                 = 50e3^2;  
Q.FFIT.L2                 = true;


%- Polyfit
%
% A polynomial of order 6 is used for "baseline fit".
%
Q.POLYFIT.RETRIEVE        = true;
Q.POLYFIT.ORDER           = 6;
Q.POLYFIT.L2              = false;
Q.POLYFIT.SX0             = 1^2; 
Q.POLYFIT.SX1             = 0.5^2; 
Q.POLYFIT.SX2             = 0.2^2;
Q.POLYFIT.SX3             = 0.1^2; 
Q.POLYFIT.SX4             = 0.05^2; 
Q.POLYFIT.SX5             = 0.05^2; 
Q.POLYFIT.SX6             = 0.05^2; 


%- OEM 
%
O = qp2_l2( Q );
%
O.linear = false;
%
if ~O.linear 
  O.itermethod = 'GN';
  O.stop_dx    = 0.01;
  O.maxiter  = 5;
end
