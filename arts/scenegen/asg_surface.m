% ASG_SURFACE   Assembles surface data
%
%    The function assenbles data for geoid radius and surface altitude.
%       ATMOSPHERE_DIM
%       R_GEOID
%       Z_SURFACE
%
%   The data are expanded to dimensionality matching ATMOSPHERE_DIM, but no
%   re-gridding is performed.
%
% FORMAT   G = asg_surface(A)
%        
% OUT   G   Assembled data.
% IN    A   Settings for arts scene generator.

% 2007-10-08   Created by Patrick Eriksson


function G = asg_surface(A)


%- Basic check of A
%
qcheck( @asg, A );




%- Geiod radius
%
R = A.R_GEOID;
%
if ~isfield( R, 'dim' )
  error( 'Gformat must be used for A.R_GEOID.' );
end
%
R.name       = 'Geoid radius';
R.data_name  = 'Radius';
R.data_unit  = 'm';
%
if ~isfield( R, 'source' )
  R.source  = 'Set by the user.';
end
%
if A.ATMOSPHERE_DIM >= 2
  if ~isfield( R, 'grid1' )
    R.grid1 = A.LAT0;
  end
  R.grid1_name = 'Latitude';
  R.grid1_unit = 'deg';
end
%
if A.ATMOSPHERE_DIM >= 3
  if ~isfield( R, 'grid2' )
    R.grid2 = A.LON0;
  end
  R.grid2_name = 'Longitude';
  R.grid2_unit = 'deg';
end
%
R.dim = A.ATMOSPHERE_DIM - 1;
%
R = orderfields( R );



%- Surface altitude
%
Z = A.Z_SURFACE;
%
if ~isfield( A.Z_SURFACE, 'dim' )
  error( 'Gformat must be used for A.Z_SURFACE.' );
end
%
Z.name       = 'Surface altitude';
Z.data_name  = 'Altitude';
Z.data_unit  = 'm';
%
if ~isfield( Z, 'source' )
  Z.source  = 'Set by the user.';
end
%
if A.ATMOSPHERE_DIM >= 2
  if ~isfield( Z, 'grid1' )
    Z.grid1 = A.LAT0;
  end
  Z.grid1_name = 'Latitude';
  Z.grid1_unit = 'deg';
end
%
if A.ATMOSPHERE_DIM >= 3
  if ~isfield( Z, 'grid2' )
    Z.grid2 = A.LON0;
  end
  Z.grid2_name = 'Longitude';
  Z.grid2_unit = 'deg';
end
%
Z.dim = A.ATMOSPHERE_DIM - 1;
%
Z = orderfields( Z );



G(1) = R;
G(2) = Z;
%
G = gf_clean( G );

  

