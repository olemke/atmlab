% DIMENS  Number of dimensions.
%
%    As *ndims* but returns 1 for a column vector.
%
% FORMAT   n = dimens(A)
%        
% OUT   n   Dimensionality.
% IN    A   Data (no type check is performed).

% 2006-08-2   Created by Patrick Eriksson.


function n = dimens(A)

n = max([ 1 max( find( size(A) > 1 ) )] );