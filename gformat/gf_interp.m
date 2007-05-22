% GF_INTERP   Interpolation of data in G format.
%
%    Basically an interface between the G format and interp1/2/3. That is,
%    only data dimensions <= 3 are handled. Interpolation positions are
%    given as row vectors with length equal to data
%    dimensionality. Multiple points are given as rows in *pos*.
%
% FORMAT   X = gf_interp( G, pos [, iopt] )
%        
% OUT   X      Interpolated data. Returned as a matrix, where each column 
%              corresponds to an item of G.
% IN    G      Data to be interpolated.
%       pos    Interpolation points, where first column corresponds to
%              dimension 1 etc.
% OPT   iopt   Interpolation option ('linear', 'cubic' etc.)

% 2007-05-21   Created by Patrick Eriksson.


function X = gf_interp( G, pos, iopt )

if nargin < 3
  iopt = 'linear';
end


X = zeros( max([1 size(pos,1)]), length(G) );


for i = 1 : length( G )

  if ( G(i).dim  > 1  &  G(i).dim ~= size(pos,2) ) | ...
     ( G(i).dim == 0  &  ~isempty(pos) )
    error( sprintf( 'Different dimension of *pos* and G(%d).', i ) );
  end
  
  if G(i).dim == 0
    %
    X = G(i).data;
    return
    
  elseif G(i).dim == 1
    %
    X(:,i) = interpd( pos, G(i).data, G(i).grid1, iopt );

  elseif G(i).dim == 2
    %
    X(:,i) = interpd( pos, G(i).data, G(i).grid1, G(i).grid2, iopt );

  elseif G(i).dim == 3
    %
    X(:,i) = interpd( pos, G(i).data, G(i).grid1, G(i).grid2, G(i).grid3, iopt);

  else
    error( 'The function handles only 1D - 3D cases.' );
  end
end
