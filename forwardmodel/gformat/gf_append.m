% GF_APPEND   Appends gformat data to other gformat data
%
%    Appends *Gnew* to *G*. Dimension, grid names and grid units are checked
%    for consistency (empty grid names and units are allowed in *Dnew*).
%
%    The variable *dims* can be used for "dimension mapping". The length of this
%    index vector shall equal Dnew.DIM. All dimension must be <= D.DIM and no
%    dimension cab be repeated. The first element gives the dimension in D/G
%    for the first diemsnion in Dnew/Gnew etc. To append "surfaces"
%    (e.g. z_surface) to a gformat array holding atmospheric fields, do
%    something like:
%       G = gf_append(D,G,Dsurf,Gsurf,[2 3])
%
% FORMAT   G = gf_append(D,G,Dnew,Gnew,dims)
%        
% OUT   G       G with data appended.
% IN    D       Gformat definition structure.
%       G       Gformat data. 
%       D       Gformat definition structure for data to append.
%       G       Gformat data to append.. 
% OPT   dims    Dimension mapping. See above.

% 2008-09-25   Created by Patrick Eriksson.

function G = gf_append(D,G,Dnew,Gnew,dims)
  

%- Default values
%
dims_DEFAULT = 1:Dnew.DIM;
%
set_defaults;

  

%- Check input
%
if min(dims) < 1  ||  length(unique(dims)) ~= length(dims)
  error( 'Negative or repeated dimension in *dims*.' );
end
if length(dims) ~= Dnew.DIM
  error( 'Length of *dims* must be equal to Dnew.DIM.' );
end
if max(dims) > D.DIM
  error( 'Max in *dims* above D.DIM.' );
end
%
gf_check( Dnew, Gnew );
%
for d = 1 : length(dims)
  gnew = sprintf( 'GRID%d_NAME', d );
  if ~isempty( Dnew.(gnew) )
    g = sprintf( 'GRID%d_NAME', dims(d) );
    if ~strcmp( Dnew.(gnew), D.(g) )
      s = sprintf('Different data type for dimension %d (in D)!\n',dims(d));
      s = sprintf('%s  D    : %s\n', s, D.(g) );
      s = sprintf('%s  Dnew : %s', s, Dnew.(gnew) );
      error( s );
    end
  end
  gnew = sprintf( 'GRID%d_UNIT', d );
  if ~isempty( Dnew.(gnew) )
    g = sprintf( 'GRID%d_UNIT', dims(d) );
    if ~strcmp( Dnew.(gnew), D.(g) )
      s = sprintf('Different data unit for dimension %d (in D)!\n',dims(d));
      s = sprintf('%s  D    : %s\n', s, D.(g) );
      s = sprintf('%s  Dnew : %s', s, Dnew.(gnew) );
      error( s );
    end
  end
end


i1 = length(G);
%
for i2 = 1 : length(Gnew)
  
  i1 = i1 + 1;
  
  G(i1).NAME      = Gnew(i2).NAME;
  G(i1).DATA_NAME = Gnew(i2).DATA_NAME;
  G(i1).DATA_UNIT = Gnew(i2).DATA_UNIT;
  G(i1).DIMS      = dims;
  G(i1).SOURCE    = Gnew(i2).SOURCE;  

  for d = 1 : dims
    gnew = sprintf( 'GRID%d', d );
    g    = sprintf( 'GRID%d', dims(d) );
    G(i1).(g) = Gnew(i2).(gnew);
  end

  %- Data reshape map
  %
  n = ones( 1, max([2,D.DIM]) );
  %
  for d = 1 : length( dims )
    n(dims(d)) = size( Gnew(i2).DATA, d );
  end

  G(i1).DATA = reshape( Gnew(i2).DATA, n );

end
