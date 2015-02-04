% SURFDATA_SCALAR   Creates a surfdata structure with a scalar value
%
%   This function can be used for either when the surfdata is a true scalar,
%   or if the field is constant in all dimensions.
%
%   surfdata_scalar( 0 ) generates
%           TYPE: 'surfdata'
%           NAME: []
%         SOURCE: []
%            DIM: 0
%           DATA: 0
%      DATA_NAME: []
%      DATA_UNIT: []
%
% FORMAT   G = surfdata_scalar( value )
%        
% OUT   G      Created atmlab structure.
% OPT   value  A scalar value.

% 2014-08-26   Created by Bengt Rydberg.

function G = atmdata_scalar( value )

if atmlab('STRICT_ASSERT'), 
  rqre_datatype( value, @istensor0 );
end
  
G = surfdata_empty( 0 );

G.DATA = value;
