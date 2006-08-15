% ARTS_ABSTABLE_FROM_ARTS1   Creates an ARTS absorption lookup table
%
%    ARTS1 is used to generate the absorption lookup table. Spectrocopic
%    settings follows Qarts1. See needed fields below.
%
%    Gas species, grids and atmospheric state are specified following Qarts.
%    Needed fields are listed below. The frequency and pressure grid in the
%    absorption table will be Q.F_GRID and Q.P_GRID. If the atmospheric
%    dimension, the VMR reference state is taken as a mean over all latitude
%    and longitude profiles.
%
%    Needed Qarts fields:
%       ABS_SPECIES
%       P_GRID
%       F_GRID
%       ATMOSPHERE_DIM
%       USE_RAW_ATMOSPHERE 
%       atmospheric fields following value of USE_RAW_ATMOSPHERE  
%
%    Needed Qarts1 fields:
%       LINEFORMAT
%       LINEDATA  
%       LINESHAPE  
%       LINESHAPE_FACTOR 
%       LINESHAPE_CUTOFF 
%       ABSMODELS 
%
% FORMAT   A = arts_abstable_from_arts1( Q, Q1, dt )
%        
% OUT   A    Absorption table structure.
% IN    Q    ARTS settings.
% IN    Q1   ARTS1 settings.
%       dt   Vector with temperature perturbations. Default is 0.

% 2004-09-08   Created by Patrick Eriksson.


function A = arts_abstable_from_arts1( Q, Q1, dt )


%= Default values
%
dt_DEFAULT = 0;
%
set_defaults;


%=== Create temporary working folder
%
tmpfolder   = create_tmpfolder;


%=== Obtain profiles through ARTS
%
rqre_bool( 'ARTS field USE_RAW_ATMOSPHERE', Q.USE_RAW_ATMOSPHERE );
%
p_grid   = qarts_get( Q.P_GRID );
%
if Q.USE_RAW_ATMOSPHERE
  %
  [t_field,z_field,vmr_field] = arts_get_atmfields( Q ); 
else
  t_field   = qarts_get( Q.T_FIELD );
  z_field   = qarts_get( Q.Z_FIELD );
  vmr_field = qarts_get( Q.VMR_FIELD );
  %
  np = length( p_grid );
  if np~=size(t_field,1)  |  np~=size(z_field,1)  |  np~=size(vmr_field,2)
    error( 'Either T_FIELD, Z_FIELD or VMR_FIELD does not match P_GRID' );
  end
end


%=== Compact to 1D
%
if Q.ATMOSPHERE_DIM == 3
 t_field = mean( t_field, 3 );
 z_field = mean( z_field, 3 );
 vmr_field = mean( vmr_field, 4 );
end
if Q.ATMOSPHERE_DIM > 1
 t_field = mean( t_field, 2 );
 z_field = mean( z_field, 2 );
 vmr_field = mean( vmr_field, 3 );
end


%=== Assign obtained fields corresponding Qarts1 fields
%
Q1.USE_RAW_ATMOSPHERE = 0;
Q1.P_ABS = p_grid;
Q1.Z_ABS = z_field;
Q1.VMRS  = vmr_field;


%=== Copy some fields from Q to Q1
%
Q1.TGS    = Q.ABS_SPECIES;
if ischar(  Q.F_GRID )
  Q1.F_MONO = xmlLoad( Q.F_GRID );
else
  Q1.F_MONO = Q.F_GRID;
end


%=== Define control file for ARTS1 run
%
cfile = fullfile( tmpfolder, 'cfile.arts' );
parts = {'tgs','load_atm','pf_grids','spectroscopy','calc_abs',...
         'save_abs_per_tg'};


%=== Create absorption table
%
A.species           = Q.ABS_SPECIES;
A.nonlinear_species = {};
A.f_grid            = vec2col( qarts_get( Q.F_GRID ) );
A.p_grid            = vec2col( qarts_get( Q.P_GRID ) );
A.vmrs_ref          = vmr_field;
A.t_ref             = vec2col( t_field );
A.t_pert            = dt;
A.nls_pert          = [];
%
nt = length(dt);
nf = length(A.f_grid);
%
A.xsec = zeros( nt, length(A.species), nf, length(A.p_grid) );
%
for i = 1 : nt
  %
  Q1.T_ABS = t_field + dt(i);
  %
  S = qarts12cfile( Q1, parts, tmpfolder );
  qtool( S, cfile, [] );
  arts1( cfile );
  %
  X = arts1_loadfile( tmpfolder, 'abs_per_tg', 'AOMATRIX' );
  %
  for j = 1 : length(A.species)
    A.xsec(i,j,:,:) = X{j} ./ ...
              repmat( vmr2nd( A.vmrs_ref(j,:), A.p_grid, Q1.T_ABS )', nf, 1 );
  end
  %
end


%=== Delete working folder
%
delete_tmpfolder( tmpfolder );
