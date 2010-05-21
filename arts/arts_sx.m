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
%.-----------------------------------------------------------------------------

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
   
   case 'Frequency'   %--------------------------------------------------------
    %
    rqre_field( Q.FFIT, 'SX', 'Q.FFIT' );                                   %&%
    rqre_datatype( Q.FFIT.SX, @istensor2, 'Q.FFIT.SX' );                    %&%
    if any( size(Q.FFIT.SX) ~= length(ind) )                                %&%
      error( sprintf('Wrong size of Q.FFIT.SX.') );                         %&%
    end                                                                     %&%
    %
    Sx(ind,ind) = Q.FFIT.SX;

   case 'Polynomial baseline fit'   %------------------------------------------
    %
    c      = sscanf(R.jq{i}.subtag(end+[-1:0]), '%d' );
    sxname = sprintf( 'SX%d', c );
    rqre_field( Q.POLYFIT, sxname, 'Q.POLYFIT' );                           %&%
    rqre_datatype( Q.POLYFIT.(sxname), @istensor2, ...                      %&%
                                          sprintf('Q.POLYFIT.%s',sxname) ); %&%
    if any( size(Q.POLYFIT.(sxname)) ~= length(ind) )                       %&%
      error( sprintf('Wrong size of Q.POLYFIT.%s.',sxname) );               %&%
    end                                                                     %&%
    %
    Sx(ind,ind) = Q.POLYFIT.(sxname);
   
  otherwise   %----------------------------------------------------------------
    error( sprintf('Unknown retrieval quantity (%s).',R.jq{i}.maintag) ); 
  end
end