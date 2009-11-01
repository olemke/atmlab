function test_qpack2
  

arts_xmldata_path = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
fascod = fullfile( arts_xmldata_path, 'atmosphere', 'fascod' );


%- Simulate an upward-looking O3-111GHz radiometer placed in lower stratosphere
%
Q                        = qpack2;
%
Q.PLATFORM_Z             = 15e3;
Q.SURFACE_Z              = Q.PLATFORM_Z;
Q.PLATFORM_LAT           = 58;
Q.PLATFORM_LON           = -12;
%
Q.ABS_LINES              = fullfile( atmlab_example_data , 'o3line111ghz' );
Q.ABS_LINES_FORMAT       = 'Arts';
%
Q.Y_UNIT                 = 'RJBT'; 
Q.CBGR                   = 0;
%
Q.F_GRID                 = qarts_get( fullfile( atmlab_example_data , ...
                                                         'f_grid_111ghz.xml' ) );
Q.BACKEND_DO             = 1;
df                       = 0.5e6;
Q.F_BACKEND              = min(Q.F_GRID)+df : df : max(Q.F_GRID)-df;
%
B.name                   = 'Spectrometer channel response function';
B.gridnames              = { 'Frequency' };
B.grids                  = { [-df/2 df/2] };
B.dataname               = 'Response';
B.data                   = [1 1];
%
Q.BACKEND_CHANNEL_RESPONSE{1} = B;
%
cfun                     = 'drc';
cl                       = 1.85 * df;
cco                      = 0.02;
%
Q.TNOISE_C               = covmat1d_from_cfun( Q.F_BACKEND, [], cfun, cl, cco );

%- Temperature
Q.T.ATMDATA              = gfin_artsxml( clmtlgy_define, [], ...
                           fullfile( fascod, 'midlatitude-winter.t.xml' ), ...
                                                                 [], 't_field' ); 

%- Ozone
%
vmr0                     = 2e-6;
%
Q.SPECIES(1).TAG{1}{1}   = 'O3';
Q.SPECIES(1).RETRIEVE    = 1;
Q.SPECIES(1).GRID        = z2p_simple(Q.PLATFORM_Z-1e3:2e3:95e3);
Q.SPECIES(1).ATMDATA.DIMS      = [1];
Q.SPECIES(1).ATMDATA.SOURCE    = 'Set manually';
Q.SPECIES(1).ATMDATA.NAME      = 'Ozone';
Q.SPECIES(1).ATMDATA.GRID1     = [1050e2 1e-5];
Q.SPECIES(1).ATMDATA.DATA      = vmr0*[1;1];
Q.SPECIES(1).ATMDATA.DATA_NAME = 'VMR';
Q.SPECIES(1).ATMDATA.DATA_UNIT = '-';
%
SX                       = covmat1d_from_cfun( Q.SPECIES(1).GRID, 1, 'lin', ...
                                                               1, 0.00, @log10 );
Q.SPECIES(1).UNIT        = 'rel';   % So far just dummy value
Q.SPECIES(1).SX          = SX;      % So far just dummy value
%
Q.SPECIES(2).TAG{1}{1}   = 'H2O';
Q.SPECIES(2).RETRIEVE    = 0;
Q.SPECIES(2).ATMDATA     = gfin_artsxml( clmtlgy_define, [], ...
                            fullfile( fascod, 'midlatitude-winter.h2o.xml' ), ...
                                                            'H2O', 'vmr_field' );

%- Create an empty measurement
%
Y                        = qp2_y;
Y.ZA                     = 60;
Y.F                      = Q.F_BACKEND;
Y.TNOISE                 = 0.05;
Y.HSE_P                  = 10e2;
Y.HSE_Z                  = 31e3;

%- OEM
%
Q.OEM_LINEAR             = 1;
%
Q.OEM_ITERMETHOD          = 'GN';
Q.OEM_STOP_DX            = 1e-2;
Q.OEM_MAXITER            = 19;




