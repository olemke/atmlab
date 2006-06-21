% QARTS1_DEMO   A demonstration of Qarts1
%
%    Gives an example on how Qarts1 can be used.
%
% FORMAT   Q = qarts1_demo( ztan )
%        
% OUT   Q      Qarts setting structure.
% OPT   ztan   Tangent altitude.

% 2005-03-14   Created by Patrick Erikssom.


function  [Q,f,y] = qarts1_demo( ztan )

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


%= Atmosphere
%
atmlab( 'require', {'ARTS1_DATA_PATH'} );
%
Q.P_ABS               = z2p_simple( [0:500:45e3 46e3:1e3:80e3] );
%
Q.USE_RAW_ATMOSPHERE  = 1;
Q.APRIORI_VMR         = fullfile( atmlab( 'ARTS1_DATA_PATH' ), 'atmosphere',...
                                                        'fascod', 'tropical' );
Q.APRIORI_PTZ         = [ Q.APRIORI_VMR, '.tz.aa' ];


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
if ~nargout
  plot( Q.F_MONO/1e9, y )
  xlabel( 'Frequency [GHz]' )
  ylabel( 'Brightness temperature [K]' )
  title( sprintf( 'Odin-SMR ClO band (tangent altitude = %.1f km)', ztan/1e3));
else
  f = Q.F_MONO;
end
