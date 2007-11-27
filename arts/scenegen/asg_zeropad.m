% ASG_ZEROPAD  Add zeros in ASG data so that the fields
%              are defined everywhere
%
%              zeros are added at the edges
%              (as example lat=-90 and lat=90)
%              and just outside the defined
%              region of the original G data,
%              where the grids will be defined
%              by values of DX.
%
% FORMAT   G = asg_zeropad( D, G, Q ,DX )
%        
% OUT   G   Extrapolated ASG data.
% IN    D   Gformat definition structure.
%       G   ASG data.
%       Q   Qarts setting structure.
% Opt.  DX  vector. 
%           DX(1) corresponds pressure.
%           DX(2) to latitude.
%           DX(3) to longitude.
%           default is [1 0.01 0.01]
%           As example G.GRID1+DX(1) will
%           be a new grid point where the data
%           will be set to zeros.
%
% 2007-11-13   Created by Bengt Rydberg

function G=asg_zeropad(D,G,Q,DX)

DX_DEFAULT  = [1 0.01 0.01];
set_defaults;


%- Basic checks of input
%
qcheck( @asgD, D );
qcheck( @asgG, G );
qcheck( @qarts, Q );
%
rqre_scalar( 'Q.ATMOSPHERE_DIM', Q.ATMOSPHERE_DIM, 1, 3 );

%- New grids for p, lat and lon .
%
expandg = { [1.1e5 1e-9], [-90 90], [-180 180] };


for ig = 1 : length(G)

  %- Do nothing if DATA field is empty.
  %
  if isempty( G(ig).DATA )
    continue;
  end
  for i=1:length(G(ig).DIMS)
      dim=G(ig).DIMS(i);
      gname = sprintf( 'GRID%d', dim );
      dname = sprintf( 'GRID%d_NAME', dim );
      grid=G(ig).(gname);
      if strcmp(D.(dname),'Pressure') 
	grid_add=[grid(1)+DX(dim) grid(end)-DX(dim)];
      else
        grid_add=[grid(1)-DX(dim) grid(end)+DX(dim)];
      end    
      grid=sort([vec2col(grid)' grid_add expandg{dim}])';
      if strcmp(D.(dname),'Pressure')
	 grid=flipud(grid);
      end
      G(ig).(gname)=grid;

      %add the zeros
      if isvector(G(ig).DATA)
	 G(ig).DATA=vec2col(G(ig).DATA);
      end
      data_size=size(G(ig).DATA);
      ind=find(G(ig).DIMS==dim);
      data_size(ind)= data_size(ind)+4;
      data=zeros(data_size);    
      %shift dimensions  
      data_dim=dimens(data);     
      old_data=shiftdim(G(ig).DATA,ind-1);
      data=shiftdim(data,ind-1);    
      data(3:end-2,:,:)=old_data;
      %shift back dimensions
      G(ig).DATA=shiftdim(data,data_dim-ind+1);
   end
end 
