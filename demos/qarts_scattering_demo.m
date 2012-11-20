% QARTS_SCATTERING_DEMO  Demonstration of scattering calculations by Qarts
%
%   ARTS has three modules for performing scattering calculations: DOIT, MC,
%   and TR (iyTransmissionStandard). The DOIT method is implemented for both 1D
%   and 3D, but is only recommended for 1D. MC is only implemented for 3D. TR
%   is defined for all atmospheric dimensionalities. This function runs a
%   simple scenario with DOIT-1D, MC (3D) or TR (1/2/3D). 
%
%   The 1D scenario used for DOIT is expanded to 3D for MC. The cloud is then
%   given a rectangular shape (in lat and lon). The 1D cloud values are applied
%   inside a range of [-15,15] degrees, in both latitude and longitude. This
%   extended by a linear transition to clear sky conditions over 3 degrees.
%   That is, a perfect match between DOIT and MC can not always be expected as
%   the "3D cloud" has a smaller extension than the 1D one, this especially if
%   a very low tangent altitude is selected (your path can then even be
%   totally outside of the cloud box).
%
%   The cloud is expanded in same way for TR, when 2D or 3D is selected.
%
% FORMAT [Q,f,ztan,y_c,y,dy] = qarts_scattering_demo([ztan,method,m_arg,iwpfac])
%
%  OUT   Q          Qarts setting structure.
%        f          Frequency grid.
%        ztan       Set of tangent altitudes used.
%        y_c        Calcualted clearsky radiances [RJ BT].
%        y          Calculated cloudy randiances  [RJ BT].
%        dy         Error estimate. Only valid for MC.
% OPT    ztan       Tangent altitudes. Default is [7 10 13] km.
%        method     Scattering method to use. Default is 'mc'. Other options
%                   are 'doit', 'and 'tr'. (Upper or lower case letters 
%                   do not matter).
%        m_arg      Method argument. Not used for DOIT. For MC it is the
%                   Target calculation accuracy for MC, in K. Default is 5K.
%                   For TR this is atmospheric dimensionality to use.
%        iwcfac     Scaling factor of the IWC used. Default is 1. Set to 0
%                   to obtain "clear-sky" also inside cloudbox.

% 2010-12-01  Extended to also handle TR by Patrick Eriksson.
% 2010-02-12  Extended to also handle FOS by Patrick Eriksson.
% 2007-07-27  Extended to also handle MC by Patrick Eriksson.
% 2005-06-13  Created by Claudia Emde


function [Q,f,ztan,y_c,y,dy] = qarts_scattering_demo( varargin )
%
[ztan,method,m_arg,iwcfac] = optargs( varargin, { [7 10 13]*1e3, 'mc', 5, 1 });


%= Init Q structure
%
Q  = qarts;


%= Overall settings
%
Q.CLOUDBOX_DO       = false;
Q.J_DO              = false;
Q.SENSOR_DO         = false;
%
Q.INCLUDES          = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                        fullfile( 'ARTS_INCLUDES', 'continua.arts' )};


%= General part
%
f                   = linspace( 501.18e9, 501.58e9, 3 )';
%f                   = linspace( 299e9, 301e9, 2 )';
Q.F_GRID            = f;
Q.STOKES_DIM        = 2;
%
Q.ABS_SPECIES(1).TAG{1} = 'ClO';
Q.ABS_SPECIES(2).TAG{1} = 'O3';
Q.ABS_SPECIES(3).TAG{1} = 'N2O';
Q.ABS_SPECIES(4).TAG{1} = 'H2O-*-490e9-510e9';  % Some local lines not in PWR98
Q.ABS_SPECIES(4).TAG{2} = 'H2O-PWR98';
Q.ABS_SPECIES(5).TAG{1} = 'N2-SelfContStandardType';


