% ASG2Q   Maps ASG data to qarts structure
%
%    The function searches the input gformat and sets corresponding qarts
%    field. For example, (first) item in Gcs with field *name* equal to
%    'Temperature' is mapped to Q.T_FIELD. Not all data have to be provided.
%
%    The following ASG (main/sub) fields are considered:
%       ATMOSPHERE_DIM
%       P_GRID
%       LAT_GRID
%       LON_GRID
%       CREATE_FILES
%       WORKFOLDER
%
%    The following qarts fields are always set:
%       ATMOSPHERE_DIM     
%       P_GRID             
%       LAT_GRID           
%       LON_GRID           
%       USE_RAW_ATMOSPHERE 
%       RAW_ATMOSPHERE     
%       RAW_ATM_EXPAND_1D  
%
%    The following qarts fields are set if matching data are found:
%       T_FIELD       From Gcs
%       Z_FIELD        |
%       VMR_FIELD      |
%       ABS_SPECIES    |
%       R_GEOID       From Gsu
%       Z_SURFACE      |
%
% FORMAT   Q = asg2q( Q, A [, Gcs, Gsu] )
%        
% OUT   Q     Qarts structure with some fields set.
% IN    Q     Original qarts structure.
%       A     Settings for arts scene generator.
% OPT   Gcs   Clear sky profiles in gformat. Default is [].
%       Gcs   Surface variables in gformat. Default is [].

% 2007-10-10   Created by Patrick Eriksson


function Q = asg2q( Q, A, Gcs, Gsu )

%- Default values
%
Gcs_DEFAULT = [];
Gsu_DEFAULT = [];
%
set_defaults;

  
%- Basic checks of input
%
qcheck( @qarts, Q );
qcheck( @asg, A );
if ~isempty(Gcs)
  rqre_datatype( 'struct', Gcs );
end
if ~isempty(Gsu)
  rqre_datatype( 'struct', Gsu );
end
%
if A.CREATE_FILES  &  ~ischar(A.WORKFOLDER) 
  error( 'A.WORKFOLDER must be set if A.CREATE_FILES is true.' );
end



%- Check that atmospheric grids are set
%
rqre_scalar( 'A.ATMOSPHERE_DIM', A.ATMOSPHERE_DIM, 1, 3 );
%
if isnan( A.P_GRID )  |  isscalar( A.P_GRID )
  error( 'No valid grid found for A.P_GRID.' );
else
  
end
if A.ATMOSPHERE_DIM >= 2 & ( isnan( A.LAT_GRID )  |  isscalar( A.LAT_GRID ) )
  error( 'No valid grid found for A.LAT_GRID.' );
end
if A.ATMOSPHERE_DIM >= 3 & ( isnan( A.LON_GRID )  |  isscalar( A.LON_GRID ) )
  error( 'No valid grid found for A.LON_GRID.' );
end


%- Some fields of Q
%
Q.ATMOSPHERE_DIM     = A.ATMOSPHERE_DIM;
Q.P_GRID             = A.P_GRID;
Q.LAT_GRID           = NaN;     % Changed below if dim >= 2
Q.LON_GRID           = NaN;     % Changed below if dim >= 3
%
Q.USE_RAW_ATMOSPHERE = 0;
Q.RAW_ATMOSPHERE     = NaN;
Q.RAW_ATM_EXPAND_1D  = 0;



%- Determine expected variable sizes and set atmospheric grids
%
np   = length(A.P_GRID);
nlat = length(A.LAT_GRID);  
nlon = length(A.LON_GRID);  
%
if A.ATMOSPHERE_DIM == 1
  sfield     = [ np    1    ];
  ssurf      = [ 1     1    ];
elseif A.ATMOSPHERE_DIM == 2
  Q.LAT_GRID = A.LAT_GRID;  
  sfield     = [ np    nlat ];
  ssurf      = [ nlat  1    ];
else
  Q.LAT_GRID = A.LAT_GRID;  
  Q.LON_GRID = A.LON_GRID;
  sfield     = [ np    nlat nlon ];
  ssurf      = [ nlat  nlon      ];
