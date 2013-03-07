% QARTS_ATM_FIELD   Extracts a basic atmospheric field from e.g. Q.T_ATMDATA
%
%   Performs an interpolation of ATMDATA, for those variables having such a
%   sub-field. Those variables include: T, Z, WIND_U, WIND_V and WIND_W.
%
%   The field ATMDATA must be set. For 3D cases, P_GRID, LAT_GRID and LON_GRID
%   are used as interpolation grids. For 1D and 2D, LAT_TRUE and LON_TRUE
%   replace LAT_GRID and LON_GRID.
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
%
% FORMAT   atmfield = qarts_atm_field( Q, vstring [, day, hour] )
%        
% OUT   atmfield    Obtained data field.
% IN    Q           Qarts setting structure.
%       vstring     The variable for which ATMDATA shall be interpolated.
%                   Case of strong is ignored. Examples: 't', 'T', 'z', 
%                   'wind_u' and 'WIND_w'.
% OPT   mjd         Date as MJD. A scalar.
%       ltime       Local (solar) time, in hours. A scalar.

% 2010-01-09   Created by Patrick Eriksson.

function atmfield = qarts_atm_field( Q, vstring, varargin )
                                                                            %&%
rqre_nargin( 2, nargin );                                                   %&%
rqre_datatype( vstring, @ischar );                                          %&%
if ~qarts_isset( Q.ATMOSPHERE_DIM )                                         %&%
  error( 'Q.ATMOSPHERE_DIM must be set when using this function' );         %&%
end                                                                         %&%


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
for i = 1 : length( varargin )
  rqre_datatype( varargin{i}, @istensor0, ...                               %&%
                                 'Optional arguments *mjd* and *ltime*.' ); %&%
  grids{3+i} = varargin{i};
end



%- Get data to interpolate
%
VNAME = upper( vstring );
astr  = sprintf( 'Q.%c.ATMDATA', VNAME );
%
if ~isfield( Q.(VNAME), 'ATMDATA' ) | ~qarts_isset( Q.(VNAME).ATMDATA )   %&%
  error( sprintf( '%s must be set when using this function', astr ) );    %&%
end                                                                       %&%
G = qarts_get_gformat( Q.(VNAME).ATMDATA );
rqre_datatype( G, @isatmdata, astr );                                     %&%


%- Interpolation
%
% Minimum dimension for interpolation is Q.ATMOSPHERE_DIM
dim = max( [ G.DIM Q.ATMOSPHERE_DIM ] );
%
G = atmdata_regrid( G, {grids{1:dim}}, astr );
%
atmfield = G.DATA;
