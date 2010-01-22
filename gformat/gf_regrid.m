% GF_REGRID   Change of rectangular grid for gformat data
%
%    Largely an interface to *regrid*. The dimension and size of new data are
%    determined by the number of grids and their lengths, respectively.
%
%    The function considers the atmlab setting EXTRAP, and it must be set to
%    true or false. If EXTRAP is false, the number of grids in *grids* must
%    be equal to G.DIM (and there is no extrapolation outside the grid in G).
%    With EXTRAP set to true, the data are extrapolated. An extrapolation 
%    to dimensions above G.DIM is then possible (*grids* can contain 
%    more than G.DIM grids).
%
% FORMAT   G = gf_regrid( G, grids, iopt )
%        
% OUT   G      Re-grided gformat data.
% IN    G      Original gformat data.
%       grids  New grids. An array of vectors.
% OPT   iopt   Interpolation option. See *regrid*.

% 2007-10-17   Created by Patrick Eriksson.


function G = gf_regrid( G, grids, iopt )
%
if nargin < 3                                            
  iopt = 'linear';
end
                                                                   %&%
                                                                   %&%
%- Check input                                                     %&%
%                                                                  %&%
rqre_datatype( G, @isgformat );                                    %&%
% Grids of G are checked inside *regrid*                           %&%
rqre_datatype( grids, @iscell );                                   %&%
rqre_datatype( iopt, @ischar );                                    %&%
                                                                   %&%
%--- Extrapolation switch defined?                                 %&%
%                                                                  %&%
atmlab( 'require', {'EXTRAP'} );                                   %&%
                                                                   %&%
                                                                   %&%
extrap = atmlab( 'EXTRAP' );
%                                                                  %&%
rqre_datatype( extrap, @isboolean );                               %&%


for i = 1 : length( G )
  %
  agrids = {};
  %
  for d = 1  : G(i).DIM
    agrids{d} = G(i).(sprintf('GRID%d',d));
  end
  %
  G(i).DATA = regrid( agrids, G(i).DATA, grids, iopt );  
  %
end