%= Define atmosphere and surface
%
Q.ATMOSPHERE_DIM      = 1;
%
Q.P_GRID              = z2p_simple( [0:500:45e3 46e3:1e3:80e3] )';
%
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                                            'Fascod', 'tropical', 'tropical' );
Q.RAW_ATM_EXPAND_1D   = false;
%
Q.REFELLIPSOID        = ellipsoidmodels( 'SphericalEarth' );
Q.Z_SURFACE           = 500;


%= Absorption
%
Q.ABS_LINES_FORMAT    = 'Arts';
Q.ABS_LINES           = fullfile( atmlab_example_data , 'lines501.4' );
Q.ABS_NLS             = [];
%
Q                     = qarts_abstable( Q );


%= Set RTE variables
%
Q.YCALC_WSMS          = { 'sensor_checkedCalc','yCalc' };
%
Q.PPATH_LMAX          = 5e3/max([1,6*iwcfac]);
Q.PPATH_LMAX 
%
zplat                 = 600e3;
sensor_pos            = zplat;
Q.SENSOR_POS          = repmat( sensor_pos, length(ztan), 1 );
Q.SENSOR_LOS          = geomztan2za( Q.REFELLIPSOID(1), zplat, ztan )';
%
if strcmp( lower(method), 'tr' )
  Q.IY_MAIN_AGENDA        = { 'iyTransmissionStandard' };
  Q.IY_TRANSMITTER_AGENDA = { 'Ignore(rte_pos)', 'Ignore(rte_los)', ...
                              'MatrixUnitIntensity(iy,stokes_dim,f_grid)' };
  Q.IY_UNIT               = '1';
else
  Q.IY_UNIT               = 'RJBT';
end
  


% Calculate clearsky
%
y_c = arts_y( Q );



%= Setting structure for cloudbox and scattering solution method
%
C               = qartsCloudbox;
Q.WSMS_AT_START = { 'FlagOff( use_mean_scat_data )' };


%- Define 1D cloudbox and particles

C.LIMITS = [ 6e3 16e3 ];

