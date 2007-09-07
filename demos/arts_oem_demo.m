% ARTS_OEM_DEMO   Demonstration of inversions using ARTS and OEM
%
%    The example treats ground-based measurements of ozone at 110.8 GHz.
%
% FORMAT   arts_oem_demo

% 2006-09-07   Created by Patrick Eriksson.

function arts_oem_demo


%= Check if arts-xml-data is found
%
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
%
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end



%- Init control structures 
%
Q      = qarts;
Q.J    = qartsJacobian;
Q.J_DO = 1;
SX     = [];



%- Basic qarts settings
%
Q.ATMOSPHERE_DIM      = 1;
Q.STOKES_DIM          = 1;
%
Q.P_GRID              = z2p_simple( 0:500:90e3 );
Q.Z_SURFACE           = 500;
%
Q.USE_RAW_ATMOSPHERE  = 1;
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                              'fascod', 'midlatitude-winter' );
%
Q.PPATH_STEP_AGENDA   = { 'ppath_stepGeometric{5e3}' };
Q.Y_UNIT              = 'RJ';
%
Q.SENSOR_LOS          = 70;
Q.SENSOR_POS          = Q.R_GEOID + Q.Z_SURFACE;



%- Exclude cosmic background radiation. A relative change of the spectrum
%- corresponds then to a relative change of the ozone profile.
%
Q.IY_SPACE_AGENDA = { 'Ignore(rte_los){}',  'Ignore(rte_pos){}', ...
                      'nelemGet(f_grid){}', 'Copy(nrows,nelem){}', ...  
                      'Copy(ncols,stokes_dim){}', 'MatrixSet(iy){0}' };



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
H.CHANNEL_RESPONSE    = { [-df/2 1; df/2 1] };
%
Q.SENSOR_DO           = 1;
Q.SENSOR_RESPONSE     = H;
Q.MBLOCK_ZA_GRID      = 0;



%- Define ozone as retrieval quantity
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



%- Absorption
%
% Water vapour is always needed (no absorption is here included)
Q = qarts_abs_species( Q, { 'H2O' } );
%
Q.ABS_LINES_FORMAT    = 'Arts';
Q.ABS_LINES           = fullfile( atmlab_example_data , 'o3line111ghz' );
Q                     = qarts_abstable( Q );



%- Calculate a spectrum matching a priori
%
y = arts_y( Q );



%- Create Se
%
si = 0.01;
%
SE.FORMAT    = 'param';
SE.SI        = si;
SE.CCO       = 0;  
SE.CFUN1     = 'drc';
%
Se = arts_covmat( 1, SE, Q.SENSOR_RESPONSE.F_BACKEND );



%- Measurement
%
y = 1.1 * y + si*randn(size(Se,1),1);



%- OEM
%
O.method  = 'GN';
O.stop_dx = 0.01;
O.maxiter = 10;
%
O.cost    = 1;
O.Xiter   = 1;
O.yf      = 1;
O.J       = 1;
O.A       = 1;
O.S       = 0;
O.So      = 0;
O.Ss      = 0;
O.d       = 0; 
O.do      = 1;
O.ds      = 0;
%
[Qoem,R,xa] = arts_oem_init( Q );
Sx          = arts_sx( Q, R, SX );
[x,P]       = oem( O, Qoem, R, @arts_oem, Sx, Se, [], [], xa, y );
%
arts_oem( 'clean', R );
clear Qoem O


z = p2z_simple( Q.J.ABS_SPECIES(1).GRID1 );


plot( x, z/1e3 )
xlabel( 'Retrieved profile' )
ylabel( 'Approximative altitude [km]' );