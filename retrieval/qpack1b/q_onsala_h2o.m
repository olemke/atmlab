% Q_ONSALA_H2O   Definition of Q for Onsala water vapour inversions
%
%    This function sets Q for inversion of the standard ground-based 
%    measurements of water vapour performed at Onsala Space Observatory. 
%    The calculations are done in a straightforward way and are not 
%    optimised for calculation speed (there is no pre-calculation of 
%    absorption).
%
%    This file is used for operational retrievals, but serves inside atmlab
%    just as an example (input files used are not part of atmlab). 
%
% FORMAT   Q = q_onsala_h2o( [width] )
%        
% OUT   Q       Qpack2 setting structure.
% OPT   width   Observation mode, in terms of observed frequency range.
%               A text string. Default is '20MHz'

% 2009-07-01   Created by Patrick Eriksson.

function Q = q_onsala_h2o(width)
%
width = optargs( varargin, { '20MHz' } );


%- Input folders
%
data    = fullfile( pwd, 'SensorData' );
atmdata = fullfile( pwd, 'AtmData' );
%
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to set ARTS_XMLDATA_PATH to run this example.');
end


%- Init Q
%
Q = qpack2;


%- General information
%
% Measurement data are corrected for tropospheric attenuation and the
% retrievals are performed assuming observations from tropopause level. Exact
% choice of observation altitude is not critical (confirmed by simulations).
%
Q.PLATFORM_Z           = 10e3;
Q.PLATFORM_LAT         = 57.40;
Q.PLATFORM_LON         = 11.93;
Q.SURFACE_Z            = Q.PLATFORM_Z;


%- Output variables
%
Q.OUT_Y                = 1;
Q.OUT_PTZ              = 1;
Q.OUT_BASELINE         = 1;
Q.OUT_A                = 1;
  

%- OEM
%
Q.OEM_LINEAR           = 0;
%
% Setting below only of interest for tests of non-linear inversions
Q.OEM_ITERMETHOD       = 'GN';
Q.OEM_STOP_DX          = 0.01;
Q.OEM_MAXITER          = 5;


%- Polyfit
%
% A polynomial of order 6 is used for "baseline fit".
%
Q.POLYFIT_DO           = 1;
Q.POLYFIT_ORDER        = 6;
Q.POLYFIT_SI           = [1 0.5 0.2 0.1 0.05 0.05 0.05]; 

  
%- FREQUENCY
%
Q.FFIT_DO              = 1;
Q.FFIT_ORDER           = 0;
Q.FFIT_SI              = 50e3; 
Q.FFIT_DF              = 50e3; 
%
if Q.FFIT_DO
  Q.OUT_F              = 1;
end


%- Species
%
% Only water vapour is retrieved here
%
species = 'H2O';
%
Q.SPECIES(1).TAG{1}{1} = species;
Q.SPECIES(1).RETRIEVE  = 1;
Q.SPECIES(1).GRID      = z2p_simple(Q.PLATFORM_Z-2e3:2e3:105e3);
%
Q.SPECIES(1).UNIT      = 'vmr';
Q.SPECIES(1).SX        = covmat1d_from_cfun( Q.SPECIES(1).GRID, 1.5e-6, ...
                                                 'lin', 0.2, 0.00, @log10 ) + ...
                         covmat1d_from_cfun( Q.SPECIES(1).GRID, 0.3e-6, ...
                                                 'lin', 0.5, 0.00, @log10 );
Q.SPECIES(1).ATMDATA   = loadvar( fullfile( atmdata, ...
                                        'mls_retriveved_total_mean_h2o' ), 'G' );


%- Temperature
%
Q.T.ATMDATA            = gfin_artsxml( clmtlgy_define, [], fullfile( ...
                                      arts_xmldata_path, ...
                                     'climatology', 'msis90', 'msis90.t.xml' ) );


%- Line data
%
Q.ABS_LINES            = fullfile( data, 'h20_22ghz.xml' );
Q.ABS_LINES_FORMAT     = 'Arts';


%- Sensor variables
%
Q.Y_UNIT                   = 'RJBT'; 
Q.CBGR                     = 0;
%
Q.BACKEND_DO               = 1;
Q.F_GRID                   = fullfile( data, ['f_grid_h2o_',width,'.xml'] );
Q.F_BACKEND                = fullfile( data, ['f_backend_h2o_',width,'.xml'] );
Q.BACKEND_CHANNEL_RESPONSE = ... 
                             fullfile( data, ['backend_channel_',width,'.xml'] );
%
% Measurements performed as beam switching. Provided data are corrected and
% match throughout beam switching between elevation angles of 25 and
% 90 degrees, without any "zenith load"
Q.BEAM_SWITCHING           = 1;
Q.MBLOCK_ZA_GRID           = [-65 0];
Q.FILL_FGRID               = [ 5 4 ];


%- Correlation of thermal noise 
%
f          = qarts_get(Q.F_BACKEND);
cfun       = 'gau';
cl         = 1.4 * ( f(2) - f(1) );
cco        = 0.05;
%
Q.TNOISE_C = covmat1d_from_cfun( f, [], cfun, cl, cco );
