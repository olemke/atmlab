% To be written ...


function Q = gf_export_qarts( Q, G )
  

if isfield( G, 'T_FIELD' )
  ok_field( Q, G.T_FIELD, 'G.T_FIELD' );
  Q.T_FIELD = G.T_FIELD.data;
end


if isfield( G, 'ABS_SPECIES' )
  for i = 1 : length(G.ABS_SPECIES)
    %
    Q.ABS_SPECIES{i} = G.ABS_SPECIES(i).name;
    %
    if i == 1
      Q.VMR_FIELD = zeros([length(G.ABS_SPECIES) size(G.ABS_SPECIES(1).data)]);
    end
    %
    ok_field( Q, G.ABS_SPECIES(i), sprintf('G.ABS_SPECIES(%d)',i) );
    Q.VMR_FIELD(i,:,:,:) = G.ABS_SPECIES(i).data;
  end
end








function ok_field( Q, Ge, fieldname )
  if ~issame( Q.P_GRID, Ge.grid1 )
    error( sprintf( 'Difference between Q.P_GRID and grid1 for %s.', ...
                                                             fieldname ) );
  end
  if Q.ATMOSPHERE_DIM >= 2  &  ~issame( Q.LAT_GRID, Ge.grid2 )
    error( sprintf( 'Difference between Q.LAT_GRID and grid2 for %s.', ...
                                                             fieldname ) );
  end
  if Q.ATMOSPHERE_DIM >= 3  &  ~issame( Q.LON_GRID, Ge.grid3 )
    error( sprintf( 'Difference between Q.LON_GRID and grid3 for %s.', ...
                                                             fieldname ) );
  end  
return
  