% Temperature for scattering data (if only one is given, no
% temperature interpolation is performed in ARTS calculation.
T_grid = [200 270];   % MC does not accept a single temperature!


% Create scattering properties for a simple cloud assumption
% (mono disperese particle distribution)

% Calculate refractive indices 
rfr_index = zeros( length(Q.F_GRID), length(T_grid) );
%
for i = 1 : length(T_grid)     % Note .' below. We do not want to conjugate
  rfr_index(:,i) = sqrt(eps_ice_matzler06( Q.F_GRID, T_grid(i) ) ).';
end


% Scattering angles
theta = 0:10:180;
% Particle size [m]
r = 50e-6;
% ice mass content
imc = iwcfac * 0.005*1e-3;
% cloud altitude
alt = [11e3 13e3];

% Calculate scattering data using Mie
C.SCAT_DATA{1} = mie_arts_scat_data( Q.F_GRID,  T_grid, rfr_index, theta, r );

% Calculate a pnd field for a homogeneous cloud
C.PND_FIELD{1} = box_pnd_mono_size_1d( alt, imc, r );


% Set up scattering method
%
if strcmp( lower(method), 'mc' )
  %
  C.METHOD                        = 'MC';
  Q.IY_MAIN_AGENDA                = { 'Ignore( rte_pos2 )', 'iyMC', ...
                                      'Touch(ppath)' };
  Q.IY_AUX_VARS                   = { 'Error (uncorrelated)' };
  %
  C.METHOD_PRMTRS.STD_ERR         = m_arg;
  C.METHOD_PRMTRS.MAX_TIME        = -1;
  C.METHOD_PRMTRS.MAX_ITER        = -1;
  C.METHOD_PRMTRS.MIN_ITER        = 100;
  %
elseif strcmp( lower(method), 'doit' )
  %
  C.METHOD                        = 'DOIT';
  % Need a trick here for setting RJ
  Q.IY_UNIT                       = '1';
  Q.WSMS_BEFORE_RTE{end+1}        = 'StringSet(iy_unit,"RJBT")';  
  % Angular grids
  C.METHOD_PRMTRS.N_ZA_GRID       =  19;
  C.METHOD_PRMTRS.N_AA_GRID       =  10;
  C.METHOD_PRMTRS.ZA_GRID_OPT_FILE = fullfile( atmlab_example_data, ...
                                                           'doit_za_grid.xml');
  C.METHOD_PRMTRS.EPSILON         = [ 0.1 0.01 0.01 0.01 ];
  C.METHOD_PRMTRS.SCAT_ZA_INTERP  = 'polynomial';
  C.METHOD_PRMTRS.ALL_F           = false;
  %
  C.OPT_PROP_PART_AGENDA = { 'ext_matInit', 'abs_vecInit', 'ext_matAddPart', ...
                                                           'abs_vecAddPart' };
  C.SPT_CALC_AGENDA = { 'opt_prop_sptFromMonoData' };

elseif strcmp( lower(method), 'fos' )
  %
  fos_file = '/tmp/fos_angles.xml';
  %
  C.METHOD                        = 'FOS';
  Q.WSMS_BEFORE_RTE{end+1}        = 'AgendaSet( fos_y_agenda ){';
  Q.WSMS_BEFORE_RTE{end+1}        = '   fos_yStandard';
  Q.WSMS_BEFORE_RTE{end+1}        = '}';
  Q.WSMS_BEFORE_RTE{end+1}        = 'AgendaSet( iy_cloudbox_agenda ){';
  Q.WSMS_BEFORE_RTE{end+1}        = '   iyFOS';
  Q.WSMS_BEFORE_RTE{end+1}        = '}';
  Q.WSMS_BEFORE_RTE{end+1}        = sprintf( ...
                                       'ReadXML(fos_angles, "%s")', fos_file );
  Q.WSMS_BEFORE_RTE{end+1}        = 'IndexSet( fos_n, 1 )';
  %
  if 0
    fos = eq_point_set_polar( 2, 5 );
    fos = rotate_in( fos );
    fos = fliplr( fos' );
    fos = 180/pi*fos;
    ind = find( fos(:,2) > 180 );
    fos(ind,2) = fos(ind,2) - 360;
  else
    fos = fos28nonrot;
    %fos = fos2
  end
  
  fos(:,3) = 4*pi / size(fos,1);
  %  
  xmlStore( fos_file, fos, 'Matrix' );

elseif strcmp( lower(method), 'tr' )
  %
  C.METHOD = 'none';

    
else
  error( ...
    'Allowed options for *method* are ''doit'', ''mc'' and ''tr''.' );
end


%- Map to 2D or 3D?
%
latlon_grid = [-45 -20:5:20 45]';
csize       = 10;
%
if any( strcmp( lower(method), {'fos','tr'} ) )  &  m_arg == 2
  %
  Q.ATMOSPHERE_DIM                = 2;
  Q.RAW_ATM_EXPAND_1D             = true;
  Q.LAT_GRID                      = latlon_grid;
  Q.Z_SURFACE                     = repmat( Q.Z_SURFACE, length(latlon_grid),1);
  %  
  Q.SENSOR_POS                    = repmat( Q.SENSOR_POS, 1, 2 );
  Q.SENSOR_POS(:,2)               = -23;
  %
  C.LIMITS                        = [ C.LIMITS csize*[-2 2] ];
  C.PND_FIELD{1}.grids{2}         = [ -90 csize*[-2 -1.5 1.5 2] 90 ];
  p                               = C.PND_FIELD{1}.data;
  C.PND_FIELD{1}.data             = zeros( length( C.PND_FIELD{1}.grids{1} ),...
                                           length( C.PND_FIELD{1}.grids{2} ) );
  C.PND_FIELD{1}.data(:,3:4)      = repmat(p,[1 2]);
  %  
elseif strcmp( lower(method), 'mc' )  |  ...
     ( any( strcmp( lower(method), {'fos','tr'} ) )  &  m_arg == 3 )  
  %
  Q.ATMOSPHERE_DIM                = 3;
  Q.RAW_ATM_EXPAND_1D             = true;
  Q.LAT_GRID                      = latlon_grid;
  Q.LON_GRID                      = latlon_grid;
  Q.Z_SURFACE                     = repmat( Q.Z_SURFACE, length(latlon_grid),...
                                                         length(latlon_grid) );
  %  
  Q.SENSOR_POS                    = repmat( Q.SENSOR_POS, 1, 3 );
  Q.SENSOR_POS(:,2)               = -20;
  Q.SENSOR_POS(:,3)               = 0;
  Q.SENSOR_LOS                    = repmat( Q.SENSOR_LOS, 1, 2 );
  Q.SENSOR_LOS(:,2)               = 0;
  %
  C.LIMITS                        = [ C.LIMITS csize*[-2 2 -2 2] ];
  C.PND_FIELD{1}.grids{2}         = [ -90 csize*[-2 -1.5 1.5 2] 90 ];
  C.PND_FIELD{1}.grids{3}         = C.PND_FIELD{1}.grids{2};
  p                               = C.PND_FIELD{1}.data;
  C.PND_FIELD{1}.data             = zeros( length( C.PND_FIELD{1}.grids{1} ),...
                                           length( C.PND_FIELD{1}.grids{2} ),...
                                           length( C.PND_FIELD{1}.grids{3} ) );
  C.PND_FIELD{1}.data(:,3:4,3:4)  = repmat(p,[1 2 2]);
  %
end



%- Activate cloudbox
%
Q.CLOUDBOX_DO = true;
Q.CLOUDBOX    = C;



% Calculate radiances with scattering
%
if strcmp( lower(method), 'mc' )
  [y,ydata,y_aux] = arts_y( Q );
  dy = y_aux{1};
else
  y  = arts_y( Q );
  dy = NaN;
end

return




function fos_angles = fos28nonrot
fos_angles = [
         0         0
   38.4684   36.0000
   38.4684  108.0000
   38.4684  180.0000
   38.4684 -108.0000
   38.4684  -36.0000
   72.5750   13.5000
   72.5750   58.5000
   72.5750  103.5000
   72.5750  148.5000
   72.5750 -166.5000
   72.5750 -121.5000
   72.5750  -76.5000
   72.5750  -31.5000
  107.4250   36.0000
  107.4250   81.0000
  107.4250  126.0000
  107.4250  171.0000
  107.4250 -144.0000
  107.4250  -99.0000
  107.4250  -54.0000
  107.4250   -9.0000
  141.5316   67.5000
  141.5316  139.5000
  141.5316 -148.5000
  141.5316  -76.5000
  141.5316   -4.5000
  180.0000         0 ];
return


function fos_angles = fos10nonrot
fos_angles = [
         0         0
   63.4349   45.0000
   63.4349  135.0000
   63.4349 -135.0000
   63.4349  -45.0000
  116.5651   90.0000
  116.5651  180.0000
  116.5651  -90.0000
  116.5651         0
  180.0000         0 ];
return


function fos_angles = fos2
fos_angles = [
        45         0
       135         0 ];
return



function in = rotate_in( in )

  DEG2RAD = constants( 'DEG2RAD' );
  RAD2DEG = constants( 'RAD2DEG' );

  rot = in(2,2) / 4;
  
  % The arts_*zaaa* functions have been removed. See ARTS source code if
  % needed to be reimplemented.
  
  [x,y,z] = arts_zaaa2cart( RAD2DEG*in(2,:), RAD2DEG*in(1,:) );
  
  u = rotationmat3D( rot, [0 1 0]) * [x;y;z];

  [za,aa] = arts_cart2zaaa( u(1,:), u(2,:), u(3,:) );

  in = DEG2RAD * [aa;za];
  
return
