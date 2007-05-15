% GF_GRID_CONVERT   Conversion of grid unit
%
%    This function allows a change of grid unit. The grid can be reversed
%    and a log-transformation can be performed.
%
% FORMAT   G = gf_grid_convert( G, dim, rev [, do_log] )
%        
% OUT   G        Data with converted grid.
% IN    G        Original data.
%       dim      Data dimension for which grid shall be converted.
%       rev      Flag to reverse order of grid.
% OPT   do_log   Flag to make log10 conversion. For values > 0, log10 is
%                applied. For values < 0, a back-transformation is done. 

% 2007-05-15   Created by Patrick Eriksson.


function G = gf_grid_convert( G, dim, rev, do_log )

if nargin < 3
  do_log = 0;  
end

%- Handle orinary vectors
%
vecopt = 0;
%
if isvector(G)  & isnumeric(G)
  vecopt  = 1;
  dim     = 1;
  g       = G;
  G       = [];
  G.grid1 = g;
  G.dim   = 1;
end

gridname = sprintf('grid%d',dim);
  
for i = 1 : length( G )

  if G(i).dim < dim
        error( sprintf( 'Selected dimension too high for G(%d).', i ) );
  end

  g = G(i).(gridname);
  
  if rev
    g = g(end:-1:1);
  end
  
  if do_log > 0
    g = log10(g);
  elseif do_log < 0
    g = 10.^(g);
  end

  G(i).(gridname) = g;
  
end


if vecopt
  g = G.grid1;
  G = [];
  G = g;
end