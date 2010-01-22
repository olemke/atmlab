% QPACK2   Main function of Qpack2
%
%    Read qpack2.pdf for an introduction to Qpack2.
%
%    The function can be used in two main ways:
%------------------------------------------------------------------------------
%
%    1: The function defines all Qpack2 fields. Most fields are initiated 
%    to {}, that indicates that no value has been specified. Allowed
%    formats differ between the fields. For information about a specific 
%    field, type e.g.:
%       qinfo( @qpack2, 'BEAM_SWITCHING' );
%    That is, the function is organised in such way that *qinfo*
%    can be applied.
%
% FORMAT   [Q,I] = qpack2
%        
% OUT   Q  Setting structure with default values for all recognised fields.
%       I  Includes same fields as Q, where the content of each field
%          is a description string (used by *qinfo*).
%------------------------------------------------------------------------------
%
%    2. To make OEM type inversions. The measurement data are inverted by 
%    combining the function oem.m and the qarts interface to arts-2. 
%
%    The data fields of the output structure P depends on selected retrieval
%    quantities. In addition, the fields to be included in P can to some
%    extent be controlled by the user. Options and avaliable output fields are
%    described in qpack2.pdf.
%
%    The measurements to be inverted (Y) must all correspond to the same sensor
%    characteristics. The sensor response is calculated before the first
%    inversion is started and it is assumed that the reponse matrix obtained is
%    valid for all cases.
%
%    The measurement matching the apriori conditions can be calculated through
%    this function. This can be useful for test retrievals, or comparison with
%    som measurement data. Such calculations are triggered by setting all
%    measurement vectors in Y (that is, Y.Y) to be empty ([]). Note that the
%    field shall be set to [], and not to {} that inside qpack2 and qarts
%    identifies an undefined field.
%
% FORMAT   L2 = qpack2(Q,Y)
%
% IN    Q        Qpack2 setting structure
%       Y        Measurement data.
% OUT   L2       Retrieved data. Or possibly Y with simulated measurements 
%                attached, see further above.

% 2009-08-14   Created by Patrick Eriksson.


function L2 = qpack2(Q,O,Y)


%------------------------------------------------------------------------------
%- Check input
%------------------------------------------------------------------------------
                                                                            %&%
rqre_nargin( 3, nargin );                                                   %&%
rqre_datatype( Q, @isstruct );                                              %&%
rqre_datatype( O, @isstruct );                                              %&%
rqre_datatype( Y, @isstruct );                                              %&%
qcheck( @qarts, Q );                                                        %&%
qcheck( @oem, O );                                                          %&%
qcheck( @qp2_y, Y );                                                        %&%
% Basic checks of Y                                                         %&%
%                                                                           %&%
empty_y = checkY( Y );



%------------------------------------------------------------------------------
%- Loop measurements
%------------------------------------------------------------------------------

L2 = [];
  
if empty_y
  workfolder = create_tmpfolder;
end

ny = length(Y);

for m = 1 : ny
  
  %- Set up data for next measurement
  %

  
  %- Simulate a (noise free) measurement if y is empty
  if empty_y
    %
    Qm = qp2_y2Q( Q, Y, m );
    %
    if isempty( L2 )
      L2    = Y(m);
    else
      L2(m) = Y(m);
    end
    %
    if out(1)
      fprintf( 'Simulating spectrum %d/%d\n', m, ny );
    end
    %
    L2(m).Y = arts_y( Qm, workfolder );
  
    
  %- Inversion
  else
    
    %- Init retrieval
    %
    if ny > 1
      O.msg = sprintf( 'Inversion case %d (of %d)', m, ny );
    end
    %
    [Qm,Se]     = qp2_y2Q( Q, Y, m );
    [Qm,O,R,xa] = arts_oem_init( Qm, O );
    
    %- Sx
    if m == 1
      %
      Sx = arts_sx( Qm, R );
      %
      si = sqrt( diag( Sx ) );
      if max(si) / min(si) <= 1e3
        Sxinv    = Sx \ speye(size(Sx));
        O.sxnorm = 0;
      else
        Sxinv    = [];
        O.sxnorm = 1;
      end
    end

    %- Perform retrieval
    %
    [X,R] = oem( O, Qm, R, @arts_oem, Sx, Se, Sxinv, [], xa, Y(m).Y );
    
    %- Fill return structure
    %
    if isempty( L2 )
      L2    = qp2_l2( Qm, R, xa, O, X, Y, m );
    else
      L2(m) = qp2_l2( Qm, R, xa, O, X, Y, m );
    end
  
    %- Remove workfolder
    %
    arts_oem( 'clean', R );
    clear Qm R  % Just to be safe
    
  end
