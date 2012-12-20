% ARTS_SX   Creation of Sx matrix based on Qarts/ARTS data
%
%    This is a standardised function to set up Sx. The function simply includes
%    the covariance matrices defined in the SX sub-fields along the diagonal of
%    the complete Sx matrix. That is, the function handles only covariances
%    inside each retrieval quantity. The result will be a (sparse) matrix with
%    non-zero elements in blocks around the diagonal.
%
% FORMAT   Sx = arts_sx( Q, R )
%        
% OUT   Sx   Covariance matrix (sparse).
% IN    Q     Qarts structure. See *qarts*.
%       R     Retrieval data structure. See *arts_oem*.

% 2006-09-07   Created by Patrick Eriksson.


function Sx = arts_sx( Q, R )



%--- Initialization of variables ----------------------------------------------

%- xa
%
nq = length( R.jq );
nx = R.ji{nq}{2};
%
Sx = sparse( nx, nx );
%
i_asj = find( [ Q.ABS_SPECIES.RETRIEVE ] );



%--- Loop retrieval quantities and fill xa and R fields -----------------------
%------------------------------------------------------------------------------

for i = 1 : nq

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag

   case 'Absorption species'   %-----------------------------------------------
    %
    ig = i_asj(i);    % Gas species index
    %                                                                       %&%
    rqre_field( Q.ABS_SPECIES(ig), 'SX', sprintf('Q.ABS_SPECIES(%d)',ig) ); %&%
    rqre_datatype( Q.ABS_SPECIES(ig).SX, @istensor2, ...                    %&%
                                      sprintf('Q.ABS_SPECIES(%d).SX',ig) ); %&%
    if any( size(Q.ABS_SPECIES(ig).SX) ~= length(ind) )                     %&%
      error( sprintf('Wrong size of Q.ABS_SPECIES(%d).SX.',ig) );           %&%
    end                                                                     %&%
    %
    Sx(ind,ind) = Q.ABS_SPECIES(ig).SX;
   
   case 'Atmospheric temperatures'   %-----------------------------------------
    %
    rqre_field( Q.T, 'SX', 'Q.T' );                                         %&%
    rqre_datatype( Q.T.SX, @istensor2, 'Q.T.SX' );                          %&%
    if any( size(Q.T.SX) ~= length(ind) )                                   %&%
      error( sprintf('Wrong size of Q.T.SX.') );                            %&%
    end                                                                     %&%
    %
    Sx(ind,ind) = Q.T.SX;
   
   case 'Sensor pointing'   %--------------------------------------------------
    %
    if ~strcmp( R.jq{i}.subtag, 'Zenith angle off-set' )                    %&%
      error( 'Unknown pointing subtag.' );                                  %&%
    end                                                                     %&%
    rqre_field( Q.POINTING, 'SX', 'Q.POINTING' );                           %&%
    rqre_datatype( Q.POINTING.SX, @istensor2, 'Q.POINTING.SX' );            %&%
    if any( size(Q.POINTING.SX) ~= length(ind) )                            %&%
      error( sprintf('Wrong size of Q.POINTING.SX.') );                     %&%
    end                                                                     %&%
    %
    Sx(ind,ind) = Q.POINTING.SX;
   
   case 'Frequency'   %--------------------------------------------------------
    %
    if strcmp( R.jq{i}.subtag, 'Shift' )
      rqre_field( Q.FSHIFTFIT, 'SX', 'Q.FSHIFTFIT' );                       %&%
      rqre_datatype( Q.FSHIFTFIT.SX, @istensor2, 'Q.FSHIFTFIT.SX' );        %&%
      if any( size(Q.FSHIFTFIT.SX) ~= length(ind) )                         %&%
        error( sprintf('Wrong size of Q.FSHIFTFIT.SX.') );                  %&%
      end                                                                   %&%
      Sx(ind,ind) = Q.FSHIFTFIT.SX;
      %
    elseif strcmp( R.jq{i}.subtag, 'Stretch' )
      rqre_field( Q.FSTRETCHFIT, 'SX', 'Q.FSTRETCHFIT' );                   %&%
      rqre_datatype( Q.FSTRETCHFIT.SX, @istensor2, 'Q.FSTRETCHFIT.SX' );    %&%
      if any( size(Q.FSTRETCHFIT.SX) ~= length(ind) )                       %&%
        error( sprintf('Wrong size of Q.FSTRETCHFIT.SX.') );                %&%
      end                                                                   %&%
      Sx(ind,ind) = Q.FSTRETCHFIT.SX;
      %
    else                                                                    %&%
      error( 'Unknown frequency subtag' );                                  %&%
    end
    
   case 'Polynomial baseline fit'   %------------------------------------------
    %
    c      = sscanf( R.jq{i}.subtag(end+[-1:0]), '%d' );
    sxname = sprintf( 'SX%d', c );
    rqre_field( Q.POLYFIT, sxname, 'Q.POLYFIT' );                           %&%
    rqre_datatype( Q.POLYFIT.(sxname), @istensor2, ...                      %&%
                                          sprintf('Q.POLYFIT.%s',sxname) ); %&%
    if any( size(Q.POLYFIT.(sxname)) ~= length(ind) )                       %&%
      error( sprintf('Wrong size of Q.POLYFIT.%s.',sxname) );               %&%
    end                                                                     %&%
    %
    Sx(ind,ind) = Q.POLYFIT.(sxname);
 
   case 'Sinusoidal baseline fit'   %------------------------------------------
    %
    c      = sscanf( R.jq{i}.subtag(end+[-1:0]), '%d' ) + 1;
    sxname = sprintf( 'SX%d', c );
    rqre_field( Q.SINEFIT, sxname, 'Q.SINEFIT' );                           %&%
    rqre_datatype( Q.SINEFIT.(sxname), @istensor2, ...                      %&%
                                          sprintf('Q.SINEFIT.%s',sxname) ); %&%
    if any( size(Q.SINEFIT.(sxname))*2 ~= length(ind) )                     %&%
      error( sprintf('Wrong size of Q.SINEFIT.%s.',sxname) );               %&%
    end                                                                     %&%
    %
    Sx(ind(1:2:end),ind(1:2:end)) = Q.SINEFIT.(sxname);
    Sx(ind(2:2:end),ind(2:2:end)) = Q.SINEFIT.(sxname);
   
  otherwise   %----------------------------------------------------------------
    error( sprintf('Unknown retrieval quantity (%s).',R.jq{i}.maintag) ); 
  end
end