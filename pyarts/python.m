function python( folder, cfile )

[s,pwd0] = system( 'pwd' );

system( ['cd ', folder, ';python ', cfile, ';cd ', pwd0 ] );

