% ARTS_ABSTABLE_FROM_ARTS1   Created an ARTS absorption lookup table
%
%    ARTS1 is used to create an absorption lookup table for ARTS.
%
%    At this moment, settings follow Qarts1, but this will be changed
%    to use Qarts.
%
%    Needed Qarts1 fields:
%        TGS
%        LINEFORMAT
%        LINEDATA  
%        LINESHAPE  
%        LINESHAPE_FACTOR 
%        LINESHAPE_CUTOFF 
%        ABSMODELS 
%        F_MONO
%        P_ABS 
%        USE_RAW_ATMOSPHERE
%        and
%        APRIORI_PTZ
%        APRIORI_VMR
%        or
%        T_ABS
%        Z_ABS
%        VMRS
%
% FORMAT   A = arts_abstable_from_arts1( Q, dt )
%        
% OUT   A    Absorption table structure.
% IN    Q    ARTS1 settings.
%       dt   Vector with temperature perturbations.

% 2004-09-08   Created by Patrick Eriksson.


function A = arts_abstable_from_arts1( Q, dt )


%= Default values
%
dt_DEFAULT = 0;
%
set_defaults;


%=== Create temporary working folder
%
tmpfolder   = create_tmpfolder;



%=== Obtain profiles
%
% We want to make calculations for USE_RAW_ATMOSPHERE = 0.
% If this field is set to 1, we need first to extract atmosphere data.
%
rqre_bool( 'ARTS1 field USE_RAW_ATMOSPHERE', Q.USE_RAW_ATMOSPHERE );
%
if Q.USE_RAW_ATMOSPHERE
  %
  S = arts1_cfile( [], Q, {'tgs','load_atm','save_atm'}, tmpfolder );
  cfile = fullfile( tmpfolder, 'cfile.arts' );
  qtool( S, cfile, [] );
  arts( cfile, 0, 1 );
  %
  Q.USE_RAW_ATMOSPHERE = 0;
  Q.T_ABS = fullfile( tmpfolder, 't_abs.ab' );
  Q.Z_ABS = fullfile( tmpfolder, 'z_abs.ab' );
  Q.VMRS  = fullfile( tmpfolder, 'vmrs.ab' );
  t0      = read_datafile( fullfile( tmpfolder, 't_abs.ab' ), 'VECTOR');
end


%=== Create control file for ARTS1 run
%
parts = {'tgs','load_atm','f_mono','spectroscopy','abscalc','save_abs_per_tg'};
S = arts1_cfile( [], Q, parts, tmpfolder );
qtool( S, cfile, [] );
arts( cfile, 0, 1 );



%=== Create absorption table
%
A.species           = Q.TGS;
A.nonlinear_species = {};
A.f_grid            = vec2col( arts1_get( Q.F_MONO, 'VECTOR' ) );
A.p_grid            = vec2col( arts1_get( Q.P_ABS, 'VECTOR' ) );
A.vmrs_ref          = arts1_get( Q.VMRS, 'MATRIX' );
A.t_ref             = t0;
A.t_pert            = dt;
A.nls_pert          = 0;
%
nt = length(dt);
%
A.xsec = zeros( nt, length(A.species), length(A.f_grid), length(A.p_grid) );
%
for i = 1 : nt
  %
  t = t0 + dt(i);
  write_datafile( fullfile( tmpfolder, 't_abs.ab' ), t, 'VECTOR' );
  %
  arts( cfile, 0, 1 );
  %
  X = read_datafile( fullfile( tmpfolder, 'abs_per_tg.ab' ), 'AOMATRIX');
  %
  for j = 1 : length(A.species)
    A.xsec(i,j,:,:) = X{j}; 
  end
  %
end
%
A.species           = Q.TGS;
A.nonlinear_species = {};
A.f_grid            = vec2col( arts1_get( Q.F_MONO, 'VECTOR' ) );
A.p_grid            = vec2col( arts1_get( Q.P_ABS, 'VECTOR' ) );
A.vmrs_ref          = arts1_get( Q.VMRS, 'MATRIX' );
A.t_ref             = t0;
A.t_pert            = dt;
A.nls_pert          = 0;



%=== Delete working folder
%
delete_tmpfolder( tmpfolder );
