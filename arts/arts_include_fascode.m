function Q = arts_include_fascode( A, Q, strinput )
%
rqre_datatype( A, { @isstruct } );
rqre_datatype( Q, { @isstruct, @ischar } );
rqre_datatype( strinput, { @ischar } );


%- Handle queries
if ischar(Q)

  if ~strcmp( Q, 'query' )
    error( 'Unrecognised choice for *Q* (%s).', Q );
  end
  
  switch lower( strinput )
   case 'free_electrons_supported'
    Q = false;
   otherwise
    error( 'Unrecognised choice for *strinput* (%s).', strinput );
  end
  return   % ---->
end



% Otherwise add atmosphere:

workfolder = strinput;


arts_xmldata_path       = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to set ARTS_XMLDATA_PATH to use this function.');
end


Q.P_GRID = z2p_simple( -250 : 250 : 95e3 )';

Q.HSE.ON                = true;
Q.HSE.P                 = Q.P_GRID(2);
Q.HSE.ACCURACY          = 1;


switch lower( A.fascode_atm )
  
  case 'tropical'  
     Q.RAW_ATMOSPHERE = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                                           'Fascod', 'tropical', 'tropical' );
     Q.LAT_TRUE       = 10;
  case 'midlatitude-summer'  
     Q.RAW_ATMOSPHERE = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                       'Fascod', 'midlatitude-summer', 'midlatitude-summer' );
     Q.LAT_TRUE       = 45;
  case 'midlatitude-winter'  
     Q.RAW_ATMOSPHERE = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                       'Fascod', 'midlatitude-winter', 'midlatitude-winter' );
     Q.LAT_TRUE       = 45;
  case 'subarctic-summer'  
     Q.RAW_ATMOSPHERE = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                       'Fascod', 'subarctic-summer', 'subarctic-summer' );
     Q.LAT_TRUE       = 75;
  case 'subarctic-winter'  
     Q.RAW_ATMOSPHERE = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                       'Fascod', 'subarctic-winter', 'subarctic-winter' );
     Q.LAT_TRUE       = 75;
     
 otherwise
  error( 'Unrecognised choice for *A.fascode_atm* (%s).', A.fascode_atm );
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


