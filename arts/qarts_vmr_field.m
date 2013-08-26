% QARTS_VMR_FIELD   Extracts vmr field from Q.ABS_SPECIES.ATMDATA
%
%   Performs an interpolation of Q.ABS_SPECIES.ATMDATA. The field ATMDATA must
%   be set for all species. For 3D cases, P_GRID, LAT_GRID and LON_GRID are
%   used as interpolation grids. For 1D and 2D, LAT_TRUE and LON_TRUE replace
%   LAT_GRID and LON_GRID.
%
%   The interpolation is made as using *gridinterp* with its optional argument
%   *extrap* set to true. That is, the data are assumed to be defined
%   everywhere (end values valid all the way to +-INF). This is also valid for
%   singleton dimensions. The grid for empty/singleton dimensions can be empty
%   or a scalar.
%
%   It is also possible to handle atmdata having date and hour dimensions. The
%   optional arguments must then be set.
%
%   The following fields must always be set:
%      Q.ATMOSPHERE_DIM
%      Q.P_GRID
%      Q.ABS_SPECIES
%
% FORMAT   vmr_field = qarts_vmr_field( Q [, mjd, ltime] )
%        
% OUT   vmr_field   Obtained vmr field.
% IN    Q           Qarts setting structure.
% OPT   mjd         Date as MJD. A scalar.
%       ltime       Local (solar) time, in hours. A scalar.

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

ns = length( Q.ABS_SPECIES );

for j = 1 : ns
%- Set interpolation grids
%
if ~qarts_isset( Q.P_GRID )                                                 %&%
  error( 'Q.P_GRID must be set when using this function' );                 %&%
end                                                                         %&%
grids{1} = qarts_get( Q.P_GRID );
%
if Q.ATMOSPHERE_DIM < 3
  grids{2} = qarts_get( Q.LAT_TRUE );
  grids{3} = qarts_get( Q.LON_TRUE );
else
  grids{2} = qarts_get( Q.LAT_GRID );
  grids{3} = qarts_get( Q.LON_GRID );
end
%
if ~isempty(varargin)
for i = 1 : length( varargin )
  rqre_datatype( varargin{i}, @istensor0, ...                               %&%
                                 'Optional arguments *mjd* and *ltime*.' ); %&%
  grids{3+i} = varargin{i};
end
end


% %- Allocate vmr_field
% %
% ns = length( Q.ABS_SPECIES );
% n  = [ ns ones(1,3) ];
% %
% for i = 1 : length(grids)
%   l = length( grids{i} );
%   if l > 1
%     n(i+1) = l;
%   end
% end
% %
% vmr_field = zeros( n );


%- Loop species and interpolate
%
%
vname = sprintf( 'Q.ABS_SPECIES(%d).ATMDATA', j );
%
G = qarts_get_gformat( Q.ABS_SPECIES(j).ATMDATA );
rqre_datatype( G, @isatmdata, vname );                                    %&%
%
% Minimum dimension for interpolation is Q.ATMOSPHERE_DIM
dim = max( [ G.DIM Q.ATMOSPHERE_DIM ] );
%
if Q.ATMOSPHERE_DIM ~= 2
   G = atmdata_regrid( G, {grids{1:dim}}, vname ); 
   vmr_field(j,:,:,:) = G.DATA;
elseif Q.ATMOSPHERE_DIM == 2
   G = atmdata_regrid( G, {grids{1} G.GRID2 G.GRID3 grids{4}}, vname ); 
   for i = 1:length(G.GRID1)
   vmr_field(j,i,:) = pointinterp({G.GRID2 G.GRID3},squeeze(G.DATA(i,:,:)),[qarts_get( Q.LAT_TRUE ) qarts_get( Q.LON_TRUE )]);
   end
end
%
end


