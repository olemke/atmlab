% TEST_ARTS_JACOBIANS
%
%    Runs a set of tests to check the implementation of Jacobians.
%
%    No options here, all changes must be done in code.
%
% FORMAT   test_arts_jacobians

% 2005-06-16   Created by Patrick Eriksson


function test_arts_jacobians


%= Make quite
%
verbosity = atmlab( 'VERBOSITY' );
artsverb  = atmlab( 'FMODEL_VERBOSITY' );
%
atmlab( 'VERBOSITY', 0 );
atmlab( 'FMODEL_VERBOSITY', 0 );


%= Test consistency between 1-3D
%
Q = qarts_demo2( 30e3, 3 );
%
Q.J_DO    = 1;
Q.J       = qartsJacobian;
%
Q.J.ABS_SPECIES(1).DO     = 1;
Q.J.ABS_SPECIES(1).UNIT   = 'vmr';
Q.J.ABS_SPECIES(1).METHOD = 'analytical';
Q.J.ABS_SPECIES(1).GRID1  = z2p_simple( [0:4e3:100e3] );
Q.J.ABS_SPECIES(1).GRID2  = -4:4;
Q.J.ABS_SPECIES(1).GRID3  = -4:4;
%
Q.J.ABS_SPECIES(2)        = Q.J.ABS_SPECIES(1);
Q.J.ABS_SPECIES(2).UNIT   = 'rel';

% 3D
[y3,ydata,dy,J3,jq,ji3]   = arts_y( Q );
  
% 2D
Q.ATMOSPHERE_DIM          = 2;
Q.LON_GRID                = [];
Q.R_GEOID                 = Q.R_GEOID(:,1);
Q.SENSOR_LOS              = Q.SENSOR_LOS(1);
Q.SENSOR_POS              = Q.SENSOR_POS(1:2);
Q.T_FIELD                 = Q.T_FIELD(:,:,1);
Q.VMR_FIELD               = Q.VMR_FIELD(:,:,:,1);
Q.Z_FIELD                 = Q.Z_FIELD(:,:,1);
Q.Z_SURFACE               = Q.Z_SURFACE(:,1);
%
[y2,ydata,dy,J2,jq,ji2]   = arts_y( Q );

% 1D
Q.ATMOSPHERE_DIM          = 1;
Q.LAT_GRID                = [];
Q.R_GEOID                 = Q.R_GEOID(1);
Q.SENSOR_POS              = Q.SENSOR_POS(1);
Q.T_FIELD                 = Q.T_FIELD(:,1);
Q.VMR_FIELD               = Q.VMR_FIELD(:,:,1);
Q.Z_FIELD                 = Q.Z_FIELD(:,1);
Q.Z_SURFACE               = Q.Z_SURFACE(1);
%
[y1,ydata,dy,J1,jq,ji1]   = arts_y( Q );

if max( abs( y1-y2 ) ) > 1e-3
  error( 'Inconsistency for *y* between 1D and 2D.' )
end
if max( abs( y1-y3 ) ) > 1e-3
  error( 'Inconsistency for *y* between 1D and 3D.' )
end
if max( abs( y2-y3 ) ) > 1e-3
  error( 'Inconsistency for *y* between 2D and 3D.' )
end

y11 = J1(:,ji1{1}{1}:ji1{1}{2}) * repmat( 1e-9, ji1{1}{2}-ji1{1}{1}+1, 1 );
y21 = J2(:,ji2{1}{1}:ji2{1}{2}) * repmat( 1e-9, ji2{1}{2}-ji1{1}{1}+1, 1 );
y31 = J3(:,ji3{1}{1}:ji3{1}{2}) * repmat( 1e-9, ji3{1}{2}-ji1{1}{1}+1, 1 );

y12 = J1(:,ji1{2}{1}:ji1{2}{2}) * repmat( 1, ji1{2}{2}-ji1{2}{1}+1, 1 );
y22 = J2(:,ji2{2}{1}:ji2{2}{2}) * repmat( 1, ji2{2}{2}-ji2{2}{1}+1, 1 );
y32 = J3(:,ji3{2}{1}:ji3{2}{2}) * repmat( 1, ji3{2}{2}-ji3{2}{1}+1, 1 );

if max( abs( y11-y21 ) ) > 1e-2
  error( 'Inconsistency for jacobian vmr calculations between 1D and 2D.' )
end
if max( abs( y11-y31 ) ) > 1e-2
  error( 'Inconsistency for jacobian vmr calculations between 1D and 3D.' )
end
if max( abs( y21-y31 ) ) > 1e-2
  error( 'Inconsistency for jacobian vmr calculations between 2D and 3D.' )
end

if max( abs( y12-y22 ) ) > 1e-3
  error( 'Inconsistency for jacobian rel calculations between 1D and 2D.' )
end
if max( abs( y12-y32 ) ) > 1e-3
  error( 'Inconsistency for jacobian rel calculations between 1D and 3D.' )
end
if max( abs( y22-y32 ) ) > 1e-3
  error( 'Inconsistency for jacobian rel calculations between 2D and 3D.' )
end


% Disturb vmr_field and test for 1D
%
Q.VMR_FIELD(1,:) = 5e-11 + Q.VMR_FIELD(1,:);
Q.VMR_FIELD(2,:) = 1.1 * Q.VMR_FIELD(2,:);
%
y1d              = arts_y( Q );

y11 = J1(:,ji1{1}{1}:ji1{1}{2}) * repmat( 5e-11, ji1{1}{2}-ji1{1}{1}+1, 1 );
y12 = J1(:,ji1{2}{1}:ji1{2}{2}) * repmat( 0.1, ji1{2}{2}-ji1{2}{1}+1, 1 );

if max( abs( (y1d-y1)./(y11+y12) - 1 ) ) > 0.01
  error( 'Inconsistency with jacobians found when disturbing *y*.' )
end



%= Reset verbosities
%
atmlab( 'VERBOSITY', verbosity );
atmlab( 'FMODEL_VERBOSITY', artsverb );


return




%----------------------------------------------------------------------------

function   cmpr_J( Ja, Jp, type );
  %
  d = full( max(max(abs( Jp-Ja ))) / max(max(abs(Ja))) ); 
  fprintf( 'Rel. difference between anal. and pert. jacobians : %.3f\n', d );
  if  d > 0.02
    keyboard
    error( sprintf('Inconsistency found for %s', type ) );
  else
    fprintf( '%s : OK\n', type );
  end
  %
return


%----------------------------------------------------------------------------

