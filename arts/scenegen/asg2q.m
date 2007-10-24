% ASG2Q   Maps ASG data to qarts structure
%
%    The function searches the input gformat data and sets corresponding qarts
%    fields. For example, (first) item in G with field *NAME* equal to
%    'Temperature' is mapped to Q.T_FIELD. All data are expected to match
%    the atmospheric grids (Q.P_GRID ...). No re-griding is performed.
%    Not all data have to be provided.
%
%    The following qarts fields are always set:
%       USE_RAW_ATMOSPHERE 
%       RAW_ATMOSPHERE     
%       RAW_ATM_EXPAND_1D  
%       BATCH
%
%    The following qarts fields are considered if matching data are found:
%       T_FIELD       
%       Z_FIELD      
%       VMR_FIELD   
%       ABS_SPECIES 
%       R_GEOID     
%       Z_SURFACE   
%
%    If length(icases)==1, and for variables where only one case is provided in
%    G, the fields above are set directly. For vector *icases* and when
%    several cases are defined, batch calculations are prepared. In the
%    first case, the function *arts_y* should be used, while in the second
%    case *arts_batch* must be used.
%
% FORMAT   Q = asg2q( D, G, Q, workfolder [, icases ] )
%        
% OUT   Q            Qarts structure with some fields set.
% IN    D            Gformat definition structure.
%       G            ASG data.
%       Q            Original qarts structure.
%       workfolder   Folder where created files shall be saved.
%       icases       Index of cases to consider. Default is 1.

% 2007-10-22   Created by Patrick Eriksson


function Q = asg2q( D, G, Q, workfolder, icases )

  
%- Default values
%
icases_DEFAULT = 1;
%
set_defaults;


%- Basic checks of input
%
if isempty(workfolder)  |  ~exist(workfolder,'dir')
  error( 'Empty or not existing folder in *workfolder*.' );
end


%- Check that atmospheric grids are set
%
rqre_scalar( 'Q.ATMOSPHERE_DIM', Q.ATMOSPHERE_DIM, 1, 3 );
%
if isnan( Q.P_GRID )  |  isscalar( Q.P_GRID )
  error( 'No valid grid found for Q.P_GRID.' );
else
  
end
if Q.ATMOSPHERE_DIM >= 2 & ( isnan( Q.LAT_GRID )  |  isscalar( Q.LAT_GRID ) )
  error( 'No valid grid found for Q.LAT_GRID.' );
end
if Q.ATMOSPHERE_DIM >= 3 & ( isnan( Q.LON_GRID )  |  isscalar( Q.LON_GRID ) )
  error( 'No valid grid found for Q.LON_GRID.' );
end


%- Find number of cases defined
%
ncases = 1;
%
for ig = 1 : length(G)
  ncases = max( [ncases size(G(ig).DATA,4) ] );
end


%- Case: OK, batch  ...?
%
if isnumeric(icases)  &  (  ( isscalar(icases)  &  ~isnan(icases) )  |  ...  
                             isvector(icases) ) 
  if any( icases < 1 )  |  any( icases > ncases )
    error( sprintf( ['You have selected cases in the range [%d,%d],',...
    'while the range [1,%d] is allowed.'], min(icases), max(icases), ncase ) );
  end
elseif ischar(icases)  &  ( strcmp(lower(icases),'batch') | ...
                           strcmp(lower(icases),'all') ) 
  icases = 1 : ncases;
else
  error( [ 'Input *icases* must be a scalar, a vector or some valid ',...
           'string ( e.g. ''batch'').' ] );
end


%- Some fields of Q
%
Q.USE_RAW_ATMOSPHERE = 0;
Q.RAW_ATMOSPHERE     = NaN;
Q.RAW_ATM_EXPAND_1D  = 0;
%
if length(icases) == 1
  Q.BATCH = NaN;
else
  Q.BATCH      = [];
  Q.BATCH.DATA = [];
  Q.BATCH.N    = length(icases);
