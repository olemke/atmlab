function [y,J] = arts_oem( Q, R, x, iter, do_j )


%- Set default values
%
do_j_DEFAULT = 0;
%
set_defaults;



% Checks done *arts_oem_init* are not repeated here
%
if nargout < 2
  do_j = 0;
end




%--- Map x to variables -------------------------------------------------------
if iter > 1

  %- General variables
  %
  nq    = length( R.jq );                   % Number of retrieval quantities.
  %
  i_asj = find( [ Q.J.ABS_SPECIES.DO ] );   % Index of retrieval absorption
  %                                           species.
  i_rel = [];                               % Index for x-values retrieved in
  %                                           relative units.

  %- Loop retrieval quantities
  %
  for i = 1 : nq

    ind = R.ji{i}{1} : R.ji{i}{2};

    switch R.jq{i}.maintag

    case 'Abs. species'   %---------------------------------------------------
      %
      ig  = i_asj(i);    % Gas species index
      D   = [];
      %
      if strcmp( R.jq{i}.mode, 'rel' )
        [D.P_GRID,D.LAT_GRID,D.LON_GRID,X] = x2field( Q.ATMOSPHERE_DIM, ...
            Q.J.ABS_SPECIES(ig).GRID1, Q.J.ABS_SPECIES(ig).GRID2, ...
            Q.J.ABS_SPECIES(ig).GRID3, x(ind) .* R.vmr0(ind), ...
                                            Q.P_GRID, Q.LAT_GRID, Q.LON_GRID );
        i_rel = [ i_rel ind ];
      elseif strcmp( R.jq{i}.mode, 'vmr' )
        [D.P_GRID,D.LAT_GRID,D.LON_GRID,X] = x2field( Q.ATMOSPHERE_DIM, ...
            Q.J.ABS_SPECIES(ig).GRID1, Q.J.ABS_SPECIES(ig).GRID2, ...
            Q.J.ABS_SPECIES(ig).GRID3, x(ind), ...
                                            Q.P_GRID, Q.LAT_GRID, Q.LON_GRID );
      else
        [D.P_GRID,D.LAT_GRID,D.LON_GRID,X] = x2field( Q.ATMOSPHERE_DIM, ...
           Q.J.ABS_SPECIES(ig).GRID1, Q.J.ABS_SPECIES(ig).GRID2, ...
           Q.J.ABS_SPECIES(ig).GRID3, nd2vmr(x(ind),R.p(ind),R.t(ind)),...
                                            Q.P_GRID, Q.LAT_GRID, Q.LON_GRID );
      end
      %
      Q.VMR_FIELD(ig,:,:,:) = arts_atminterp( Q.ATMOSPHERE_DIM, D, X, Q );
      %
    end
  end
end
%------------------------------------------------------------------------------



%--- Run ARTS -----------------------------------------------------------------

if ~do_j
  y = arts_y( Q );
else
  [y,dy,J] = arts_y( Q );
end

%------------------------------------------------------------------------------



%--- Post-processing ----------------------------------------------------------

%- Rescaling of jacobians in relative units
%
if do_j  &  iter > 1  &  ~isempty( i_rel )
  J(:,i_rel) =  J(:,i_rel) ./ repmat( x(i_rel)', size(J,1), 1 );
end

%------------------------------------------------------------------------------

return





%--- Internal sub-functions ---------------------------------------------------

function [rgrid1,rgrid2,rgrid3,x] = ...
                 x2field( dim, rgrid1, rgrid2, rgrid3, x, grid1, grid2, grid3 )
  %
  if dim == 1
    %
    [rgrid1,f1,l1] = expand_grid( rgrid1, grid1 );
    %
    if ~isempty(f1)  |  ~isempty(l1)
      x = [ x(f1); vec2col(x); x(l1) ];   % x as row vector accepted !
    end 
    %
  elseif dim == 2
    %
    x = reshape( x, length(rgrid1), length(rgrid2) );
    %
    [rgrid1,f1,l1] = expand_grid( rgrid1, grid1 );
    [rgrid2,f2,l2] = expand_grid( rgrid2, grid2 );
    %
    if ~isempty(f1)  |  ~isempty(l1)  |  ~isempty(f2)  |  ~isempty(l2)
      x = [ x(f1,f2) x(f1,:) x(f1,l2); 
            x(:,f2)  x       x(:,l2); 
            x(l1,f2) x(l1,:) x(l1,l2) ];
    end 
  end
return


%------------------------------------------------------------------------------

function [rgrid,f,l] = expand_grid( rgrid, grid )
  %
  % *rgrid* is expanded to cover range of *grid*. The output arguments
  % *f* and *l* can be used to expand the data to be interpolated following
  % the usage at the end of this function.
  %
  n1 = length( grid );
  n2 = length( rgrid );
  %
  % Increasing vector
  if grid(2) > grid(1)
    if grid(1) < rgrid(1)
      f = 1;
    else
      f = [];
    end 
    if grid(n1) > rgrid(n2)
      ll = n1; l = n2;
    else
      ll = []; l = [];
    end 
  % Decreasing vector
  else
    if grid(1) > rgrid(1)
      f = 1;
    else
      f = [];
    end 
    if grid(n1) < rgrid(n2)
      ll = n1; l = n2;
    else
      ll = []; l = [];
    end 
  end
  %
  if ~isempty(f)  |  ~isempty(l)
    rgrid = [ grid(f); vec2col(rgrid); grid(ll) ];
  end
  %
return