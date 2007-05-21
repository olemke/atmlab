% GF_REGRID   Change of rectangular grid (1D to 3D)
%
%    Just an interface to *regrid* function.
%
% FORMAT   G = gf_regrid( G, Gtmplt [, iopt] )
%        
% OUT   G      Re-grided data.
% IN    G      Original data.
%       Gtmplt New grids are taken from (first element of) this data
%              structure. Data dimension must match G.
% OPT   iopt   Interpolation option. See *regrid*.

% 2007-05-15   Created by Patrick Eriksson.


function X = gf_interp( G, pos, iopt )

if nargin < 3
  iopt = 'linear';
end


X = zeros( max([1 size(pos,1)]), length(G) );


for i = 1 : length( G )

  if G(i).dim ~= size(pos,2)
    error( sprintf( 'Different dimension of *pos* and G(%d).', i ) );
  end
  
  if G(i).dim == 0
    %
    X = G(i).data;
    return
    
  elseif G(i).dim == 1
    %
    X(:,i) = interp1( G(i).grid1, G(i).data, pos, iopt );

  elseif Gtmplt(1).dim == 2
    %
    X(:,i) = interp2( G(i).grid1, G(i).grid2, G(i).data, ...
                                                   pos(:,1), pos(:,2), iopt );

  elseif Gtmplt(1).dim == 3
    %
    X(:,i) = interp3( G(i).grid1, G(i).grid2, G(i).grid3, G(i).data, ...
                                         pos(:,1), pos(:,2), pos(:,3), iopt );
  else
    error( 'The function handles only 1D - 3D cases.' );
  end
end
