% SCALARS_VECTORS2SAME_SIZE   Merging of scalars and vector input arguments
%
%   This a help function to handle function input arguments. The idea is to
%   allow that a set of variable combinations shall be specified, but
%   frequently one or several variables are kept constant. That is, it is
%   useful that some of the input arguments can be allowed to be scalars,
%   while the other input arguments are vectors. But which variables that are
%   scalars and vectors can change. For simplicity, it is demanded that
%   vectors are given just as column ones (tensor1).
%
%   Practically, the input arguments must either be a scalar or tensor1.
%   Several arguments can be tensor1, but they must then all have the same
%   length. The scalars are expanded to tensor1, with all elements the same.
%   That is, after the function all the varaibles will have the same size,
%   and all variables will be defined for all combinations.
%
% FORMAT [a,b,c,...] = scalars_vectors2same_size(a,b,c,...)

% 2015-06-11 Patrick Eriksson

function varargout = scalars_vectors2same_size( varargin )

% Check that all input are vectors and find lengths
%
n = length( varargin );
l = zeros( n, 1 );
%
for i = 1 : n 
  if ~istensor1( varargin{i} )
    error( 'Input argument %s is not a scalar or a tensor1.', inputname(i) );
  end
  l(i) = length( varargin{i} );
end

vlength = max(l);

if vlength == 1
  varargout = varargin;
else
  for i = 1 : n 
    if l(i) == vlength
      varargout{i} = varargin{i};
    else
      if l(i) ~= 1
        error( ['Input argument %s is a tensor1, but deviates in length to some ' ...
                'other input tensor1.'], inputname(i) );
      end 
      varargout{i} = repmat( varargin{i}, vlength, 1 );    
    end
  end
end