% QARTS_ABSTABLE   Help preparing qarts for calculation of an absorption table
%
%   Sets automatically some Q-fields (see below) needed for calculation of
%   an absorption look-up table. The fields are set to match the selected
%   pressure grid and atmospheric temperature and VMR fields. 
%
%   The pressure grid is set to be identical to P_GRID, while temperature
%   and VMR profiles are set to the mean of max and min values. 
%
%   Default values for optional arguments should work for a single
%   calculation. Temperature and "non-linear" species variations are then
%   selected automatically to precisely cover the variation of specified
%   atmospheric fields.
%
%   The following fields must always be set:
%      Q.ATMOSPHERE_DIM
%      Q.P_GRID
%      Q.USE_RAW_ATMOSPHERE
%      Q.ABS_NLS
%
% FORMAT   Q = qarts_abstable( Q, nt, dt, nnls, dnls )
%        
% OUT   Q      Q structure wth some fields automatically set. These fields
%              are:
%                 ABSORPTION
%                 ABS_P
%                 ABS_T
%                 ABS_T_PERT 
%                 ABS_VMRS 
%                 ABS_NLS_PERT
% IN    Q      Original qarts settings.
% OPT   nt     Number of temperature variations. Default is 3.
%       dt     Maximum size of temperature variation. If set to be empty,
%              an automatic selection is made. Default is [].
%       nnls   Number of variations for "non-linear" species. Default is 3.
%       dnls   Maximum size of variation for "non-linear" species. If set 
%              to be empty, an automatic selection is made. Default is [].

% 2007-08-22   Created by Patrick Eriksson.


function Q = qarts_abstable( Q, nt, dt, nnls, dnls )


%- Default values
%
nt_DEFAULT   = 3;
dt_DEFAULT   = [];
nnls_DEFAULT = 3;
dnls_DEFAULT = [];
%
set_defaults;


%- Check input
%
rqre_datatype( 'struct', Q );
%
if ~qarts_isset( Q.ATMOSPHERE_DIM )
  error( 'Q.ATMOSPHERE_DIM must be set' );
end
rqre_scalar( 'ARTS field ATMOSPHERE_DIM', Q.ATMOSPHERE_DIM, 1, 3 );
%
if ~qarts_isset( Q.P_GRID )
  error( 'Q.P_GRID must be set' );
end
%
if ~qarts_isset( Q.USE_RAW_ATMOSPHERE )
  error( 'Q.USE_RAW_ATMOSPHERE must be set' );
end
rqre_bool( 'ARTS field USE_RAW_ATMOSPHERE', Q.USE_RAW_ATMOSPHERE );
%
if ~qarts_isset( Q.ABS_NLS )
  error( 'Q.ABS_NLS must be set' );
end



%- Obtain atmospheric profiles
%
p_grid   = qarts_get( Q.P_GRID );
%
if Q.USE_RAW_ATMOSPHERE
  %
  [t_field,z_field,vmr_field] = arts_atmfields( Q ); 
else
  t_field   = qarts_get( Q.T_FIELD );
  vmr_field = qarts_get( Q.VMR_FIELD );
  %
  np = length( p_grid );
  if np~=size(t_field,1)  |  np~=size(vmr_field,2)
    error( 'Either T_FIELD or VMR_FIELD does not match P_GRID' );
  end
end



%- Compact to 1D, and possibly determine dt and dnls automatically
%
if Q.ATMOSPHERE_DIM == 1
  %
  t = t_field;
  if isempty(dt)
    dt = 0;
  end
  %
  vmr = vmr_field;
  if isempty(dnls)
    dnls = 0;
  end
else
  %
  t_max   = t_field;
  t_min   = t_field;
  vmr_max = vmr_field;
  vmr_min = vmr_field;
  %
  if Q.ATMOSPHERE_DIM == 3
    t_max   = max( t_max, [], 3 );
    t_min   = min( t_min, [], 3 );
    vmr_max = max( vmr_max, [], 4 );
    vmr_min = min( vmr_min, [], 4 );
  end
  if Q.ATMOSPHERE_DIM > 1
    t_max   = max( t_max, [], 2 );
    t_min   = min( t_min, [], 2 );
    vmr_max = max( vmr_max, [], 3 );
    vmr_min = min( vmr_min, [], 3 );
  end 
  %
  t   = ( t_max + t_min ) / 2;
  vmr = ( vmr_max + vmr_min ) / 2;
  %
  if isempty(dt)
    dt   = max( t_max - t_min ) / 2;
  end
  if isempty( Q.ABS_NLS )
    dnls = 0;
  elseif isempty(dnls) 
    dnls = max( max( vmr_max(Q.ABS_NLS,:)./ vmr(Q.ABS_NLS,:) ) );
  end
end



%- Fill Q fields
%
Q.ABSORPTION = 'CalcTable';
%
Q.ABS_P      = p_grid;
%
Q.ABS_T      = t;
%
if dt == 0  |  nt < 2
  Q.ABS_T_PERT = [];
else
  Q.ABS_T_PERT = linspace( -dt, dt, nt );
end  
%
Q.ABS_VMRS   = vmr;
%
if dnls == 0  |  nnls < 2  |  isempty( Q.ABS_NLS )
  Q.ABS_NLS_PERT = [];
else
  Q.ABS_NLS_PERT = linspace( 2-dnls, dnls, nnls );
end  



