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
i_asj   = find( [ Q.J.ABS_SPECIES.DO ] );





%--- Loop retrieval quantities and fill xa and R fields ----------------------
%-----------------------------------------------------------------------------

for i = 1 : nq

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag


  case 'Abs. species'   %------------------------------------------------------
    %
    ig      = i_asj(i);    % Gas species index
    %
    Sx(ind,ind) = arts_covmat( Q.ATMOSPHERE_DIM, SX.ABS_SPECIES{ig}, ... 
                                                        R.jq{i}.grids, 'atm' );



  otherwise   %----------------------------------------------------------------
    error('Unknown retrieval characteristics.'); 
  end
end