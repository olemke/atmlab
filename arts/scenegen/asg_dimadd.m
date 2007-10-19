function G = asg_dimadd( D, G, Q )
  

%- Basic checks of input
%
qcheck( @asgD, D );
qcheck( @asgG, G );
qcheck( @qarts, Q );
%
rqre_scalar( 'Q.ATMOSPHERE_DIM', Q.ATMOSPHERE_DIM, 1, 3 );



%- New grids for p, lat and lon . To be used with 'expand' option.
%
expandg = { [1.1e5 1e-9], [-90 90], [0 360] };


for ig = 1 : length(G)

  %- Do nothing if DATA field is empty.
  %
  if isempty( G(ig).DATA )
    continue;
  end
  
  %- Determine new dimensions
  %
  % Scalar input accepted for variables of type atmospheric fields
  %
  maxdim  = G(ig).DIMS( find(G(ig).DIMS <= Q.ATMOSPHERE_DIM) );
  if isempty(maxdim)
    maxdim = 0;
  end
  newdims = maxdim+1 : Q.ATMOSPHERE_DIM;
  
  %- Already at Q.ATMOSPHERE_DIM?
  %
  if isempty( newdims )
    continue;
  end
  
  if ~isfield( G(ig).DIMADD, 'METHOD' )
    error( sprintf('No field ''METHOD in G(%d).DIMADD.', ig ) );
  end

  switch lower( G(ig).DIMADD.METHOD )
  
   %--- Simple expansion ---------------------------------------------------
   case 'expand'
    %
    G(ig) = gf_increase_dim( D, G(ig), newdims, {expandg{newdims}} );
    
   otherwise
     error( sprintf( 'No recognised choice for G(%d).DIMADD.METHOD.', ig ) );
  end
end

  