%--- Start of calculations ------------------------------------------------------

%- Spectrum for a priori state
%
Y1 = qpack2( Q, Y );


%- Make inversion for same a priori uncertainty, but in different units
%
si_rel                     = 0.4;
%
Q.SPECIES(1).UNIT          = 'rel';
Q.SPECIES(1).SX            = si_rel^2 * SX;
P1rel                      = qpack2( Q, Y1 );
%
Q.SPECIES(1).UNIT          = 'logrel';
P1logrel                   = qpack2( Q, Y1 );
%
Q.SPECIES(1).UNIT          = 'vmr';
Q.SPECIES(1).SX            = (si_rel*vmr0)^2 * SX;
P1vmr                      = qpack2( Q, Y1 );
%
should_be_close( 1e-15, 'P1rel', P1rel, 'P1vmr', P1vmr ); 
should_be_close(  1e-8, 'P1rel', P1rel, 'P1logrel', P1logrel ); 



%- Same but for state 2*Y1
%
Q2                         = Q;
Q2.SPECIES(1).ATMDATA.DATA = 2*Q.SPECIES(1).ATMDATA.DATA;
Y2                         = qpack2( Q2, Y );
Q.OEM_LINEAR               = 0;
%
Q.SPECIES(1).UNIT          = 'rel';
Q.SPECIES(1).SX            = si_rel^2 * SX;
P2rel                      = qpack2( Q, Y2 );
%
Q.SPECIES(1).UNIT          = 'logrel';
P2logrel                   = qpack2( Q, Y2 );
%
Q.SPECIES(1).UNIT          = 'vmr';
Q.SPECIES(1).SX            = (si_rel*vmr0)^2 * SX;
P2vmr                      = qpack2( Q, Y2 );
%
should_be_close( 1e-8, 'P2rel', P2rel, 'P2logrel', P2logrel, 1 ); 
should_be_close( 1e-8, 'P2rel', P2rel, 'P2vmr', P2vmr ); 
should_be_close( 1e-8, 'P1rel', P1rel, 'P2rel', P2rel, 1 ); 


%- Turn on frequency to active O.sxnorm option
%
%
Q.FFIT_DO                 = 1;
Q.FFIT_ORDER              = 0;
Q.FFIT_SI                 = [100e3]; 
Q.FFIT_DF                 = 50e3; 
%
P3vmr                     = qpack2( Q, Y2 );
%
should_be_close( 1e-8, 'P2vmr', P2vmr, 'P3vmr', P3vmr ); 



% The part below generates n cases where std(Xt,[],2) can be compared directly
% to P2logrel.species1_eo:
%     z=p2z_simple(P2rel.species1_p)/1e3;
%     plot(std(Xt,[],2),z,P2logrel.species1_eo,z,)
%
if 0
  n  = 3000;
  Xt = zeros( length(P2logrel.species1_x), n );
  for i = 1:n
    fprintf( '%d/%d\n', i, n );
    Yt      = Y2;
    Yt.Y    = Yt.Y + Y.TNOISE*randn(size(Yt.Y));
    Pt      = qpack2( Q, Yt );
    Xt(:,i) = Pt.species1_x;
  end
end


function should_be_close( dvmr, name1, P1, name2, P2, ignore_x )
  %
  if nargin < 6  |  ~ignore_x  
    if max( abs( P1.species1_x-P2.species1_x ) ) > dvmr
      error( sprintf( 'Retrieved x is not sufficient close for %s and %s.', ...
                    name1, name2 ) );
    end  
  end
  if max( abs( P1.species1_eo-P2.species1_eo ) ) > dvmr
    error( sprintf( 'Obtained eo is not sufficient close for %s and %s.', ...
                    name1, name2 ) );
  end
  if max( abs( P1.species1_e-P2.species1_e ) ) > dvmr
    error( sprintf( 'Obtained e is not sufficient close for %s and %s.', ...
                    name1, name2 ) );
  end

  

