% ASG2Q   Maps ASG data to qarts structure
%
%    The function searches the input gformat data and sets corresponding qarts
%    fields. Data type is primarily determined by the field NAME, as follows:
%
%        NAME                       ARTS variable
%        ----                       ----
%        temperature                t_field
%        altitude                   z_field
%        vmr                        vmr_field
%        volume mixing ratio        vmr_field
%        surface elevation          z_surface
%        surface skin temperature   skin_t_field
%        -
%        surface_refractive_index
%          or                       see below
%        surface_reflectivity
%
%    The NAME text string can include uppercase lettters. Not all these
%    variables must be covered. There can only exist one element in G that
%    gives a match, beside for vmr data.
%
%    For vmr, each match adds a species to ABS_SPECIES. For such cases, G
%    must contain the field PROPS that must match ABS_SPECIES.TAG directly.
%    ABS_SPECIES.RETRIEVE is set to false.
%
%    For surface RT properties, 'surface_refractive_index' and
%    'surface_reflectivity' are the options at hand. In the first case, the
%    input can have dimension 0, 1, 4 or 6, ampped to
%    surface_scalar_reflectivity, surface_scalar_reflectivity, GriddedField4
%    and GriddedField6, respectively. In the second case, the allowed
%    dimensions are 3 and 5, mapped to surface_complex_refr_index and
%    GriddedField5, respectively. In all cases, Q.SURFACE_RTPROP_AGENDA is set
%    in a matching way, using e.g. surface_complex_refr_indexFromGriddedField5.
%    If the G element holding these properties has a field named as
%    DZA_DOWN, surface_los is disturbed with this (scalar) value.
%    All options above assume that skin_t_field has been set.
%
% FORMAT   Q = asg2q( G, Q, workfolder )
%
% OUT   Q            Qarts structure with some fields set.
% IN    G            ASG data.
%       Q            Original qarts structure.
%       workfolder   Data will be stored in this folder

% 2010-01-25   Created by Patrick Eriksson
% 2014-09-02   Updated by Bengt Rydberg

function Q = asg2q( G, Q , workfolder )

strictAssert = atmlab('STRICT_ASSERT');

if strictAssert
  %- Check that atmospheric grids are set
  %
  if ~qarts_isset( Q.ATMOSPHERE_DIM )
    error( 'Q.ATMOSPHERE_DIM must be set.' );
  end
  if ~qarts_isset( Q.P_GRID )
    error( 'Q.P_GRID must be set.' );
  end
end


dim    = qarts_get( Q.ATMOSPHERE_DIM );
p_grid = qarts_get( Q.P_GRID );
np     = length( p_grid );


if strictAssert
  rqre_in_range( dim, 1, 3, 'Q.ATMOSPHERE_DIM' );
  if ~istensor1(p_grid)  |  np < 2
    error( 'Q.P_GRID must be a tensor1 with length > 1.' );
  end
end
%
if dim >= 2
  if ~qarts_isset( Q.LAT_GRID )
    error( 'Q.LAT_GRID must be set.' );
  end
  lat_grid = Q.LAT_GRID;
  nlat     = length( lat_grid );
  if ~istensor1(lat_grid)  |  nlat < 2
    error( 'Q.LAT_GRID must be a tensor1 with length > 1.' );
  end
  if Q.ATMOSPHERE_DIM >= 3
    if ~qarts_isset( Q.LON_GRID )
      error( 'Q.LON_GRID must be set.' );
    end
    %lon_grid = qarts_grid( Q.LON_GRID );
    lon_grid = Q.LON_GRID;
    nlon     = length( lon_grid );
    if ~istensor1(lon_grid)  |  nlon < 2
      error( 'Q.LON_GRID must be a tensor1 with length > 1.' );
    end
  end
end


%- Determine expected variable sizes
%
if Q.ATMOSPHERE_DIM == 1
  sfield = [ np    1    1    1 ];
  ssurf  = [       1    1    1 ];
elseif Q.ATMOSPHERE_DIM == 2
  sfield = [ np   nlat  1    1 ];
  ssurf  = [      nlat  1    1 ];
else
  sfield = [ np   nlat nlon  1 ];
  ssurf  = [      nlat nlon  1 ];
end


%--- Clear sky profiles -------------------------------------------------------

%- t_field
%
i  = 0;
in = 1;
for j = 1:length(G)
  if isequal(lower(G{j}.NAME), 'temperature');
    i(in) = j;
    in = in + 1;
  end
end
%
if ~isempty(i)
  if length(i) > 1
    error('Multiple matches between G.NAME and ''temperature'' were found.');
  end
  if G{i}.DIM ~= dim
    error(sprintf('Wrong dimension of G{%d}.', i));
  end
  s = [ size(G{i}.DATA) 1 1 ];
  if any(s(1:4) ~= sfield )
    error(sprintf('Wrong size of G{%d}.DATA', i));
  end
  %
  Q.T_FIELD = fullfile( workfolder, 't_field.xml' );
  xmlStore( Q.T_FIELD, G{i}.DATA, 'Tensor3' );
