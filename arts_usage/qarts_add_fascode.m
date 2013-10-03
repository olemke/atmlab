% QARTS_ADD_FASCODE   Includes a Fascode atmosphere
%
%  Expands Q to import one of the five Fasoce atmospheres. These atmospheres
%  are named as 'tropical', 'midlatitude-summer', 'midlatitude-winter',
%  'subarctic-summer' and 'subarctic-winter'.
%
%  Q.ATMSOPHERE_DIM must be set, and can be 1, 2 or 3. Fields of Q set by 
%  the function are P_GRID, LAT_GRID (only 2D and 3D), LON_GRID (only 3D), 
%  LAT_TRUE, LON_TRUE, ABS_SPECIES, HSE (set to to true), RAW_ATMOSPHERE and
%  Q.RAW_ATM_EXPAND_1D.
%
%  The P_GRID set reaches about 95 km. LAT/LON_TRUE are set to representative
%  values for the selected atmosphere. For 3D, LON_GRID is set to cover the
%  complete planet ([-180,180], can be modfified by *A.lon0*). For 2D and 3D,
%  LAT_GRID is set to cover pole to pole, with a spacing of 3 degrees. Final,
%  T_FIELD and VMR_FIELD will not have any latitudinal variation, but a
%  latitude grid is required to capture the variation in Z_FIELD originating
%  from the constrain of HSE. Note that LAT_GRID can be controlled cropped by
%  *A.lat_min* and *A.lat_max*.
%  
%  The mandatory fields of A are
%   'fascode_atm' : String with name of atmosphere, eg. 'tropical'.
%   'ABS_SPECIES' : These data are copied to Q.ABS_SPECIES. 
%   
%  Optional fields are
%   'p_min'   : Crop P_GRID at this value. Lower values are rejected.
%   'lat_min' : Crop LAT_GRID at this value. Lower values are rejected.
%   'lat_min' : Crop LAT_GRID at this value. Higher values are rejected.
%   'lon0'    : Focus LON_GRID on this value, ie. LON_GRID = 
%               A.lon0 + [-180,180] 
%
% FORMAT Q = qarts_add_fascode( A, Q, workfolder )
%
% OUT   Q          Modified Q
% IN    A          Atmosphere structure, see above.
%       Q          Original Q
%       workfolder Path to workfolder (not used, but an input is demanded)

% 2013-09-29   Created by Patrick Eriksson.

function Q = qarts_add_fascode( A, Q, workfolder )
%
rqre_datatype( A, { @isstruct } );
rqre_datatype( Q, { @isstruct } );
rqre_datatype( workfolder, { @ischar,@isempty } );


arts_xmldata_path       = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to set ARTS_XMLDATA_PATH to use this function.');
end


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

Q.LON_TRUE              = 0;


Q.ABS_SPECIES           = A.ABS_SPECIES;


Q.P_GRID                = z2p_simple( -250 : 250 : 95e3 )';
%
if isfield( A, 'p_min' )
  ind      = find( Q.P_GRID >= A.p_min );
  Q.P_GRID = Q.P_GRID( ind );  
end
%
Q.HSE.ON                = true;
Q.HSE.P                 = Q.P_GRID(2);
Q.HSE.ACCURACY          = 1;


if ~qarts_isset( Q.ATMOSPHERE_DIM )
  error( 'Q.ATMOSPHERE_DIM must be set.' );
end
%
if Q.ATMOSPHERE_DIM == 1
  Q.RAW_ATM_EXPAND_1D     = false;
else Q.ATMOSPHERE_DIM == 3
  Q.LON_GRID              = [ -180 180 ];
  if isfield( A, 'lon0' )
    Q.LON_GRID            = A.lon0 + Q.LON_GRID;    
  end
end

if Q.ATMOSPHERE_DIM > 1
  Q.RAW_ATM_EXPAND_1D     = true;
  Q.LAT_GRID              = [ -90 : 3 : 90 ]';
  %
  ind        = find( Q.LAT_GRID >= safegetfield( A, 'lat_min', -Inf )  &  ...
                     Q.LAT_GRID <= safegetfield( A, 'lat_max', Inf  )   );
  Q.LAT_GRID = Q.LAT_GRID( ind );
end



