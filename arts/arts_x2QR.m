% ARTS_x2QR   Maps an x state to Q and R fields
%
%    The function updates *Q* and *R* to match the present state of *x*.
%
%    No forward model calculations are performed.
%
% FORMAT   [Q,R] = arts_x2QR( Q, R, x )
%        
% OUT   Q      Modified Q structure.
%       R      Modified R structure.
% IN    Q      Qarts structure.
%       R      Retrieval data structure. 
%       x      State vector.

% 2010-01-11   Started by Patrick Eriksson.


function [Q,R] = arts_x2QR(Q,R,x)


%- General variables
%
nq       = length( R.jq );                  % Number of retrieval quantities.
%
i_asj    = find([Q.ABS_SPECIES.RETRIEVE]);  % Index of retrieval absorption
%                                             species.
any_gas  = false;                           % Any gas species among rq
% 
bl       = 0;                               % Sum of all baseline terms
%  
j_loaded = false;                           % To avoid repeated loading of J
%
do_sensor = false;                          % Recalculation of sensor needed


%- Loop retrieval quantities
%
for i = 1 : nq

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag

   case 'Absorption species'   %----------------------------------------------
    %
    if ~any_gas
      vmr = R.vmr_field0;    % Will be filled with latest VMR for all species
    end                      % that are retrieved
    any_gas   = true;
    ig        = i_asj(i);    % Gas species index
    %
    X = x2field( Q.ATMOSPHERE_DIM, R.jq{i}.grids, x(ind) );
    X = arts_regrid( Q.ATMOSPHERE_DIM, R.jq{i}.grids, X, Q );
    %
    if strcmp( R.jq{i}.mode, 'rel' )
      vmr(ig,:,:,:) = getdims( vmr(ig,:,:,:), 2:Q.ATMOSPHERE_DIM+1 ) .* X;
    elseif strcmp( R.jq{i}.mode, 'vmr' )
      vmr(ig,:,:,:) = X;
    elseif strcmp( R.jq{i}.mode, 'nd' )
      vmr(ig,:,:,:) = nd2vmr( X, repmat(R.p_grid,[1 size2(X,2:3)]), ...
                             qarts_get(fullfile(R.workfolder,'t_field.xml')) );
    elseif strcmp( R.jq{i}.mode, 'logrel' )
      vmr(ig,:,:,:) = getdims( vmr(ig,:,:,:), 2:Q.ATMOSPHERE_DIM+1 ) .* exp(X);
    else                                                                    %&%
      assert( false );                                                      %&%
    end
    %
    clear X
    
   case 'Atmospheric temperatures'   %----------------------------------------
    %
    X = x2field( Q.ATMOSPHERE_DIM, R.jq{i}.grids, x(ind) );
    X = arts_regrid( Q.ATMOSPHERE_DIM, R.jq{i}.grids, X, Q );
    xmlStore( fullfile(R.workfolder,'t_field.xml'), X, 'Tensor3' );
    %
    clear X
   
   case 'Frequency'   %-------------------------------------------------------
    %
    if ~do_sensor
      Q.SENSOR_RESPONSE = R.sensor_response;
    end    
    %
    fb = qarts_get(Q.SENSOR_RESPONSE.F_BACKEND);
    %
    % Shift part
    df = x(ind(1));
    %
    % Stretch part
    if length( ind ) > 1
      df = df + x(ind(2)) * arts_polybasis_func( fb, 1 );
    end     
    Q.SENSOR_RESPONSE.F_BACKEND = fb + df;
    do_sensor                   = true;
    clear   fb;
      
   case 'Polynomial baseline fit'   %-----------------------------------------
    %
    if ~j_loaded
      J        = xmlLoad( fullfile( R.workfolder, 'jacobian.xml' ) );
      j_loaded = 1;
    end
    %
    bl = bl + J(:,ind) * x(ind);
      
    otherwise   %--------------------------------------------------------------
      error('Unknown retrieval quantitity.'); 
  end 
end 


%- Data to save ?
%
if any_gas
  xmlStore( fullfile(R.workfolder,'vmr_field.xml'), vmr, 'Tensor4' );
end


%- Update sensor characteristics
%
arts_sensor( Q, R.workfolder );


%- Total baseline
%
R.bl = bl;

return



%--- Internal sub-functions ----------------------------------------------------

function X = x2field( dim, rgrids, x )
  %
  map = ones( 1, 3 );
  for i = 1 : dim
    map(i) = length( rgrids{i} );
  end
  X = reshape( x, map );
return
