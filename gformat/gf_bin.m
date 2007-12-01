% GF_BIN   bin data on gformat
%
%          Bin data in G. The binning is performed in
%          one dimension. If binning in more than one 
%          dimension is desired the binning is performed
%          in order of how the grids are in GRIDS. 
%
% FORMAT   G=gf_bin( D, G, GRIDS , DIMS)
% 
% IN       D        G format definition structure 
%          G        original gformat data             
%          GRIDS    cell array with grids
%          DIMS     vector with dimensions corresonding
%                   to GRIDS and D. DIMS(1) corresponds
%                   to GRIDS{1}. If DIMS(1)=1 the
%                   dimension is as defined in D.GRID1 
%      
% example usage:
% z_grid=[0:1e3:20e3];lat_grid=[0:0.05:5];
% grids{1}=z_grid;grids{2}=lat_grid;
% dims(1)=1;dims(2)=2;
% G=gf_bin(D,G,grids,dims); 
%  
% 2007-11-05 created by Bengt Rydberg
%
   
function [G,D]=gf_bin(D,G,grids,dims)
   
if length(grids)~= length(dims)
   error('Mismatch in size between grids and dims')
end

if length(grids)>D.DIM
   error( 'You have more grids in GRIDS than D.DIM.' );
end

if max(dims)>D.DIM
   error( 'The dimension in dims is outside the range of D.' );
end
 
for i=1:length(grids)
    grids{i}=vec2col(grids{i});
    if ~isvector(grids{i})
       error('the elements in GRIDS must be a vector')
    end
end

for j=1:length(G)
    for ig=1:length(grids)
        gname = sprintf( 'GRID%d', dims(ig) );
        old_grids{ig}=vec2col([G(j).(gname)]);
        if ~isempty(old_grids{ig}) 
          if grids{ig}(1)<old_grids{ig}(1) | grids{ig}(end)>old_grids{ig}(end)
            error('grids is outside the range of original grids')
          end
           %find the dimension of data
	   old_dim=find(G(j).DIMS==dims(ig));
           data=G(j).DATA;
	   funhandle = @(data) binning(grids{ig},old_grids{ig},data);
           data = fun2Dwrapper(data,old_dim,funhandle,'X');
	   G(j).DATA=data;
           G(j).(gname)=grids{ig};
        end
   end
end   



