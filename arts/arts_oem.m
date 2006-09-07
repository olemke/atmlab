% ARTS_OEM   Interface between *oem* and the ARTS forward model
%
%    This function together with *arts_oem_init* handles all bookkeeping and
%    communication to perform OEM inversion with ARTS. The standard sequence
%    of function calls is:
%
%       [Qoem,R,xa] = arts_oem_init( Q );
%       Sx          = arts_sx( Q, R, SX );
%       Se          = arts_covmat ...
%       [x,P]       = oem( O, Qoem, R, @arts_oem, Sx, Se, [], [], xa, y );
%       %
%       arts_oem( 'clean', R );
%       clear Qoem
%
%    Note that *arts_oem_init* can modify Q in such way that it can not be
%    used for further calculations. 
%
%    An implementation strategy has been to avoid unnecessery reading and
%    writing of files, in order to obtain high calculation speed. The drawback
%    is that more variables must be kept in memory.
%
%    All pure forward model variables are stored in Q, while all extra data 
%    needed to handle the inversions are put into R. This data can be used
%    for further processing or "re-packing" of inversions results.
%    These fields exist:
%       workfolder: Path to the temporary working folder.
%       jq        : ARTS description of jacobian quantities.
%       ji        : Start and stop index in J for each jacobian quantities.
%       cfile_y   : Name of control file to generate only y
%       cfile_yj  : Name of control to generate y and J
%       x_p       : The pressure corresponding to each element of x. 
%       x_t       : The temperature corresponding to each element of x. 
%       x_vmr0    : The a priori VMR corresponding to each element of x. 
%       ---
%       p_grid    : R can further contain fields corresponding to a number 
%       lat_grid  : of ARTS WSVs. The same information exists in files and
%       lon_grid  : these fields are included to minimize reading of files. 
%       vmr_field : Only some example on these fields are here given.
%       sensor_los:
%       ...
%
% FORMAT   [R,y,J] = arts_oem( Q, R, x, iter )
%        
% OUT   R     Retrieval data structure. See above.
%       y     Calculated measurement vector.
%       J     Jacobian.
% IN    Q     Qarts structure. See *qarts*.
%       R     Retrieval data structure. See above.
%       x     State vector.
%       iter  Iteration number. Iteration number 1 is treated as x = xa
%             can be assumed.

% 2006-09-07   First working version by Patrick Eriksson.


function [R,y,J] = arts_oem( Q, R, x, iter )



%- Handle special case of arts_oem('clean',R) ---------------------------

if ischar(Q)  &  strcmp( Q, 'clean' )
  delete_tmpfolder( R.workfolder );
  return                               % --->
end

%-----------------------------------------------------------------------------




%- Everything is here put into try-catch to enable that work folder is
%- removed if something goes wrong.
%
try


% Checks done *arts_oem_init* are not repeated here


%- Shall jacobians be done ?
%
if nargout == 3
  do_j = 1;
else
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
  any_gas = false;                          % Any gas species among rq

  %- Loop retrieval quantities
  %
  for i = 1 : nq

    ind = R.ji{i}{1} : R.ji{i}{2};

    switch R.jq{i}.maintag

    case 'Abs. species'   %---------------------------------------------------
      %
      any_gas = true;
      ig      = i_asj(i);    % Gas species index
      D       = [];
      %
      if strcmp( R.jq{i}.mode, 'rel' )
        [D.P_GRID,D.LAT_GRID,D.LON_GRID,X] = ...
                                  x2field( Q.ATMOSPHERE_DIM, R.jq{i}.grids, ...
                                      x(ind) .* R.x_vmr0(ind), ...
                                            R.p_grid, R.lat_grid, R.lon_grid );
        i_rel = [ i_rel ind ];
      elseif strcmp( R.jq{i}.mode, 'vmr' )
        [D.P_GRID,D.LAT_GRID,D.LON_GRID,X] = ...
                                  x2field( Q.ATMOSPHERE_DIM, R.jq{i}.grids, ...
                                      x(ind), ...
                                            R.p_grid, R.lat_grid, R.lon_grid );
      else
        [D.P_GRID,D.LAT_GRID,D.LON_GRID,X] = ...
                                  x2field( Q.ATMOSPHERE_DIM, R.jq{i}.grids, ...
                                      nd2vmr(x(ind),R.x_p(ind),R.x_t(ind)),...
                                            R.p_grid, R.lat_grid, R.lon_grid );
      end
      %
      R.vmr_field(ig,:,:,:) = arts_atminterp( Q.ATMOSPHERE_DIM, D, X, Q );
      %
    end
  end


  %- Data to save ?
  %
  if any_gas
    xmlStore( fullfile(R.workfolder,'vmr_field.xml'), R.vmr_field, 'Tensor4' );
  end

end
%------------------------------------------------------------------------------





%--- Run ARTS -----------------------------------------------------------------

if do_j
  cfile = R.cfile_yj;
else
  cfile = R.cfile_y;
end
%
arts( cfile );
%
y     = xmlLoad( fullfile( R.workfolder, 'y.xml' ) );
if do_j  
  J     = xmlLoad( fullfile( R.workfolder, 'jacobian.xml' ) );
end

%------------------------------------------------------------------------------





%--- Post-processing ----------------------------------------------------------

%- Rescaling of jacobians in relative units
%
if do_j  &  iter > 1  &  ~isempty( i_rel )
  J(:,i_rel) =  J(:,i_rel) ./ repmat( x(i_rel)', size(J,1), 1 );
end

%------------------------------------------------------------------------------




%- Something went wrong?
%
catch
  delete_tmpfolder( R.workfolder );
  rethrow(lasterror);
end

return





%--- Internal sub-functions ---------------------------------------------------

function [rgrid1,rgrid2,rgrid3,x] = ...
                 x2field( dim, rgrids, x, grid1, grid2, grid3 )
  %
  if dim == 1
    %
    [rgrid1,f1,l1] = expand_grid( rgrids{1}, grid1 );
    %
    rgrid2 = NaN;
    rgrid3 = NaN;
    %
    if ~isempty(f1)  |  ~isempty(l1)
      x = [ x(f1); vec2col(x); x(l1) ];   % x as row vector accepted !
    end 
    %
  elseif dim == 2
    %
    x = reshape( x, length(rgrid1), length(rgrid2) );
    %
    rgrid3 = NaN;
    %
    [rgrid1,f1,l1] = expand_grid( rgrids{1}, grid1 );
    [rgrid2,f2,l2] = expand_grid( rgrids{2}, grid2 );
    %
    if ~isempty(f1)  |  ~isempty(l1)  |  ~isempty(f2)  |  ~isempty(l2)
      x = [ x(f1,f2) x(f1,:) x(f1,l2); 
            x(:,f2)  x       x(:,l2); 
            x(l1,f2) x(l1,:) x(l1,l2) ];
    end 
  elseif dim == 2
     error('3D not yet handled by x2field.');
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