% ASG2Q   Maps ASG data to qarts structure
%
%    The function searches the input gformat data and sets corresponding qarts
%    fields. For example, (first) item in G with field *NAME* equal to
%    'Temperature' is mapped to Q.T_FIELD. Not all data have to be provided.
%
%    The following qarts fields are always set:
%       USE_RAW_ATMOSPHERE 
%       RAW_ATMOSPHERE     
%       RAW_ATM_EXPAND_1D  
%
%    The following qarts fields are set if matching data are found:
%       T_FIELD       
%       Z_FIELD      
%       VMR_FIELD   
%       ABS_SPECIES 
%       R_GEOID     
%       Z_SURFACE   
%
% FORMAT   Q = asg2q( D, G, Q, workfolder )
%        
% OUT   Q            Qarts structure with some fields set.
% IN    D            Gformat definition structure.
%       G            ASG data.
%       Q            Original qarts structure.
%       workfolder   Folder where created files shall be saved.

% 2007-10-22   Created by Patrick Eriksson


function Q = asg2q( D, G, Q, workfolder )


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


%- Some fields of Q
%
Q.USE_RAW_ATMOSPHERE = 0;
Q.RAW_ATMOSPHERE     = NaN;
Q.RAW_ATM_EXPAND_1D  = 0;


%- Determine expected variable sizes and set atmospheric grids
%
np   = length( Q.P_GRID   );
nlat = length( Q.LAT_GRID );  
nlon = length( Q.LON_GRID );  
%
if Q.ATMOSPHERE_DIM == 1
  sfield = [ np    1    ];
  ssurf  = [ 1     1    ];
elseif Q.ATMOSPHERE_DIM == 2
  sfield = [ np    nlat ];
  ssurf  = [ 1     nlat ];
else
  sfield = [ np    nlat nlon ];
  ssurf  = [ nlat  nlon      ];
end



%--- Clear sky profiles -----------------------------------------------------

%- t_field
%
i = min( find( strncmp( lower({G.NAME}), 'temperature', 11 ) ) );
%
if ~isempty(i)
  if any( size(G(i).DATA) ~= sfield )
    error( sprintf( ...
                  'Data for t_field have not expected size (item %d).',i) );
  end
  %
  Q.T_FIELD = fullfile( workfolder, 't_field.xml' );
  xmlStore( Q.T_FIELD , G(i).DATA, 'Tensor3' );
  %
end


%- z_field
%
i = min( find( strncmp( lower({G.NAME}), 'altitude', 8 ) ) );
%
if ~isempty(i)
  if any( size(G(i).DATA) ~= sfield )
    error( sprintf( ...
                 'Data for z_field have not expected size (item %d).',i) );
  end
  %
  Q.Z_FIELD = fullfile( workfolder, 'z_field.xml' );
  xmlStore( Q.Z_FIELD , G(i).DATA, 'Tensor3' );
  %
end


%- vmr_field
%
ind = find( strcmp( lower({G.DATA_NAME}), 'volume mixing ratio' ) );
%
if ~isempty(ind)
  %
  Q.VMR_FIELD = zeros( [ length(ind) sfield] );
  %
  for i = 1 : length(ind)
    if any( size(G(ind(i)).DATA) ~= sfield )
      error( sprintf( 'Data for %s have not expected size (item %d).',...
                                                     G(ind(i)).NAME, i) );
    end
    %
    Q.VMR_FIELD(i,:,:,:) = G(ind(i)).DATA;
    %
    if ischar( G(ind(i)).PROPS )
      Q.ABS_SPECIES{i} = { G(ind(i)).PROPS };
    elseif iscell( G(ind(i)).PROPS )
      Q.ABS_SPECIES{i} = G(ind(i)).PROPS;
    else
      error( sprintf( 'Not handled tag format for %s (item %d).',...
                                                     G(ind(i)).NAME, i) );
    end
  end
  %
  filename = fullfile( workfolder, 'vmr_field.xml' );
  xmlStore( filename, Q.VMR_FIELD, 'Tensor4' );
  Q.VMR_FIELD = filename;
  %
end





%--- Surface and geoid -----------------------------------------------------

%- r_geoid
%
i = min( find( strcmp( lower({G.NAME}), 'geoid radius' ) ) );
%
if ~isempty(i)
  if any( size(G(i).DATA) ~= ssurf )
    error( sprintf( ...
                  'Data for r_geoid have not expected size (item %d).',i) );
  end
  %
  Q.R_GEOID = fullfile( workfolder, 'r_geoid.xml' );
  xmlStore( Q.R_GEOID , getdims(G(i).DATA,2:3), 'Matrix' );
  %
end


%- z_surface
%
i = min( find( strcmp( lower({G.NAME}), 'surface altitude' ) ) );
%
if ~isempty(i)
  if any( size(G(i).DATA) ~= ssurf )
    error( sprintf( ...
                'Data for z_surface have not expected size (item %d).',i) );
  end
  %
  Q.Z_SURFACE = fullfile( workfolder, 'z_surface.xml' );
  xmlStore( Q.Z_SURFACE , getdims(G(i).DATA,2:3), 'Matrix' );
  %
end
