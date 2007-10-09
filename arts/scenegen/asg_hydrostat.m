% ASG_HYDROSTAT   Calculates hydrostatic equilibrium for ASG data
%
%    The function demands that *G* contains temperature and water vapour
%    data. These quantities are found by searching for the names
%    'Temperature' and 'Water vapour', respectively. If several items exist,
%    the first one is used.
%
%    Hydrostatic equilibrium is calculated for each geographical position
%    individually. The reference point (see *pt2z*) is taken from
%    A.HSE. The same pressure of the reference point is applied for all
%    positions, and is taken from A.HSE.P0 (should be a scalar). The
%    altitude of the reference point is described by A.HSE.Z0, which is
%    expected to be a surface described in gformat. The input can here be
%    for lower data dimension. For example, a constant altitude can be set
%    as:
%       A.HSE.Z0.name       = 'Reference altitude for HSE';
%       A.HSE.Z0.source     = mfilename;
%       A.HSE.Z0.dim        = 0;
%       A.HSE.Z0.data       = 6e3;
%       A.HSE.Z0.data_name  = 'Altitude';
%       A.HSE.Z0.data_unit  = 'm';
%
% FORMAT   G = asg_hydrostat( A, G )
%        
% OUT   G           Expanded gformat array, appended with an item holding
%                   altitudes. Name set to 'Altitude'.
% IN    A           Settings for arts scene generator.
%       G           Data (in gformat).

% 2007-10-09   Created by Patrick Eriksson

function G = asg_hydrostat( A, G )


%- Some checks of A
%
qcheck( @asg, A );
rqre_field( A.HSE, 'P0', 0 );
rqre_field( A.HSE, 'Z0', 0 );
  
  
%- Find index of temperature and H2O in G 
%
% Take first index of several found
%
it = find( strcmp( lower({G(:).name}), 'temperature' ) );
if isempty( it )
  error( 'Could not locate temperature in G.' );
end
%
iw = find( strcmp( lower({G(:).name}), 'water vapour' ) );
if isempty( iw )
  error( 'Could not locate water vapour in G.' );
end
%
it = it(1);
iw = iw(1);


%- Add new item to G
%
iz    = length(G) + 1;
G(iz) = G(it);
%
G(iz).name      = 'Altitude';
G(iz).source    = 'asg_hydrostat';
G(iz).data_name = 'Altitude';
G(iz).data_unit = 'm';


%- Latitudes
%
if G(it).dim >= 2
  lats = G(it).grid2;
else
  lats = 45;
end



%- Re-grid A.HSE.ZO
%
ind    = repmat( NaN, 1, G(it).dim );
ind(1) = 1;
Gtmplt = gf_decrease_dim( G(it), ind );
%
if A.HSE.Z0.dim < Gtmplt.dim
  A.HSE.Z0 = gf_increase_dim( A.HSE.Z0, Gtmplt.dim, Gtmplt );
end
%
Z0 = gf_regrid( A.HSE.Z0, Gtmplt, 'linear' );



%- Run HSE
%
for ilon = 1 : size(G(it).data,3)
  for ilat = 1 : size(G(it).data,2)

    G(iz).data(:,ilat,ilon) = pt2z( G(it).grid1, G(it).data(:,ilat,ilon), ...
                                                 G(iw).data(:,ilat,ilon), ...
                                A.HSE.P0, Z0.data(ilat,ilon), lats(ilat) );
    
  end
end


