% GF_REGRID   Change of rectangular grid for gformat data
%
%    Largely an interface to *regrid*, but with some extra functionality to
%    handle cases where DIMS deviates from 1:n. For example, to regrid a
%    "surface" spanning dimensions 2 and 3, in a case where D.DIM=3:
%       G = gf_regrid( D, G, {newgrid2,newgrid3}, 2:3 );
%
%    Regridding for dimensions above 3D is done by repeated 3D regridding.
%    The looping is then performed for the highest dimensions involved.    
%
% FORMAT   G = gf_regrid( D, G, grids, dims, iopt )
%        
% OUT   G      Re-grided gformat data.
% IN    D      Gformat definition structure
%       G      Original gformat data.
% OPT   dims   Dimensions for which regridding shall be done. That is, the
%              dimension corresponding to each vector in *grids*. Default is 
%              to assign data to the n first data dimensions, where n is
%              the dimensionality of *grids*.   
%       iopt   Interpolation option. See *regrid*.

% 2007-10-17   Created by Patrick Eriksson.


function G = gf_regrid( D, G, grids, dims, iopt )

  
%- Default values
%
if nargin < 4
  dims = [];
end
if nargin < 5
  iopt = 'linear';
end


%- Some input checks
%
rqre_datatype( 'struct', D );
rqre_datatype( 'struct', G );
rqre_field( D, 'DIM', 0 );
rqre_field( G, 'DIMS', 0 );
rqre_datatype( {'vector','cell'}, grids );
%
rqre_datatype( 'char', iopt );


%- Handle different input versions and furter inout checks
%
if ~isempty(grids)  &  isnumeric( grids )
  grids = { grids };
end
%
if isempty(dims) 
  dims = 1 : length(grids);
end
%
if max(dims) > D.DIM
  error( 'You have selected a dimension (in *dims*) above D.DIM.' );
end
%
if ~isnumeric(dims) | ~isvector(dims)  |  any( iswhole(dims) ~= 1 )  | ...
   ~issorted(dims)
  error( 'Input *dims* must be a sorted numeric vector of integers.' );
end
%
if length(dims) ~= length(grids)
  error( 'Difference in length between *dims* and *grids*.' );
end


dim = length( dims );

for id = 1 : length(dims)
  gnames{id} = sprintf( 'GRID%d', dims(id) );
end


for ig = 1 : length( G )

  %- Possible to regrid
  %
  if isempty(G(ig).DIMS) 
    error( sprintf( ['G(%d) is either empty or a scalar, and can not be ',...
                     'regridded.'], ig ) ); 
  elseif length(intersect(G(ig).DIMS,dims)) ~= length(dims)
    error( sprintf( '*dims* includes some dimension not found in G(%d).',...
                                                                       ig ) );
  end
  
  %- Determine final size
  %
  n = ones( 1, max([2 D.DIM]) ); % reshape demands at least 2 values
  %
  for id = 1 : dim
    n(dims(id)) = length( grids{id} );
  end
  
  A     = getdims( G(ig).DATA, dims );

  if dim == 1
    %
    B                 = regrid( A, G(ig).(gnames{1}), grids{1}, iopt );
    G(ig).(gnames{1}) = grids{1};

  elseif dim == 2
    %
    B                 = regrid( A, G(ig).(gnames{1}), grids{1}, ...
                                   G(ig).(gnames{2}), grids{2}, iopt );
    G(ig).(gnames{1}) = grids{1};
    G(ig).(gnames{2}) = grids{2};
  
  elseif dim == 3
    %
    B                 = regrid( A, G(ig).(gnames{1}), grids{1}, ...
                                   G(ig).(gnames{2}), grids{2}, ...
                                   G(ig).(gnames{3}), grids{3}, iopt );
    G(ig).(gnames{1}) = grids{1};
    G(ig).(gnames{2}) = grids{2};
    G(ig).(gnames{3}) = grids{3};
  
  elseif dim == 4
    %
    B = zeros( n(dims) );
    %
    for i1 = 1 : n(dims(4))
      B(:,:,:,i1) = regrid( A(:,:,:,i1), G(ig).(gnames{1}), grids{1}, ...
                                   G(ig).(gnames{2}), grids{2}, ...
                                   G(ig).(gnames{3}), grids{3}, iopt );
    end
    G(ig).(gnames{1}) = grids{1};
    G(ig).(gnames{2}) = grids{2};
    G(ig).(gnames{3}) = grids{3};
    G(ig).(gnames{4}) = grids{4};

  elseif dim == 5
    %
    B = zeros( n(dims) );
    %
    for id = 1 : n(dims(4))
      for id = 1 : n(dims(4))
        B(:,:,:,i1,i2) = regrid( A(:,:,:,i1,i2), ...
                                   G(ig).(gnames{1}), grids{1}, ...
                                   G(ig).(gnames{2}), grids{2}, ...
                                   G(ig).(gnames{3}), grids{3}, iopt );
      end
    end
    G(ig).(gnames{1}) = grids{1};
    G(ig).(gnames{2}) = grids{2};
    G(ig).(gnames{3}) = grids{3};
    G(ig).(gnames{4}) = grids{4};
    G(ig).(gnames{5}) = grids{5};
    
  else
    error( ['The function handles so far only 1D - 5D interpolation, ',...
            'but can easily be extended.'] );
  end
  
  G(ig).DATA = reshape( B, n );
end
