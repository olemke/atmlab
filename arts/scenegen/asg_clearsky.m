% ASG_CLEARSKY   Assembles "clear sky" data
%
%    The function loads temperature and gas species profile data. The
%    following ASG (main/sub) fields are considered:
%       ATMOSPHERE_DIM
%       LAT0
%       LON0
%       T.SOURCE
%       ABS_SPECIES(:).NAME
%       ABS_SPECIES(:).SOURCE
%       ABS_SPECIES(:).TAG
%
%   The data are expanded to dimensionality given by ATMOSPHERE_DIM, but no
%   re-gridding is performed.
%
% FORMAT   G = asg_clearsky(A)
%        
% OUT   G   Assembled data.
% IN    A   Settings for arts scene generator.

% 2007-10-08   Created by Patrick Eriksson


function G = asg_clearsky(A)


%- Basic check of A
%
qcheck( @asg, A );



%--- Load data ----------------------------------------------------------------

%- Temperature
%
rqre_field( A.T, 'SOURCE', 0 );
%
source = A.T.SOURCE;
%
if ischar( source )
  if ~exist( source, 'file' )
    fprintf('File: %s\n', source );
    error( 'Could not find input file (see above) for temperature.' );
  end
else
  if ~isstruct(source)  |  ~isfield(source.dim )
    fprintf('Doing: Temperature\n' );
    error( 'If data not given as a file, the gformat must be used.' );
  end
end
%
G(1) = gfxmlin_GriddedField3( source, 'Temperature', 't' );



%- Absorption species
%
rqre_field( A.ABS_SPECIES, 'NAME', 0 );
rqre_field( A.ABS_SPECIES, 'SOURCE', 0 );
rqre_field( A.ABS_SPECIES, 'TAG', 0 );
%
for is = 1 : length( A.ABS_SPECIES )
  
  %- Load data (either from file or already in gformat)
  %
  source = A.ABS_SPECIES(is).SOURCE;
  %
  if ischar( source )
    if ~exist( source, 'file' )
      fprintf('File: %s\n', source );
      error( 'Could not find input file (see above) for %s.', ...
             A.ABS_SPECIES(is).NAME );
    end
  else
    if ~isstruct(source)  |  ~isfield(source.dim )
      fprintf('Doing: %s\n', A.ABS_SPECIES(is).NAME );
      error( 'If data not given as a file, the gformat must be used.' );
    end
  end
  %
  G(end+1) = gfxmlin_GriddedField3( source, A.ABS_SPECIES(is).NAME, 'vmr' );
  %
end



%--- Expand (and cut) to A.GENERAL_DIM ---------------------------------------
%
% Name and unit for lat and lon grids added by gfxmlin_GriddedField3.
%
for ig = 1 : length(G)
  %
  for id = G(ig).dim+1 : A.ATMOSPHERE_DIM
    switch id
     case 2
      G(ig).grid2 = A.LAT0;
     case 3
      G(ig).grid3 = A.LON0;
    end
  end
  %
  G(ig).dim = A.ATMOSPHERE_DIM;
  %
end
%
G = gf_clean( G );
  

