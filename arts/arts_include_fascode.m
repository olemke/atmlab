% ARTS_INCLUDE_FASCODE   Includes a Fascode atmosphere
%
%   The first way to use the function is modify the Q structure in such way
%   that the selected atmosphere is included in the calculations. The format
%   is then:
%
% FORMAT   Q = arts_include_fascode( A, Q, strinput )
%        
% OUT   Q          Modified Q
% IN    A          Atmosphere structure, see below.
%       Q          Original Q
%       strinput   Path to workfolder (not used, but an input is demanded)
%
%  The structure A must contain the field (but can contain further fields)
%    fascode_atm : Name of the atmosphere, eg. 'midlatitude-winter'.
%
%  Fields of Q set by the function are P_GRID, LAT_TRUE,LON_TRUE, HSE,
%  RAW_ATMOSPHERE and Q.RAW_ATM_EXPAND_1D.
%  
%  Q.ATMSOPHERE_DIM must be set, and can be 1, 2 or 3. Note that LAT_GRID
%  and LON_GRID are not set by the function.
%
%  Queries can also be given to the function. This feature can be used by
%  the calling function to check if some feature can be included.  
%
% FORMAT   answer = arts_include_fascode( A, 'query', strinput )
%
% Handled options for *strinput* are
%   free_electrons_supported : Can the function include free electrons? The
%   answer is false.

% 2013-09-29   Created by Patrick Eriksson.

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

Q.LON_TRUE              = 0;


if ~qarts_isset( Q.ATMOSPHERE_DIM )
  error( 'Q.ATMOSPHERE_DIM must be set.' );
end
%
if Q.ATMOSPHERE_DIM == 1
  Q.RAW_ATM_EXPAND_1D     = false;
else
  Q.RAW_ATM_EXPAND_1D     = true;
end


