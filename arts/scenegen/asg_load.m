% Used Q fields:
%    ATMOSPHERE_DIM


function G = asg_load(S,G)

  
%- Default values
%
G_DEFAULT = [];
%
set_defaults;



%--- Start part ---------------------------------------------------------------

%- Basic checks of input
%
rqre_field( S, 'T', 0 );
rqre_field( S, 'ABS_SPECIES', 0 );
%rqre_field( S, 'R_GEOID', 0 );
%rqre_field( S, 'Z_SURFACE', 0 );
%
if ~isempty(G)  &  ( ~isstruct(G)  |  ~isfield(G(1).dim) )
  error( 'The input variable *G* must be in the gformat.' );
end

%- Check S.GENERAL
%
rqre_field( S.GENERAL, 'DIM', 0 );
rqre_scalar( 'S.GENERAL.DIM', S.GENERAL.DIM, 1, 3 );
if S.GENERAL.DIM >= 2
  rqre_field( S.GENERAL, 'LAT0', 0 );
end
if S.GENERAL.DIM == 3
  rqre_field( S.GENERAL, 'LON0', 0 );
end



%--- Load data ----------------------------------------------------------------

%- Temperature
%
rqre_field( S.T, 'SOURCE', 0 );
%
source = S.T.SOURCE;
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
G = gfxmlin_GriddedField3( source, 'Temperature', 'vmr' );



%- Absorption species
%
rqre_field( S.ABS_SPECIES, 'NAME', 0 );
rqre_field( S.ABS_SPECIES, 'SOURCE', 0 );
rqre_field( S.ABS_SPECIES, 'TAG', 0 );
%
for is = 1 : length( S.ABS_SPECIES )
  
  %- Load data (either from file or already in gformat)
  %
  source = S.ABS_SPECIES(is).SOURCE;
  %
  if ischar( source )
    if ~exist( source, 'file' )
      fprintf('File: %s\n', source );
      error( 'Could not find input file (see above) for %s.', ...
             S.ABS_SPECIES(is).NAME );
    end
  else
    if ~isstruct(source)  |  ~isfield(source.dim )
      fprintf('Doing: %s\n', S.ABS_SPECIES(is).NAME );
      error( 'If data not given as a file, the gformat must be used.' );
    end
  end
  %
  G(end+1) = gfxmlin_GriddedField3( source, S.ABS_SPECIES(is).NAME, 'vmr' );
  %
end



%--- Expand to S.GENERAL_DIM (where necessary) ---------------------------------

% Name and unit for lat and lon grids added by gfxmlin_GriddedField3.
% Lat and lon positions are taken from S.GENERAL

for ig = 1 : length(G)
  %
  G(ig).dim = S.GENERAL.DIM;
  %
  for id = G(ig).dim : S.GENERAL.DIM
    switch id
     case 2
      G(ig).grid2      = S.GENERAL.LAT0;
     case 3
      G(ig).grid2      = S.GENERAL.LON0;
    end
  end
end
  
  

  

