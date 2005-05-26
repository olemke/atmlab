function oa = arts_datatypes( ia, datagroup )

if nargin < 2
  datagroup = 'numeric';
end


rqre_char( 'input argument *datagroup*', datagroup );


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
  if strcmp( lower(datagroup), 'numeric' )
    % 
    i  = find( strcmp( numtypes, ia ) );

  elseif strcmp( lower(datagroup), 'index' )
    % 
    i  = find( strcmp( inttypes, ia ) );

  else
     error( sprintf('Unknown datagroup (%s)',datagroup) );
  end

  if isempty(i)
    error( sprintf('The type %s was not found.', ia ) );
  end

  oa = i - 1;

elseif isinteger(ia) & isscalar(ia)
  oa = 1;

else
  error( 'Unknown type of *ia*.' );

end