end


%- Determine expected variable sizes and set atmospheric grids
%
np   = length( Q.P_GRID   );
nlat = length( Q.LAT_GRID );  
nlon = length( Q.LON_GRID );  
%
if Q.ATMOSPHERE_DIM == 1
  sfield = [ np    1    1   ];
  ssurf  = [ 1     1    1   ];
elseif Q.ATMOSPHERE_DIM == 2
  sfield = [ np   nlat  1   ];
  ssurf  = [ 1    nlat  1   ];
else
  sfield = [ np   nlat nlon ];
  ssurf  = [ 1    nlat nlon ];
end



%--- Clear sky profiles -----------------------------------------------------

%- t_field
%
i = min( find( strncmp( lower({G.NAME}), 'temperature', 11 ) ) );
%
if ~isempty(i)  &  size(G(i).DATA,1)
  s = [ size(G(i).DATA) 1 1 ];  % Make sure that at least 4 dims are defined
  if any( s(1:3) ~= sfield )
    error( sprintf( ...
                  'Data for t_field have not expected size (item %d).',i) );
  end
  %
  if s(4) == 1  |  length(icases) == 1
    Q.T_FIELD = fullfile( workfolder, 't_field.xml' );
    xmlStore( Q.T_FIELD, get_cases(G(i).DATA,icases(1)), 'Tensor3' );
  else
    Q.BATCH.DATA(end+1).WSV = 't_field'; 
    Q.BATCH.DATA(end).TYPE  = 'Tensor3'; 
    Q.BATCH.DATA(end).X     = fullfile( workfolder, 't_field_batch.xml' );; 
    xmlStore( Q.BATCH.DATA(end).X, get_cases(G(i).DATA,icases), 'Tensor4' );
  end
  %
end


%- z_field
%
i = min( find( strncmp( lower({G.NAME}), 'altitude', 8 ) ) );
%
if ~isempty(i)  &  size(G(i).DATA,1)
  s = [ size(G(i).DATA) 1 1 ];
  if any( s(1:3) ~= sfield )
    error( sprintf( ...
                 'Data for z_field have not expected size (item %d).',i) );
  end
  %
  if s(4) == 1  |  length(icases) == 1
    Q.Z_FIELD = fullfile( workfolder, 'z_field.xml' );
    xmlStore( Q.Z_FIELD , get_cases(G(i).DATA,icases(1)), 'Tensor3' );
  else
    Q.BATCH.DATA(end+1).WSV = 'z_field'; 
    Q.BATCH.DATA(end).TYPE  = 'Tensor3'; 
    Q.BATCH.DATA(end).X     = fullfile( workfolder, 'z_field_batch.xml' );; 
    xmlStore( Q.BATCH.DATA(end).X, get_cases(G(i).DATA,icases), 'Tensor4' );
  end
  %
end


