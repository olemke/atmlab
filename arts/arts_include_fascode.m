function Q = arts_include_fascode( Q, A, workfolder )
  

arts_xmldata_path       = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to set ARTS_XMLDATA_PATH to use this function.');
end


Q.P_GRID = p2z_simple( -250 : 250 : 95e3 )';

Q.HSE.ON                = true;
Q.HSE.P                 = Q.P_GRID(1);
Q.HSE.ACCURACY          = 1;


switch lower( A.fascode_atm )
  
  case 'tropical'  
     Q.RAW_ATMOSPHERE = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                                           'Fascod', 'tropical', 'tropical' );
     Q.LAT_TRUE       = 10;

 otherwise
  error( 'Unrecognised choice for A.fascode_atm (%s).', A.fascode_atm );
end

Q.LON_TRUE              = -30;


if ~qarts_isset( Q.ATMOSPHERE_DIM )
  error( 'Q.ATMOSPHERE_DIM must be set.' );
end
%
if Q.ATMOSPHERE_DIM == 1
  Q.RAW_ATM_EXPAND_1D     = false;
else
  Q.RAW_ATM_EXPAND_1D     = true;
end


