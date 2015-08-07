%ASG_REGRID   Regrids data on atmdata or surfdata formats
%
%    asg_regrid regrids atmdata or surfdata on desired grids.
%    asg_regrid wraps around *atmdata_regrid* for atmdata 
%    and *gf_regrid* for surfdata.
%
%    FORMAT  [G]=asg_regrid(G,grids)
%
%    OUT     G  array of atmdata or surfdata structures
%               where data has been regridded on desired 
%               grids. 
%               grids{1} is assumed to be pressure.
%               grids{2} is assumed to be latitude.
%               grids{3} is assumed to be longitude.
%               grids{4} is assumed to be day (mjd).
%
%    IN      G  array of atmdata or surfdata structures
%
%            grids array of grids
%
%  Example usage: 
%  G{1} = atmdata_scalar(0.718);
%  G{2} = atmdata_scalar(0.800);
%  p_grid = vec2col( z2p_simple( [-1e3:1e3:70e3] ) );
%  lat_grid = vec2col( [-10 : 10] );
%  lon_grid = vec2col( [-10 : 10] );
%  grids ={p_grid, lat_grid, lon_grid};
%  [G]=asg_regrid(G,grids)

% 2014-08-24  Created by Bengt Rydberg
function [G]=asg_regrid(G,grids)

for i=1:length(G);
  if isatmdata(G{i});
    if G{i}.DIM<length(grids);
      newgrids={grids{G{i}.DIM+1:end}};
      G{i} = atmdata_dimadd(G{i},newgrids);
    end
    G{i} = atmdata_regrid(G{i}, grids);
  elseif issurfdata(G{i}); 
    surfgrids={grids{2:end}};
    if G{i}.DIM<length(surfgrids);
      newgrids={surfgrids{G{i}.DIM+1:end}};
      G{i} = surfdata_dimadd(G{i},newgrids); 
    end 
    G{i} = gf_regrid(G{i}, surfgrids);
  else
    error(['Element ',i,' is not atmdata or surfata'])
  end
  %check dimensions of data
  datasize=size(G{i}.DATA);
  if isscalar(G{i}.DATA);
    G{i}.DIM = 0;
  elseif (length(datasize)==2 & datasize(end)==1);
    G{i}.DIM = 1;
  else
    G{i}.DIM = length(datasize);
  end
end