end


%- z_field
%
i = 0;
in = 1;
for j = 1:length(G)
  if strncmp( lower(G{j}.NAME), 'altitude',8);
    i(in) = j;
    in = in + 1;
  end
end
%
if ~isempty(i)
  if length(i) > 1
    error('Multiple matches between G.NAME and ''altitude'' weres found.' );
  end
  if G{i}.DIM ~= dim
    error(sprintf('Wrong dimension of G{%d}.',i));
  end
  s = [ size(G{i}.DATA) 1 1 ];
  if any( s(1:4) ~= sfield )
    error(sprintf('Wrong size of G{%d}.DATA',i));
  end
  %
  Q.Z_FIELD = fullfile( workfolder, 'z_field.xml' );
  xmlStore( Q.Z_FIELD, G{i}.DATA, 'Tensor3' );
end


%- vmr_field
%
ind = 0;
in = 1;
for j = 1:length(G)
  if (strcmp( lower(G{j}.DATA_NAME), 'volume mixing ratio') | ...
      strcmp( lower(G{j}.DATA_NAME), 'vmr'));
    ind(in) = j;
    in = in + 1;
  end
end
%
if ~isempty(ind)
  %
  vmr_field = zeros( [ length(ind) sfield ] );
  %
  for i = 1 : length(ind)
    if G{ind(i)}.DIM ~= dim
      error( sprintf('Wrong dimension of G{%d}.', ind(i)) );
    end
    s = [ size(G{ind(i)}.DATA) 1 1 ];
    if any( s(1:4) ~= sfield )
      error( sprintf('Wrong size of G{%d}.DATA', ind(i)) );
    end
    %
    vmr_field(i,:,:,:)        = G{ind(i)}.DATA;
    if i==1
       Q.ABS_SPECIES=[];
    end
    Q.ABS_SPECIES(i).TAG      = G{ind(i)}.PROPS;
    Q.ABS_SPECIES(i).RETRIEVE = false;
  end
  %
  Q.VMR_FIELD = fullfile( workfolder, 'vmr_field.xml' );
  xmlStore( Q.VMR_FIELD, vmr_field, 'Tensor4' );
end



%--- Surface ------------------------------------------------------------

%- z_surface
%
i = 0;
in = 1;
for j = 1:length(G)
  if strcmp( lower(G{j}.NAME), 'surface elevation');
    i(in) = j;
    in = in + 1;
  end
end
%
if ~isempty(i)
  if length(i) > 1
    error( ...
     'Multiple matches between G.NAME and ''surface elevation'' were found.');
  end
  if G{i}.DIM ~= dim-1
    error( sprintf('Wrong dimension of G{%d}.',i) );
  end
  s = [ size(G{i}.DATA) 1 1 ];
  if any( s(1:3) ~= ssurf )
    error( sprintf('Wrong size of G{%d}.DATA',i) );
  end
  %
  Q.Z_SURFACE = fullfile( workfolder, 'z_surface.xml' );
  xmlStore( Q.Z_SURFACE, G{i}.DATA, 'Matrix' );
end



%- surface skin temperature
%
i = 0;
in = 1;
for j = 1:length(G)
  if strcmp( lower(G{j}.NAME), 'surface skin temperature');
    i(in) = j;
    in = in + 1;
  end