%- vmr_field
%
ind1 = find( strcmp( lower({G.DATA_NAME}), 'volume mixing ratio' ) );
%
if ~isempty(ind1)
  %
  do_batch = false;    % Shall gas species be handled in batch mode?
  ind2     = [];
  %
  for i = 1 : length(ind1)
    s = [ size(G(ind1(i)).DATA) 1 1 ];
    if s(1)
      ind2 = [ ind2 ind1(i) ];
    else
      continue;   % --->
    end
    if any( s(1:3) ~= sfield )
      error( sprintf( 'Data for %s have not expected size (item %d).',...
                                                     G(ind1(i)).NAME, i) );
    end
    %
    if s(4) > 1
      do_batch = true;
    end
    %
    if ischar( G(ind1(i)).PROPS )
      Q.ABS_SPECIES{i} = { G(ind1(i)).PROPS };
    elseif iscell( G(ind1(i)).PROPS )
      Q.ABS_SPECIES{i} = G(ind1(i)).PROPS;
    else
      error( sprintf( 'Not handled tag format for %s (item %d).',...
                                                     G(ind1(i)).NAME, i) );
    end
  end
  %
  if ~do_batch
    Q.VMR_FIELD = zeros( [ length(ind2) sfield] );
    for i = 1 : length(ind2)
      Q.VMR_FIELD(i,:,:,:) = get_cases(G(ind2(i)).DATA,icases(1));
    end
    filename = fullfile( workfolder, 'vmr_field.xml' );
    xmlStore( filename, Q.VMR_FIELD, 'Tensor4' );
    Q.VMR_FIELD = filename;
  else
    data = zeros( [ length(icases) length(ind2) sfield] );
    for i = 1 : length(ind2)
      data(:,i,:,:,:) = get_cases(G(ind2(i)).DATA,icases);
    end
    Q.BATCH.DATA(end+1).WSV = 'vmr_field'; 
    Q.BATCH.DATA(end).TYPE  = 'Tensor4'; 
    Q.BATCH.DATA(end).X     = fullfile( workfolder, 'vmr_field_batch.xml' );
    xmlStore( Q.BATCH.DATA(end).X, data, 'Tensor5' );
    clear data
  end
end





%--- Surface and geoid -----------------------------------------------------

%- r_geoid
%
i = min( find( strcmp( lower({G.NAME}), 'geoid radius' ) ) );
%
if ~isempty(i)   &  size(G(i).DATA,1)
  s = [ size(G(i).DATA) 1 1 ];
  if any( s(1:3) ~= ssurf )
    error( sprintf( ...
                  'Data for r_geoid have not expected size (item %d).',i) );
  end
  %
  if s(4) == 1  |  length(icases) == 1
    Q.R_GEOID = fullfile( workfolder, 'r_geoid.xml' );
    xmlStore( Q.R_GEOID , getdims(get_cases(G(i).DATA,icases(1)),2:3), ...
                                                                  'Matrix' );
  else
    Q.BATCH.DATA(end+1).WSV = 'r_geoid'; 
    Q.BATCH.DATA(end).TYPE  = 'Matrix'; 
    Q.BATCH.DATA(end).X     = fullfile( workfolder, 'r_geoid_batch.xml' );; 
    xmlStore( Q.BATCH.DATA(end).X, ...
              getdims(get_cases(G(i).DATA,icases),[1 3 4]), 'Tensor3' );
  end
  %
end


%- z_surface
%
i = min( find( strcmp( lower({G.NAME}), 'surface altitude' ) ) );
%
if ~isempty(i)  &  size(G(i).DATA,1)
  s = [ size(G(i).DATA) 1 1 ];
  if any( s(1:3) ~= ssurf )
    error( sprintf( ...
                'Data for z_surface have not expected size (item %d).',i) );
  end
  %
  if s(4) == 1  |  length(icases) == 1
    Q.Z_SURFACE = fullfile( workfolder, 'z_surface.xml' );
    xmlStore( Q.Z_SURFACE , getdims(get_cases(G(i).DATA,icases(1)),2:3), ...
                                                                  'Matrix' );
  else
    Q.BATCH.DATA(end+1).WSV = 'z_surface'; 
    Q.BATCH.DATA(end).TYPE  = 'Matrix'; 
    Q.BATCH.DATA(end).X     = fullfile( workfolder, 'z_surface_batch.xml' );; 
    xmlStore( Q.BATCH.DATA(end).X, ...
              getdims(get_cases(G(i).DATA,icases),[1 3 4]), 'Tensor3' );
  end
  %
end




function B = get_cases( A, icases )
  
if length( icases ) == 1
  if icases <= size(A,4)
    B = A(:,:,:,icases);
  else
    B = A(:,:,:,end);
  end    
else
  s = [ size(A) 1 ];
  B = zeros( [ length(icases) s(1:3) ] );
  for i = 1 : length(icases)
    B(i,:,:,:) = get_cases( A, icases(i) );
  end
end
