function Q = pyarts_boxcloud_create(Q,folder)


S = file2strs( 'boxcloud.py.tmplt' );

cfile = fullfile( folder, 'boxcloud.py' );

qtool( S, cfile, Q );

python( folder, cfile )

Q.PND_FIELD = fullfile( folder, 'pnd_field.xml' );

Q.SCAT_FILES = xmlLoad( fullfile( folder, 'scat_files.xml' ) );