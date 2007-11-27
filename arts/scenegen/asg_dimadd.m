% ASG_DIMADD   Extrapolates ASG data to match Q.ATMOSPHERE_DIM
%
%    The function ensures that atmospheric fields are defined for 
%    dimensions 1:Q.ATMOSPHERE_DIM and surface for 2:Q.ATMOSPHERE_DIM.
%    Nothing is done if the DATA field is empty. 
%
%    The data are extended following settings in G.DIMADD. The extrapolation
%    method is selected by the field METHOD. The following options exist:
%
%    FORMAT = 'expand'
%    -----------------
%    The data are simply expanded to fill missing higher dimensions. For 
%    example, a 1D pressure profile is expanded to 2D by inserting the
%    profile at each Q.LAT_GRID position.
%   
%    FORMAT = 'expand_weighting'
%    reguires the fields
%    G.DIMADD.weight    which is a weighting vector with the same length
%    as the corresponding missing data in Q.(P,LAT,LON)_GRID
%    -----------------        
%    
%    FORMAT = 'iafft'
%    the data are expanded in longitude dimension  by an Iterative
%    Amplitude Adapted Fourier Transform algorithm   
%
%    The data are expanded to fill missing higher dimensions. For
%    example 2D pressure and latitude dependent data are
%    expanded to longitudinal dependency by applying the weights
%    in G.DIMADD.weight. So G.DATA(p1,lat1,lon1)=  
%    G.DATA(p1,lat1)*G.DIMADD.weight(1) 
%
% FORMAT   G = asg_regrid( D, G, Q )
%        
% OUT   G   Extrapolated ASG data.
% IN    D   Gformat definition structure.
%       G   ASG data.
%       Q   Qarts setting structure.

% 2007-10-19   Created by Patrick Eriksson

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
expandg = { [1.1e5 1e-9], [-90 90], [-180 180] };


for ig = 1 : length(G)

  %- Do nothing if DATA field is empty.
  %
  if isempty( G(ig).DATA )
    continue;
  end
  
  %- Determine new dimensions
  %
  maxdim  = max( G(ig).DIMS( find(G(ig).DIMS <= Q.ATMOSPHERE_DIM) ) );
  %
  if isempty(maxdim)
    if G(ig).SURFACE
      maxdim = 1;
    else
      maxdim = 0;
    end
  end
  %
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

   case 'expand_weighting'
    %
    if length(newdims)==1 
       if newdims~=3 
          error('only longitudinal dependency can be added with this option')
       end
    else
      error('only longitudinal dependency can be added with this option')
    end
    if length(Q.LON_GRID)~=length(G(ig).DIMADD.weights)
      error('mismatch in size between Q.LON_GRID and G.DIMADD.weights')
    end
    G(ig) = gf_increase_dim( D, G(ig), newdims, {Q.LON_GRID} );
    data=G(ig).DATA;
    if isvector(data)
       for jg=1:length(Q.LON_GRID)
           data(:,jg)=data(:,jg)*G(ig).DIMADD.weights(jg);
       end       
    else
       for jg=1:length(Q.LON_GRID)
           data(:,:,jg)=data(:,:,jg)*G(ig).DIMADD.weights(jg);
       end
    end 
    G(ig).DATA=data;
   case 'iafft' 
    if length(newdims)==1 
      if newdims~=3 
          error('only longitudinal dependency can be added with this option')
      end
    else
      error('only longitudinal dependency can be added with this option')
    end  
    G(ig) = asg_2d23d( D, G(ig), Q );   

   otherwise
     error( sprintf( 'No recognised choice for G(%d).DIMADD.METHOD.', ig ) );
  end
end

  