end


%- Remove work folder
%
if empty_y
  delete_tmpfolder( workfolder );
end

return
%------------------------------------------------------------------------------

% Checks if all Y.Y have the same length
%
function empty_y = checkY( Y )

  % All y empty 
  if isempty( Y(1).Y )
    for i = 2 : length(Y)                                                   %&%
      if length(Y(i).Y) > 0                                                 %&%
        error( ['First spectrum in Y is empty. Then all other '...          %&%
                'spectra must also be empty.'] );                           %&%
      end                                                                   %&%
    end                                                                     %&%
    empty_y = true;
    
  % Standard case 
  else            
    rqre_datatype( Y(1).Y, @istensor1, 'Y(1).Y' );                          %&%
    n = length( Y(1).Y );                                                   %&%
    for i = 2 : length(Y)                                                   %&%
      rqre_datatype( Y(i).Y, @istensor1, sprintf('Y(%d).Y',i) );            %&%
      if length(Y(i).Y) ~= n                                                %&%
        error( 'All spectra must have the same length.' );                  %&%
      end                                                                   %&%
    end                                                                     %&%
    empty_y = false;
  end
return      




function  [Q,Se] = qp2_y2Q( Q, Y, m );

  % If output does not include Se, it assumed that no retrieval will 
  % be performed (for all m). 
  
  %- Stuff only done for first measurement
  %
  if m == 1
    % 1. Make sure that some fields are set as demanded                     %&%
    % 2. "Load" data into Q to avoid repated reading of files               %&%
    if ~qarts_isset(Q.ATMOSPHERE_DIM)                                       %&%
      error( 'Qpack2 requires that Q.ATMOSPHERE_DIM is set to 1.' );        %&%
    end                                                                     %&%
    Q.ATMOSPHERE_DIM = qarts_get( Q.ATMOSPHERE_DIM ); 
    rqre_datatype( Q.ATMOSPHERE_DIM, @istensor0, Q.ATMOSPHERE_DIM );        %&% 
    if Q.ATMOSPHERE_DIM ~= 1                                                %&%
      error( 'Qpack2 requires that Q.ATMOSPHERE_DIM is set to 1.' );        %&%
    end                                                                     %&%
    if ~qarts_isset(Q.USE_RAW_ATMOSPHERE) | ...                             %&%
        qarts_get(Q.USE_RAW_ATMOSPHERE) ~= false                            %&%
      error( 'Qpack2 requires that Q.USE_RAW_ATMOSPHERE == false' );        %&%
    end                                                                     %&%
    if ~isfield(Q.ABS_SPECIES,'ATMDATA')                                    %&%
      error( 'Qpack2 requires that Q.ABS_SPECIES has the field ATMDATA.' ) ;%&%
    end                                                                     %&%
    Q.ABS_SPECIES = qarts_get_gformat( Q.ABS_SPECIES ); 
    for i = 1 : length(Q.ABS_SPECIES)                                       %&%
      rqre_datatype( Q.ABS_SPECIES(i).ATMDATA, @isatmdata, ...              %&%
                                  sprintf('Q.ABS_SPECIES(%d).ATMDATA',i) ); %&%
    end                                                                     %&%
    if ~qarts_isset(Q.T_ATMDATA)                                            %&%
      error( 'Qpack2 requires that Q.T_ATMDATA is set.' );                  %&%
    end                                                                     %&%
    Q.T_ATMDATA = qarts_get_gformat( Q.T_ATMDATA ); 
    rqre_datatype( Q.T_ATMDATA, @isatmdata, Q.T_ATMDATA );                  %&%
    if ~qarts_isset(Q.ABSORPTION)                                           %&%
      error( 'Qpack2 requires that Q.ABSORPTION is set.' );                 %&%
    end                                                                     %&%
    rqre_datatype( Q.ABSORPTION, @ischar, Q.ABSORPTION );                   %&%
    if ~qarts_isset(Q.R_GEOID)                                              %&%
      error( 'Qpack2 requires that Q.R_GEOID is set.' );                    %&%
    end                                                                     %&%
    Q.R_GEOID = qarts_get( Q.R_GEOID ); 
    rqre_datatype( Q.R_GEOID, @istensor0, Q.R_GEOID );                      %&%
  
    if nargout < 2
      Q.J_DO = 0;
    else
      Q.J_DO = 1;
      if ~qarts_isset(Q.TNOISE_C)                                           %&%
        error( 'Qpack2 requires that Q.TNOISE_C is set.' );                 %&%
      end                                                                   %&%
      Q.TNOISE_C = qarts_get( Q.TNOISE_C ); 
      if ~issparse(Q.TNOISE_C)                                              %&%
        error( 'Q.TNOISE_C is required to be sparse (to save memory).' );   %&%
      elseif dimens(Q.TNOISE_C)~=2 | size(Q.TNOISE_C,1)~=size(Q.TNOISE_C,2) %&%
        error( 'Q.TNOISE_C must be square.' );                              %&%
      elseif size(Q.TNOISE_C,1) ~= length(Y(m).Y)                           %&%
        error( 'Mismatch in size between Q.TNOISE_C and Y.Y.' );            %&%
      end                                                                   %&%
    end % nargout < 2
  end % if m==1

  
  % Checks of Y(m)                                                          %&%
  %                                                                         %&%
  rqre_datatype( Y(m).LATITUDE, @istensor0, sprintf('Y(%d).LATITUDE',m) );  %&%
  rqre_datatype( Y(m).LONGITUDE, @istensor0, sprintf('Y(%d).LONGITUDE',m) );%&%
  rqre_datatype( Y(m).HSE_P, @istensor0, sprintf('Y(%d).HSE_P',m) );        %&%
  rqre_datatype( Y(m).HSE_Z, @istensor0, sprintf('Y(%d).HSE_Z',m) );        %&%
  rqre_datatype( Y(m).YEAR, @istensor0, sprintf('Y(%d).YEAR',m) );          %&%
  rqre_datatype( Y(m).MONTH, @istensor0, sprintf('Y(%d).MONTH',m) );        %&%
  rqre_datatype( Y(m).DAY, @istensor0, sprintf('Y(%d).DAY',m) );            %&%
  rqre_datatype( Y(m).Z_PLATFORM, @istensor0, ...                           %&%
                                           sprintf('Y(%d).Z_PLATFORM',m) ); %&%
  rqre_datatype( Y(m).ZA, @istensor0, sprintf('Y(%d).ZA',m) );              %&%


  %- Map ATMDATA to VMR_FIELD and T_FIELD
  %
  Q.LAT_GRID  = Y(m).LATITUDE;
  Q.LON_GRID  = Y(m).LONGITUDE;
  %
  if qarts_isset( Y(m).HOUR )
    rqre_datatype( Y(m).HOUR, @istensor0, sprintf('Y(%d).HOUR',m) );        %&%
    ho = Y(m).HOUR;
  else
    ho = 12;
  end
  if qarts_isset( Y(m).MINUTE )
    rqre_datatype( Y(m).MINUTE, @istensor0, sprintf('Y(%d).MINUTE',m) );    %&%
    mi = Y(m).MINUTE;
  else
    mi = 0;
  end
  if qarts_isset( Y(m).SECOND )
    rqre_datatype( Y(m).SECOND, @istensor0, sprintf('Y(%d).SECOND',m) );    %&%
    se = Y(m).SECOND;
  else
    se = 0;
  end
  %
  mjd = date2mjd( Y(m).YEAR, Y(m).MONTH, Y(m).DAY, ho, mi, se );;
  %
  Q.VMR_FIELD = qarts_vmr_field( Q, mjd, ho );
  Q.T_FIELD   = qarts_t_or_z_field( Q, 't', mjd, ho );
  Q.Z_FIELD   = qarts_hse( Q, Y(m).HSE_P, Y(m).HSE_Z );

  
  %- Prepare absorption table, if ABSORPTION = 'CalcTable'
  %
  if strcmp( Q.ABSORPTION, 'CalcTable' )
    Q = qarts_abstable( Q );
  end
  
  
  %- Sensor pos and los
  %
  r = qarts_get( Q.R_GEOID ); 
  %
  Q.SENSOR_POS = r + Y(m).Z_PLATFORM;
  Q.SENSOR_LOS = Y(m).ZA;

  
  %- Se
  %
  if nargout == 2
    rqre_datatype( Y(m).TNOISE, @istensor1, sprintf('Y(%d).TNOISE',m) );   %&%
    n  = length( Y(m).TNOISE );
    if n ~= 1 & n ~= length( Y(m).Y )                                      %&%
      error( sprintf( ...                                                  %&%
      'Length of Y(%d).TNOISE must be 1 or equal to length of Y.Y.',m)  ); %&%
    end                                                                    %&%
    
    if n == 1
      Se = (Y(m).TNOISE^2) .* Q.TNOISE_C;
    else
      % Avoid to generate full matrix that is n x n:
      [i,j,s] = find( Q.TNOISE_C );
      for k = 1 : length(i)
        s(k) = prod( tnoise_si([i(k) j(k)]) ) * s(k);
      end
      Se = sparse(i,j,s);
    end
  end 
return

