function P = arts_ppath(dim,p_grid,lat_grid,lon_grid,z_field,a_pos,a_los,lmax,z_ground)


%= Check input and default values
%
min_nargin( 7, nargin );
%
if ~isscalar( dim )  |  dim < 1  |  dim > 3
  error('The atmospheric dimensionality must be a scalar between 1 and 3.');
end
%
if nargin < 8
  lmax = -1;
end
%
if nargin < 9
  z_ground = 0;
end



%= Create a temporary folder
%
tmpfolder = create_tmpfolder;


%= Create a name of a control file inside the temporary folder
%
cfile = fullfile( tmpfolder, 'cfile.arts' );


%= Set the fields of Q.
%
Q.DIM  = dim;
Q.LMAX = lmax;
Q.TMPFOLDER = tmpfolder;
if isscalar( z_ground )
  Q.ZGROUND = z_ground;
end


%= Create the control file
%
S = file2strs( 'arts_ppath.tmplt' );
qtool( S, cfile, Q );


%= Save grids, z_field and t_field
%
xmlStore( fullfile( tmpfolder, 'p_grid.xml' ), p_grid, 'Vector');
%
if dim > 1
 xmlStore( fullfile( tmpfolder, 'lat_grid.xml' ), lat_grid, 'Vector');
end
%
if dim > 2
 xmlStore( fullfile( tmpfolder, 'lon_grid.xml' ), lon_grid, 'Vector');
end
%
xmlStore( fullfile( tmpfolder, 'z_field.xml' ), z_field, 'Tensor3');
xmlStore( fullfile( tmpfolder, 't_field.xml' ), z_field*0+200, 'Tensor3');


%= Handle z_ground
%
if ~isscalar( z_ground )
  xmlStore( fullfile( tmpfolder, 'z_ground.xml' ), z_ground, 'Matrix');
end



%= Save a_pos and a_los
%
xmlStore( fullfile( tmpfolder, 'a_pos.xml' ), a_pos, 'Vector');
xmlStore( fullfile( tmpfolder, 'a_los.xml' ), a_los, 'Vector');



%= Execute ARTS and load the result
%
call_fmodel( ['-r20 ',cfile] );
%
P = xmlLoad( fullfile( tmpfolder, 'ppath.xml' ) );


%= Remove the temporary folder
%
delete_tmpfolder( tmpfolder );
  

return


