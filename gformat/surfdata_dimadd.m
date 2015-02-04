% SURFDATA_DIMADD expands dimensionality of atmdata
%
%   The function adds dimensions to data having
%   the surfdata structure, by a simple expansion 
%   of the data.
%   0-Dimension (0-D) data can be expanded to
%   1-D, 2-D data.
%   1-D data can be expanded to 2-D. 
%
%   FORMAT [Gout]=surfdata_dimadd(G,grids)
%
%   IN    G       an surfdata structure
%         grids   a cell array of the new grids
%         to be used for the expansion. 
%         grids{1} is assumed to be the first
%         dimension to be added. 
%
%   OUT   Gout an surfdata structure with
%         new data dimensionallity.
%
%   Example usage:
%   Here is an example how to expand 0-D data
%   to 2-D:
%   G0D = surfdata_scalar( 0 ); %0-D data
%   G0D.NAME = 'Surface altitude';
%   G0D.DATA_NAME='Surface altitude';
%   G0D.DATA_UNIT='m';
%   lat_grid = vec2col([-4:0.5:4]);
%   lon_grid = vec2col([23:0.5:27]);
%   grids = {lat_grid, lon_grid};
%   [G2D]=atmdata_dimadd(G0D,grids); 

function [Gout]=atmdata_dimadd(G,grids)

strictAssert = atmlab('STRICT_ASSERT');

if strictAssert; 
  rqre_datatype( G, @issurfdata );
  if ~iscell(grids);
    error('grids must be a cell array.')
  end
  if length(grids)>3;
    error('length of grids must be less than 4.')
  end
  for i=1:length(grids);
    if ~isvector(grids{i});
      error('the elements of grids should be a vector.')
    end
  end 
  if G.DIM>2;
    error('This function does not handle G.DIM>2.')
  end
end

newdim = G.DIM + length(grids);

Gout = surfdata_empty(newdim);
Gout.NAME = G.NAME;
Gout.DATA_NAME = G.DATA_NAME;
Gout.DATA_UNIT = G.DATA_UNIT;
Gout.SOURCE = G.SOURCE; 
if newdim==3;
  Gout.GRID3_NAME='MJD';
  Gout.GRID3_UNIT='mjd';
end

%write new grids to Gnew 
mapdata=[];
for i=1:G.DIM;
   Gout.(sprintf('GRID%d',i))=vec2col(G.(sprintf('GRID%d',i)));
   mapdata(i)=length(Gout.(sprintf('GRID%d',i)));
end
for i=1:length(grids)
  Gout.(sprintf('GRID%d',G.DIM+i))=vec2col(grids{i});
  mapdata(G.DIM+i)=length(grids{i});
end


if G.DIM==1;
  mapdata(1)=1;
end
if G.DIM==2;
  mapdata(1)=1;
  mapdata(2)=1;
end
mapdata(end+1)=1;

Gout.DATA=repmat(G.DATA,mapdata);


