% ARTS_PPATH   Extract propagation paths from ARTS.
%
%    This is a getaway function to calculate propagation path in ARTS.
%
%    The input arguments, beside *dim* and *vmr_field*, shall be given as
%    their ARTS WSV counterpart. For example, *z_field* shall be given as
%    a Tensor3 for 3D calculations. Note that trailing dimensions are added
%    when storing to files, and only the used dimensions ahve to be added.
%    The fields shall for 1D be given as column vectors.
%
%    The geoid radius if for 1D set to the ARTS default value. For 2D and 3D,
%    the WGS84 reference ellipsiod is used.
%
%    To activate refraction, the variables *lraytrace*, *t_field* and 
%    *vmr_field* must be given. The species list is set to only include
%    water vapour and *vmr_field* shall here be treated as a normal field 
%    (i.e. a Tensor3). The Thayer parameterization is used to calculate
%    the refractive index.
%
% FORMAT   P = arts_ppath(dim,p_grid,lat_grid,lon_grid,z_field,a_pos,a_los,[
%                   [lmax,z_ground,cb_lims,lraytrace,t_field,vmr_field])
%        
% OUT   P         The WSV *ppath*.
% IN    dim       Atmospheric dimension (1-3).
%       p_grid    As the WSV with the same name.
%       lat_grid  As the WSV with the same name.
%       lon_grid  As the WSV with the same name.
%       z_field   As the WSV with the same name.
%       r_geoid   As the WSV with the same name.
%       a_pos     As the WSV with the same name.
%       a_los     As the WSV with the same name.
% OPT   lmax      Keyword argument inside ppath_step_agenda. Default is -1.
%       z_ground  As the WSV with the same name. Default is 0 everywhere.
%       cb_lims   As the WSV cloudbox_limits. The cloud box is turned off
%                 with cb_lims=[], which is also default.
%       lraytrace Keyword argument inside ppath_step_agenda.
%       t_field   As the WSV with the same name.
%       vmr_field As the WSV with the same name, but here treated as Tensor3
%                 (see above).

% 2003-03-02   Created by Patrick Eriksson.


function P = arts_ppath(dim,p_grid,lat_grid,lon_grid,z_field,r_geoid, ...
                 a_pos,a_los,lmax,z_ground,cb_lims,lraytrace,t_field,vmr_field)


%= Check input and default values
%
min_nargin( 7, nargin );
%
if ~isscalar( dim )  |  dim < 1  |  dim > 3
  error('The atmospheric dimensionality must be a scalar between 1 and 3.');
end
%
if nargin < 8  |  isempty( lmax )
  lmax = -1;
end
%
if nargin < 9  |  isempty( z_ground )
  z_ground = 0;
end
%
if nargin < 10
  cb_lims = [];
end
%
if nargin >= 13
  do_refr = 1;
else
  do_refr = 0;
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
  Q.Z_GROUND = z_ground;
end
Q.CLOUDBOX_LIMITS = cb_lims;
Q.REFRACTION      = do_refr; 


%= Create the control file
%
qtool( cfiletemplate, cfile, Q );


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
%
xmlStore( fullfile( tmpfolder, 'r_geoid.xml' ), r_geoid, 'Matrix');


%= Handle z_ground
%
if ~isscalar( z_ground )
  xmlStore( fullfile( tmpfolder, 'z_ground.xml' ), z_ground, 'Matrix');
end


%= Cloud box
%
if ~isempty( Q.CLOUDBOX_LIMITS )
  xmlStore( fullfile( tmpfolder, 'cb_lims.xml' ), cb_lims, 'ArrayOfIndex');
end


%= Save a_pos and a_los
%
xmlStore( fullfile( tmpfolder, 'a_pos.xml' ), a_pos, 'Vector');
xmlStore( fullfile( tmpfolder, 'a_los.xml' ), a_los, 'Vector');


%= Refraction
%
if Q.REFRACTION
xmlStore( fullfile( tmpfolder, 't_field.xml' ), t_field, 'Tensor3');
A = zeros([1 size(vmr_field)]);
A(1,:,:,:) = vmr_field;
xmlStore( fullfile( tmpfolder, 'vmr_field.xml' ), A, 'Tensor4');
clear A
end



%= Execute ARTS and load the result
%
call_fmodel( ['-r20 ',cfile] );
%
P = xmlLoad( fullfile( tmpfolder, 'ppath.xml' ) );


%= Remove the temporary folder
%
delete_tmpfolder( tmpfolder );
  

return



%-----------------------------------------------------------------------------

function S = cfiletemplate

S = { ...
'Main {', ...
'output_file_formatSetAscii{}', ...
'AtmosphereSet$Q.DIM$D {}', ...
'ReadXML(p_grid){"$Q.TMPFOLDER$$Q.FILESEP$p_grid.xml"}', ...
'IF  Q.DIM > 1', ...
'ReadXML(lat_grid){"$Q.TMPFOLDER$$Q.FILESEP$lat_grid.xml"}', ...
'END', ...
'IF  Q.DIM > 2', ...
'ReadXML(lon_grid){"$Q.TMPFOLDER$$Q.FILESEP$lon_grid.xml"}', ...
'END', ...
'ReadXML(z_field){"$Q.TMPFOLDER$$Q.FILESEP$z_field.xml"}', ...
'ReadXML(r_geoid){"$Q.TMPFOLDER$$Q.FILESEP$r_geoid.xml"}', ...
'IF isscalar( Q.Z_GROUND )', ...
'MatrixSetTakingSizeFromMatrix(z_ground,r_geoid){value = $Q.Z_GROUND$}', ...
'ELSE', ...
'ReadXML(z_ground){"$Q.TMPFOLDER$$Q.FILESEP$z_ground.xml"}', ...
'END', ...
'IF isempty( Q.CLOUDBOX_LIMITS )', ...
'CloudboxOff{}', ...
'ELSE', ...
'FlagOn(cloudbox_on){}', ...
'ReadXML(cloudbox_limits){"$Q.TMPFOLDER$$Q.FILESEP$cb_lims.xml"}', ...
'END', ...
'ReadXML(a_pos){"$Q.TMPFOLDER$$Q.FILESEP$a_pos.xml"}', ...
'ReadXML(a_los){"$Q.TMPFOLDER$$Q.FILESEP$a_los.xml"}', ...
'IF Q.REFRACTION', ...
'gas_speciesSet{species = ["H2O"]}', ...
'ReadXML(t_field){"$Q.TMPFOLDER$$Q.FILESEP$t_field.xml"}', ...
'ReadXML(vmr_field){"$Q.TMPFOLDER$$Q.FILESEP$vmr_field.xml"}', ...
'AgendaSet(refr_index_agenda){', ...
'  refr_indexThayer{}', ...
'}', ...
'AgendaSet(ppath_step_agenda){', ...
'  ppath_stepRefractionEuler{', ...
'    lraytrace = 1e3', ...
'    lmax      = $Q.LMAX$', ...
'  }', ...
'}', ...
'ELSE', ...
'AgendaSet(ppath_step_agenda){', ...
'  ppath_stepGeometric{lmax = $Q.LMAX$}', ...
'}', ...
'END', ...
'ppathCalc{}', ...
'WriteXML(ppath){"$Q.TMPFOLDER$$Q.FILESEP$ppath.xml"}', ...
'}'
};
