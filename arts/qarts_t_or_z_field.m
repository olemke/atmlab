% QARTS_T_OR_Z_FIELD   Extracts t or z field from Q.T/Z_ATMDATA
%
%   Works as qarts_vmr_field but makes instead an interpolation of 
%   T_ATMDATA or Z_ATMDATA.
%
% FORMAT   tzfield = qarts_t_or_z_field( Q, t_or_z [, day, hour] )
%        
% OUT   tzfield     Obtained data field.
% IN    Q           Qarts setting structure.
%       t_or_z      Either 't' or 'z' to flag if T_ABSDATA or Z_ABSDATA shall
%                   be interpolated.
% OPT   day         Day. A scalar.
%       hour        Hour. A scalar.

% 2010-01-09   Created by Patrick Eriksson.

function tzfield = qarts_t_or_z_field( Q, t_or_z, varargin )
                                                                            %&%
rqre_nargin( 2, nargin );                                                   %&%
rqre_datatype( t_or_z, @ischar );                                           %&%
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



%- Get data to interpolate
%
if strcmp( t_or_z, 't' )
  if ~isfield( Q.T, 'ATMDATA' ) | ~qarts_isset( Q.T.ATMDATA )               %&%
    error( 'Q.T.ATMDATA must be set when using this function' );            %&%
  end                                                                       %&%
  G = qarts_get_gformat( Q.T.ATMDATA );
  rqre_datatype( G, @isatmdata, 'Q.T.ATMDATA' );                            %&%
elseif strcmp( t_or_z, 'z' )
  if ~qarts_isset( Q.Z_ATMDATA )                                            %&%
    error( 'Q.Z_ATMDATA must be set when using this function' );            %&%
  end                                                                       %&%
  G = qarts_get_gformat( Q.Z_ATMDATA );
  rqre_datatype( G, @isatmdata, 'Q.Z_ATMDATA' );                            %&%
else                                                                        %&%
  error( 'The argument *t_or_z* must be ''t'' or ''z''.' );                 %&%
end


%- Interpolation
%
% Minimum dimension for interpolation is Q.ATMOSPHERE_DIM
dim = max( [ G.DIM Q.ATMOSPHERE_DIM ] );
%
G = atmdata_regrid( G, {grids{1:dim}}, ...
                               sprintf('Q.%c_ATMDATA',upper(t_or_z)) );
%
tzfield = G.DATA;
