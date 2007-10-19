% ASG_HYDROSTAT   Calculates hydrostatic equilibrium for ASG data
%
%    The function demands that *G* contains temperature and water vapour
%    data. These quantities are found by searching for the names
%    'Temperature' and 'Water vapour', respectively. If several items exist,
%    the first one is used.
%
%    The G array must further contain an item for altitudes. The field NAME
%    is expected to start as 'Altitude'. This is item of G can be empty,
%    beside the field SPCFC, where settings for this functions is stored,
%    as described below.
%
%    Hydrostatic equilibrium is calculated for each geographical position
%    individually. The reference point (see *pt2z*) is taken from
%    G.SPCFC. The same pressure of the reference point is applied for all
%    positions, and is taken from G.SPCFC.P0 (should be a scalar). The
%    altitude of the reference point is described by G.SPCFC.Z0, which is
%    expected to be a surface described in gformat. The input can here be
%    for lower data dimension. For example, a constant altitude can be set
%    as:
%       G(i).SPCFC.Z0        = gf_set( D, asgG, [], 0, [], ...
%                                     'Altitude at P0', 'Altitude', 'm' );
%
% FORMAT   G = asg_hydrostat( D, G, Q )
%        
% OUT   G   Expanded gformat array, appended with an item holding
%           altitudes. Name set to 'Altitude'.
% IN    A   Settings for arts scene generator.
%       G   Data (in gformat).
%       Q   Qarts setting structure.

% 2007-10-09   Created by Patrick Eriksson

function G = asg_hydrostat( D, G, Q )


%- Locate position of 'Altitude field'
%
% Take first index if several found
%
iz = min( find( strncmp( lower({G.NAME}), 'altitude', 8 ) ) );
%
if isempty( iz )
  error( 'Could not locate any altitude data in G.' );
end
%
rqre_field( G(iz).SPCFC, 'P0', 0 );
rqre_field( G(iz).SPCFC, 'Z0', 0 );
qcheck( @asgG, G(iz).SPCFC.Z0 );


%- Locate also position of temperature and water vapour
%
it = min( find( strncmp( lower({G(:).NAME}), 'temperature', 11 ) ) );
if isempty( it )
  error( 'Could not locate temperature in G.' );
end
%
iw = min( find( strcmp( lower({G(:).NAME}), 'water vapour' ) ) );
if isempty( iw )
  error( 'Could not locate water vapour in G.' );
end


%- Set string fields
%
G(iz).NAME      = 'Altitude field';
G(iz).SOURCE    = 'asg_hydrostat';
G(iz).DATA_NAME = 'Altitude';
G(iz).DATA_UNIT = 'm';


%- Latitudes
%
if any( G(it).DIMS == 2 )
  lats = G(it).GRID2;
else
  lats = 45;
end


%- Re-grid SPCFC.ZO
%
Z0 = asg_dimadd( D, G(iz).SPCFC.Z0, Q );
Z0 = asg_regrid( D, Z0, Q );


%- Run HSE
%
G(iz).GRID1 = G(it).GRID1; 
G(iz).GRID2 = G(it).GRID2; 
G(iz).GRID3 = G(it).GRID3; 
%
for ilon = 1 : size(G(it).DATA,3)
  for ilat = 1 : size(G(it).DATA,2)

    G(iz).DATA(:,ilat,ilon) = pt2z( G(it).GRID1, G(it).DATA(:,ilat,ilon), ...
                                                 G(iw).DATA(:,ilat,ilon), ...
                             G(iz).SPCFC.P0, Z0.DATA(ilat,ilon), lats(ilat) );
    
  end
end


