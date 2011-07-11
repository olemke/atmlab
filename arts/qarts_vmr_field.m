% QARTS_VMR_FIELD   Extracts vmr field from Q.ABS_SPECIES.ATMDATA
%
%   Performs an interpolation of Q.ABS_SPECIES.ATMDATA. The field ATMDATA must
%   be set for all species. P_GRID, LAT_GRID and LON_GRID are used as
%   interpolation grids. It is here allowed (and sometime necessary) to set
%   LAT_GRID and LON_GRID to scalar values.
%
%   The interpolation is made as using *gridinterp* with its optional argument
%   *extrap* set to true. That is, the data are assumed to be defined
%   everywhere (end values valid all the way to +-INF). This is also valid for
%   singleton dimensions. The grid for empty/singleton dimensions can be empty
%   or a scalar.
%
%   It is also possible to handle atmdata having day and hour dimensions. The
%   optional arguments must then be set.
%
%   The following fields must always be set:
%      Q.ATMOSPHERE_DIM
%      Q.P_GRID
%      Q.ABS_SPECIES
%
% FORMAT   vmr_field = qarts_vmr_field( Q [, day, hour] )
%        
% OUT   vmr_field   Obtained vmr field.
% IN    Q           Qarts setting structure.
% OPT   day         Day. A scalar.
%       hour        Hour. A scalar.

% 2010-01-09   Created by Patrick Eriksson.

function vmr_field = qarts_vmr_field( Q, varargin )
                                                                            %&%
if ~qarts_isset( Q.ATMOSPHERE_DIM )                                         %&%
  error( 'Q.ATMOSPHERE_DIM must be set when using this function' );         %&%
end                                                                         %&%
if ~qarts_isset( Q.ABS_SPECIES )                                            %&%
  error( 'Q.ABS_SPECIES must be set when using this function' );            %&%
end                                                                         %&%
rqre_field( Q.ABS_SPECIES(1), 'ATMDATA', 'Q.ABS_SPECIES' );                 %&%


%- Set interpolation grids
%
if ~qarts_isset( Q.P_GRID )                                                 %&%
  error( 'Q.P_GRID must be set when using this function' );                 %&%
end                                                                         %&%
grids{1} = qarts_get( Q.P_GRID );
%
if qarts_isset( Q.LAT_GRID )                                            
  grids{2} = qarts_get( Q.LAT_GRID );
else
  grids{2} = [];  
end
%
if qarts_isset( Q.LON_GRID )                                            
  grids{3} = qarts_get( Q.LON_GRID );
else
  grids{3} = [];  
end
%
for i = 1 : length( varargin )
  rqre_datatype( varargin{i}, @istensor0, ...                               %&%
                                       'Optional arguments day and hour' ); %&%
  grids{3+i} = varargin{i};
end


%- Allocate vmr_field
%
ns = length( Q.ABS_SPECIES );
n  = [ ns ones(1,3) ];
%
for i = 1 : length(grids)
  l = length( grids{i} );
  if l > 1
    n(i+1) = l;
  end
end
%
vmr_field = zeros( n );


%- Loop species and interpolate
%
for i = 1 : ns
  %
  vname = sprintf( 'Q.ABS_SPECIES(%d).ATMDATA', i );
  %
  G = qarts_get_gformat( Q.ABS_SPECIES(i).ATMDATA );
  rqre_datatype( G, @isatmdata, vname );                                    %&%
  %
  % Minimum dimension for interpolation is Q.ATMOSPHERE_DIM
  dim = max( [ G.DIM Q.ATMOSPHERE_DIM ] );
  %
  G = atmdata_regrid( G, {grids{1:dim}}, vname );
  %
  vmr_field(i,:,:,:) = G.DATA;
  %
end