end



%--- Clear sky profiles -----------------------------------------------------
%
if ~isempty(Gcs)

  %- t_field
  %
  i = min( find( strcmp( {Gcs.name}, 'Temperature' ) ) );
  %
  if ~isempty(i)
    if any( size(Gcs(i).data) ~= sfield )
      error( sprintf( ...
                    'Data for t_field have not expected size (item %d).',i) );
    end
    %
    if A.CREATE_FILES
      Q.T_FIELD = fullfile( A.WORKFOLDER, 't_field.xml' );
      xmlStore( Q.T_FIELD , Gcs(i).data, 'Tensor3' );
    else
      Q.T_FIELD = Gcs(i).data;
    end
  end


  %- z_field
  %
  i = min( find( strcmp( {Gcs.name}, 'Altitude' ) ) );
  %
  if ~isempty(i)
    if any( size(Gcs(i).data) ~= sfield )
      error( sprintf( ...
                   'Data for z_field have not expected size (item %d).',i) );
    end
    %
    if A.CREATE_FILES
      Q.Z_FIELD = fullfile( A.WORKFOLDER, 'z_field.xml' );
      xmlStore( Q.Z_FIELD , Gcs(i).data, 'Tensor3' );
    else
      Q.Z_FIELD = Gcs(i).data;
    end
  end

  
  %- vmr_field
  %
  ind = find( strcmp( {Gcs.data_name}, 'Volume mixing ratio' ) );
  %
  if ~isempty(ind)
    %
    Q.VMR_FIELD = zeros( [ length(ind) sfield] );
    %
    for i = 1 : length(ind)
      if any( size(Gcs(ind(i)).data) ~= sfield )
        error( sprintf( 'Data for %s have not expected size (item %d).',...
                                                       Gcs(ind(i)).name, i) );
      end
      %
      Q.VMR_FIELD(i,:,:,:) = Gcs(ind(i)).data;
      %
      if ischar( Gcs(ind(i)).tag )
        Q.ABS_SPECIES{i} = { Gcs(ind(i)).tag };
      elseif iscell( Gcs(ind(i)).tag )
        Q.ABS_SPECIES{i} = Gcs(ind(i)).tag;
      else
        error( printf( 'Not handled tag format for %s (item %d).',...
                                                       Gcs(ind(i)).name, i) );
      end
    end
    %
    if A.CREATE_FILES
      filename = fullfile( A.WORKFOLDER, 'vmr_field.xml' );
      xmlStore( filename, Q.VMR_FIELD, 'Tensor4' );
      Q.VMR_FIELD = filename;
    end
  end
  
end




%--- Surface and geoid -----------------------------------------------------
%
if ~isempty(Gsu)

  %- r_geoid
  %
  i = min( find( strcmp( {Gsu.name}, 'Geoid radius' ) ) );
  %
  if ~isempty(i)
    if any( size(Gsu(i).data) ~= ssurf )
      error( sprintf( ...
                    'Data for r_geoid have not expected size (item %d).',i) );
    end
    %
    if A.CREATE_FILES
      Q.R_GEOID = fullfile( A.WORKFOLDER, 'r_geoid.xml' );
      xmlStore( Q.R_GEOID , Gsu(i).data, 'Matrix' );
    else
      Q.R_GEOID = Gcs(i).data;
    end
  end
  

  %- z_surface
  %
  i = min( find( strcmp( {Gsu.name}, 'Surface altitude' ) ) );
  %
  if ~isempty(i)
    if any( size(Gsu(i).data) ~= ssurf )
      error( sprintf( ...
                  'Data for z_surface have not expected size (item %d).',i) );
    end
    %
    if A.CREATE_FILES
      Q.Z_SURFACE = fullfile( A.WORKFOLDER, 'z_surface.xml' );
      xmlStore( Q.Z_SURFACE , Gsu(i).data, 'Matrix' );
    else
      Q.Z_SURFACE = Gcs(i).data;
    end
  end
  
end