% ARTS_SX   Creation of Sx matrix based on Qarts/ARTS data
%
%    This is a standardised function to set up Sx. In short, *arts_covmat*
%    is called for each retreival quantity. That is, the function handles
%    only covariances inside each quantity. The result will be a (sparse)
%    matrix with non-zero elements in blocks around the diagonal.
%
%    The covariances are defined by the structure SX. Each field is a single
%    or an aray of structures that can be passed to *arts_covmat*. Each such
%    structure is here denoted as D. Note that indexing in D-arrays must be
%    done as {i}, as the fields can differ between quantities. 
%    These fields are recognised:
%       ABS_SPECIES : An array of D's. The indexing must match Q.ABS_SPECIES,
%                     and thus J.ABS_SPECIES. 
%
% FORMAT   Sx = arts_sx( Q, R, SX )
%        
% OUT   Sx   Covariance matrix (sparse).
% IN    Q     Qarts structure. See *qarts*.
%       R     Retrieval data structure. See *arts_oem*.
%       SX    Defintion of covariances. See above.

% 2006-09-07   Created by Patrick Eriksson.


function Sx = arts_sx( Q, R, SX )



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