function A = arts_abstable_from_arts1( S, f, p, dt )


%= Default values
%
dt_DEFAULT = 0;
%
set_defaults;


%=== Create temporary working folder
%
tmpfolder   = create_tmpfolder;
S.TMPFOLDER = tmpfolder;


%=== Add path to AMI/arts
%
atmlab( 'require', {'AMI_PATH'} );
amipath = atmlab( 'AMI_PATH' );
addpath( fullfile( amipath, 'arts' ), '-end' );


%=== Create tag string
%
S.TGSSTRING = arts_tgs_cnvrt( S.TGS );


%=== Write *p* and *f* to files
%
write_datafile( fullfile( tmpfolder, 'p_abs.aa' ), p, 'VECTOR' );
write_datafile( fullfile( tmpfolder, 'f_mono.aa' ), f, 'VECTOR' );


%=== Obtain profiles
%
cfile = fullfile( tmpfolder, 'cfile.arts' );
Tfile = file2strs( 'prof.tmplt' );
qtool( Tfile, cfile, S );
%
arts( cfile, 0, 1 );
%
t0   = read_datafile( fullfile( tmpfolder, 't_abs.aa' ), 'VECTOR');
vmrs = read_datafile( fullfile( tmpfolder, 'vmrs.aa' ), 'MATRIX');


%=== Create control file for ARTS1 run
%
Cfile = file2strs( S.ABSMODELS );
Tfile = file2strs( 'abs.tmplt' );
qtool( [{'cont_descriptionInit{}'} Cfile Tfile], cfile, S );


%=== Create absorption table
%
A.species           = S.TGS;
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


%=== Recreate path
%
rmpath( fullfile( amipath, 'arts' ) );



%=== Delete working folder
%
delete_tmpfolder( tmpfolder );
