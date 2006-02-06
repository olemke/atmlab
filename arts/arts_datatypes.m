% ARTS_DATATYPES   Mapping between ARTS data types and container dimensionality
%
%    This function can be used to automatically determine the name or
%    dimensionality of an ARTS data type. Three examples:
%       arts_datatypes(3) returns ['Tensor3','num']
%       arts_datatypes('Vector') gives [1,'num']
%       arts_datatypes(1,'int') gives ['ArrayOfIndex','int]
%
%    Handled data type series are listed below. Scalar data types (Numeric
%    and Index) are treated to have dimension 0.
%
% FORMAT   [oa,datagroup] = arts_datatypes( ia [, datagroup] )
%        
% OUT   oa          Output argument. Either name of a ARTS data type or
%                   dimension of wanted data type.
%       datagroup   See corresponding input argument.
% IN    ia          Input argument. Either name of a ARTS data type or
%                   dimension of wanted data type.
% OPT   datagroup   Type of data. Defined choices are:
%                      'num' : Numeric, Vector, Matrix, Tensor3 ... Tensor7
%                      'int' : Index, ArrayOfIndex
%                   Default is 'num'.

% 2005-05-26   Created by Patrick Eriksson.


function [oa,datagroup] = arts_datatypes( ia, datagroup )


numtypes = {
'Numeric' , ...
'Vector' , ...
'Matrix' , ...
'Tensor3' , ...
'Tensor4' , ...
'Tensor5' , ...
'Tensor6' , ...
'Tensor7'
};

inttypes = {
'Index', ...
'ArrayOfIndex'
};



if ischar( ia )
  %
  if nargin > 1
    warning( 'ATMLAB:UnusedArguments', ...
                                'Input argument *datagroup* will be ignored.' )
  end
  %
  i         = find( strcmp( numtypes, ia ) );
  datagroup = 'num';
  %
  if isempty(i)
    i         = find( strcmp( inttypes, ia ) );
    datagroup = 'int';
  end

  if isempty(i)
    error( sprintf('The type %s was not found.', ia ) );
  end

  oa = i - 1;

elseif iswhole(ia) & isscalar(ia)
  %
  if nargin < 2
    datagroup = 'num';
  end
  %
  rqre_char( 'input argument *datagroup*', datagroup );
  %
  if strcmp( lower(datagroup), 'num' )
    % 
    rqre_scalar( 'input argument *ia*', ia, 0, length(numtypes)-1 )
    oa  = numtypes{ia+1};

  elseif strcmp( lower(datagroup), 'int' )
    % 
    rqre_scalar( 'input argument *ia*', ia, 0, length(inttypes)-1 )
    oa  = inttypes{ia+1};

  else
     error( sprintf('Unknown datagroup (%s)',datagroup) );
  end

else
  error( 'Unknown type of *ia*.' );

end