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
parts = {'tgs','load_atm','f_mono','spectroscopy'};
S = arts1_cfile( [], Q, parts, tmpfolder );
qtool( S, cfile, [] );
arts( cfile, 0, 1 );



%=== Create absorption table
%
A.species           = Q.TGS;
A.nonlinear_species = {};
A.f_grid            = f;
A.p_grid            = p;
A.vmrs_ref          = vmrs;
A.t_ref             = t0;
A.t_pert            = dt;
A.nls_pert          = 0;
%
nt = length(dt);
%
for i = 1 : nt
  %
  t = t0 + dt(i);
  write_datafile( fullfile( tmpfolder, 't_abs.aa' ), t, 'VECTOR' );
  %
  arts( cfile, 0, 1 );
  %
  A.xsec = read_datafile( fullfile( tmpfolder, 'abs_per_tg.aa' ), 'AOMATRIX');
  %
end



%=== Delete working folder
%
delete_tmpfolder( tmpfolder );
