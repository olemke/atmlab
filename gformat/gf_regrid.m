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


function G = gf_regrid( G, Gtmplt, iopt )

if nargin < 3
  iopt = 'linear';
end


for i = 1 : length( G )

  if Gtmplt(1).dim ~= G(i).dim
    error( sprintf( 'Different dimension of Gtmplt and G(%d).', i ) );
  end
  
  if Gtmplt(1).dim == 1
    %
    G(i).data  = regrid( G(i).data, G(i).grid1, Gtmplt(1).grid1 );
    G(i).grid1 = Gtmplt(1).grid1;

  elseif Gtmplt(1).dim == 2
    %
    G(i).data  = regrid( G(i).data, G(i).grid1, Gtmplt(1).grid1, ...
                                    G(i).grid2, Gtmplt(1).grid2 );
    G(i).grid1 = Gtmplt(1).grid1;
    G(i).grid2 = Gtmplt(1).grid2;
  
  elseif Gtmplt(1).dim == 3
    %
    G(i).data  = regrid( G(i).data, G(i).grid1, Gtmplt(1).grid1, ...
                                    G(i).grid2, Gtmplt(1).grid2 );
    G(i).grid1 = Gtmplt(1).grid1;
    G(i).grid2 = Gtmplt(1).grid2;
    G(i).grid3 = Gtmplt(1).grid3;
  
  else
    error( 'The function handles only 1D - 3D cases.' );
  end
end
