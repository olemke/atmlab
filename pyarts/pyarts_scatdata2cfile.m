function pyarts_scatdata2cfile(Q,fid)


for i = 1 : length( Q.SCAT_FILES )

  fprintf( fid, '\nParticleTypeAdd{\n' );
  fprintf( fid, '   filename_scat_data = "%s"\n', Q.SCAT_FILES{i} );
  fprintf( fid, '   filename_pnd_field = ""\n}\n' );

end

  
fprintf( fid, '\nReadXML( pnd_field_raw ){\n' );
fprintf( fid, '   filename = "%s"\n}\n', Q.PND_FIELD );