end
%
if ~isempty(i)
  if length(i) > 1
    error( ['Multiple matches between G.NAME and ',
            '''surface skin temperature'' were found.'] );
  end
  if G{i}.DIM ~= dim-1
    error( sprintf('Wrong dimension of G{%d}.',i) );
  end
  s = [ size(G{i}.DATA) 1 1 ];
  if any( s(1:3) ~= ssurf )
    error( sprintf('Wrong size of G{%d}.DATA',i) );
  end
  %
  filename = fullfile( workfolder, 'skin_t_field.xml' );
  xmlStore( filename, G{i}.DATA, 'Matrix' );
  %
  Q.WSMS_BEFORE_ATMSURF{end+1} = 'MatrixCreate(skin_t_field)';
  Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
                       'ReadXML( skin_t_field, "%s" )', filename );
end



%- surface reflectivity / refractive index
%
i = 0;
in = 1;
for j = 1:length(G)
  if (strcmp( lower(G{j}.NAME), 'surface_reflectivity') | ...
      strcmp( lower(G{j}.NAME), 'surface_refractive_index')) ;
    i(in) = j;
    in = in + 1;
  end
end

if ~isempty(i)
  if length(i) > 1
    error( ...
      ['Multiple matches between G.NAME and ''surface_reflectivity'' ',
       ' and ''surface_refractive_index''' were found.']);
  end

  for j=1:G{i}.DIM;
    d.grids{j}     = G{i}.(sprintf('GRID%d',j));
    d.gridnames{j} = G{i}.(sprintf('GRID%d_NAME',j));
  end
  d.data   = G{i}.DATA;
  filename = fullfile(workfolder,'surfrtdata.xml');

  % Reflectivity data provided
  if isequal( G{i}.DATA_NAME, 'surface_reflectivity' );

    if( G{i}.DIM==0 | G{i}.DIM==1 )
      %
      Q.WSMS_BEFORE_ATMSURF{end+1}   = sprintf( ...
                         'VectorSet( surface_scalar_reflectivity, [%s] )', ...
                                                                     d.data );
      Q.SURFACE_RTPROP_AGENDA{end+1} = 'specular_losCalc';
      Q.SURFACE_RTPROP_AGENDA{end+1} = ...
       'InterpSurfaceFieldToPosition( out=surface_skin_t, field=skin_t_field )';
      Q.SURFACE_RTPROP_AGENDA{end+1} = 'surfaceFlatScalarReflectivity';


    elseif G{i}.DIM==4;
      %
      xmlStore(filename, d, 'GriddedField4' );
      Q.WSMS_BEFORE_ATMSURF{end+1}   = 'GriddedField4Create(r_gfield)';
      Q.WSMS_BEFORE_ATMSURF{end+1}   = sprintf( 'ReadXML( r_gfield, "%s")', ...
                                                                    filename );
      Q.SURFACE_RTPROP_AGENDA{end+1} = 'specular_losCalc';
      Q.SURFACE_RTPROP_AGENDA{end+1} = ...
            'surface_scalar_reflectivityFromGriddedField4( r_field=r_gfield )';
      Q.SURFACE_RTPROP_AGENDA{end+1} = ...
       'InterpSurfaceFieldToPosition( out=surface_skin_t, field=skin_t_field )';
      Q.SURFACE_RTPROP_AGENDA{end+1} = 'surfaceFlatScalarReflectivity';


    elseif G{i}.DIM==6;
      %
      xmlStore( filename, d, 'GriddedField6' );
      Q.WSMS_BEFORE_ATMSURF{end+1}   = 'GriddedField6Create(r_gfield)';
      Q.WSMS_BEFORE_ATMSURF{end+1}   = sprintf( 'ReadXML( r_gfield, "%s")', ...
                                                                    filename );
      Q.SURFACE_RTPROP_AGENDA{end+1} = 'specular_losCalc';
      Q.SURFACE_RTPROP_AGENDA{end+1} = ...
                   'surface_reflectivityFromGriddedField6( r_field=r_gfield )';
      Q.SURFACE_RTPROP_AGENDA{end+1} = ...
       'InterpSurfaceFieldToPosition( out=surface_skin_t, field=skin_t_field )';
      Q.SURFACE_RTPROP_AGENDA{end+1} = 'surfaceFlatReflectivity';
    else
      error('asg2q only handles surface_reflectivity with dim 0, 1, 4 or 6.');
    end

  % Refractive index provided
  elseif isequal( G{i}.DATA_NAME, 'surface_refractive_index' )

    if G{i}.DIM==3;
      xmlStore( filename, d, 'GriddedField3' );
      Q.WSMS_BEFORE_ATMSURF{end+1}   = sprintf( ...
                             'ReadXML( surface_complex_refr_index, "%s")', ...
                                                                    filename );
      Q.SURFACE_RTPROP_AGENDA{end+1} = 'specular_losCalc';
      Q.SURFACE_RTPROP_AGENDA{end+1} = ...
       'InterpSurfaceFieldToPosition( out=surface_skin_t, field=skin_t_field )';
      Q.SURFACE_RTPROP_AGENDA{end+1} = 'surfaceFlatRefractiveIndex';

    elseif G{i}.DIM==5;
      xmlStore( filename, d, 'GriddedField5' );
      Q.WSMS_BEFORE_ATMSURF{end+1}   = 'GriddedField5Create(n_gfield)';
      Q.WSMS_BEFORE_ATMSURF{end+1}   = sprintf( 'ReadXML( n_gfield, "%s")',...
                                                                    filename );
      Q.SURFACE_RTPROP_AGENDA{end+1} = 'specular_losCalc';
      Q.SURFACE_RTPROP_AGENDA{end+1} = ...
       'InterpSurfaceFieldToPosition( out=surface_skin_t, field=skin_t_field )';
      Q.SURFACE_RTPROP_AGENDA{end+1} = ...
                        [ 'surface_complex_refr_indexFromGriddedField5( ',...
                          'complex_refr_index_field=n_gfield )' ];
      Q.SURFACE_RTPROP_AGENDA{end+1} = 'surfaceFlatRefractiveIndex';
    else
      error('asg2q only handles surface refractive index with dim 3 or 5')
    end
  end

  if isfield( G{i}, 'DZA_DOWN' )
    Q.WSMS_BEFORE_ATMSURF{end+1}   = 'NumericCreate(dza_down)';
    Q.WSMS_BEFORE_ATMSURF{end+1}   = sprintf( 'NumericSet( dza_down, %d)', ...
                                                               G{i}.DZA_DOWN );
    Q.SURFACE_RTPROP_AGENDA{end+1} = ...
                      'MatrixAddScalar( surface_los, surface_los, dza_down )';
  end

end
