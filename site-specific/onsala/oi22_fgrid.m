% Creates *f_grid*
%
%   The grid set follows the data in *O*, particularly O.freq
%
% FORMAT G = oi22_channel_response(O)
%
% OUT   G   Channel response as a ArrayOfGriddedField1
% IN    O   Observation data structure

% 2021-02-07 Patrick Eriksson


function f_grid = oi22_fgrid(O)

f0 = 22.23508e9;

% ???
if length(O.freq) == 9001  &  (diff(O.freq(1:2)) - 12.2e3) < 500
  %
  df = 20e3;
  f_grid = grid_for_1line( f0, 40e3, f0-O.freq(1)+25e3, O.freq(end)-f0+1e6, ...
                           5e3, 0.05 )';
  
else
  error( 'O.freq does not match any of the recognised choices.' );
end
