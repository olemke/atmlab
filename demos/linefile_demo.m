% LINEFILE_DEMO   Demosntration on usage of ARTS1_CREATE_LINEFILE
%
%   Selects H2O transitions (only local ones) for a range around 490.5 GHz.
%   A SSB reciever is assumed, with image band around 498.5 GHz. The 
%   sideband leakage has a max value of 3%. 
%
% FORMAT   linefile_demo

% 2005-03-17   Created by Patrick Erikssom.

function linefile_demo


%= Make sure that AMI is in the search path. Needed to read/write ARTS1 files
%
addpath_ami;


%= Init Q structure
%
Q = qarts1;


%= Set needed Q fields
%
Q.P_ABS          = z2p_simple( [0:1e3:45e3 46e3:2e3:80e3] );
Q.Z_PLAT         = 600e3;
Q.Z_GROUND       = 500;
Q.L_STEP         = 10e3;
Q.REFR_ON        = 0;
%
Q.ZA_PENCIL      = geomztan2za( Q.R_GEOID, Q.Z_PLAT, 10e3:10e3:30e3 );


C.TB_LIMIT   = 0.02;
C.N_TESTATMS = 3;
%
C.MOLECULES  = { 'H2O-161', 'H2O-162', 'H2O-171', 'H2O-181' };
%
C.DF_SEARCH  = [ 10e9, 10e9, 10e9, 10e9 ];
%
C.BANDDATA     = [ 490e9 491e9  1;
                   498e9 499e9  0.03 ];


[L,tb_max]   = arts1_create_linefile( Q, C );

keyboard

% To save data to a file:
%
%arts_write_linefile( 'linefile_demo.ac', L );








