% QARTS1_DEMO   A demonstration of Qarts1
%
%    Gives an example on how Qarts1 can be used.
%
% FORMAT   Q = qarts1_demo( ztan )
%        
% OUT   Q      Qarts setting structure.
% OPT   ztan   Tangent altitude.

% 2005-03-14   Created by Patrick Erikssom.


function Q = qarts_demo( ztan )

if nargin == 0
  ztan = 30e3;
end


%= Make sure that AMI is in the search path. Needed to read/write ARTS1 files
%
addpath_ami;


%= Init Q structure
%
Q = qarts1;


%= Spectroscopy
%
Q.TGS{1}{1} = 'ClO';
Q.TGS{2}{1} = 'O3';
Q.TGS{3}{1} = 'N2O';
Q.TGS{4}{1} = 'H2O';
Q.TGS{4}{2} = 'H2O-MPM89';
Q.TGS{5}{1} = 'N2-SelfContStandardType';
%
Q.F_MONO         = linspace( 501.18e9, 501.58e9, 201 );
%
Q.LINEFORMAT    = 'Arts';
Q.LINEDATA      = fullfile( atmlab_example_data , 'lines501.4' );


%= Use Qarts to obtain atmospheric fields
%
QQ = qarts;
%
QQ.GAS_SPECIES         = Q.TGS;
QQ.ATMOSPHERE_DIM      = 1;
arts_xmldata_path      = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
QQ.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, ...
                        fullfile( 'atmosphere', ...
                        fullfile( 'fascod', 'tropical' ) ) );
QQ.P_GRID              = z2p_simple( [0:500:45e3 46e3:1e3:80e3] );
%
Q.USE_RAW_ATMOSPHERE = 0;
Q.P_ABS              = QQ.P_GRID;
%
[Q.T_ABS,Q.Z_ABS,Q.VMRS] = arts_get_atmfields( QQ );
%
clear QQ


%= RTE 
%
Q.Z_PLAT         = 600e3;
Q.ZA_PENCIL      = geomztan2za( Q.R_GEOID, Q.Z_PLAT, ztan );
%
Q.Z_GROUND       = 500;
Q.T_GROUND       = 280;
Q.E_GROUND       = 0.7*ones(size(Q.F_MONO));
Q.L_STEP         = 10e3;
Q.HSE_ON         = 0;
Q.REFR_ON        = 0;

%= Calculate spectrum
%
y = arts1_y( Q );


%= Plot
%
plot( Q.F_MONO/1e9, y )
xlabel( 'Frequency [GHz]' )
ylabel( 'Brightness temperature [K]' )
title( sprintf( 'Odin-SMR ClO band (tangent altitude = %.1f km)', ztan/1e3 ) );

