% Q_GAS_SPECIES   Adds a gas species to a Qarts structure
%
%    The method modifies the fields GAS_SPECIES and GAS_SPECIES_JAC.
%    The field ATMOSPHERE_DIM must be set.
%
%    Example on adding a species, without jacobians:
%       Q = q_gas_species( Q, {'O2-PWR93'} );
%
%    With jacobians:
%       Q = q_gas_species( Q,{'H2O-PWR98'},1,'rel','analytical',NaN,p_grid);
%
% FORMAT   Q = q_gas_species( Q, tags, [ do_jac, unit, method, dx, p_grid, ...
%                                                        lat_grid, lon_grid ] )
%        
% OUT   Q          Modified Q structure.
% IN    Q          Original Q structure.
%       tags       Tag names as cell string array.
% OPT   do_jacs    Flag to do jacobians. Default is 0. If 0, the variables
%                  below are not needed.
%       unit       Retrieval unit ('rel', 'vmr' or 'nd')
%       method     Calculation method ('analytical' or 'perturbation')
%       dx         Size of perturbations. Ignored if *method* = 'analytical'
%       p_grid     Pressure retrieval grid.
%       lat_grid   Latitude retrieval grid. Ignored if ATMOSPHERE_DIM < 2.
%       lon_grid   Longitude retrieval grid. Ignored if ATMOSPHERE_DIM < 3.

% 2005-06-23   Created by Patrick Eriksson.


function Q = q_gas_species(...
                        Q,tags,do_jac,unit,method,dx,p_grid,lat_grid,lon_grid)


%= Set defaults
%
if nargin < 3
  do_jac = 0;
end


%= Check input
%
rqre_datatype( 'cellstr', tags );
rqre_bool( 'argument *do_jac*', do_jac );


%= Checl length of fields to set
%
i = length(Q.GAS_SPECIES);
%
if length(Q.GAS_SPECIES_JAC) ~= i
  error('Length of fields GAS_SPECIES and GAS_SPECIES_JAC must be identical.');
end


i = i + 1;


for j = 1 : length(tags)
  Q.GAS_SPECIES{i}{j} = tags{j};
end


Q.GAS_SPECIES_JAC{i}.DO = do_jac;


if do_jac

  Q.GAS_SPECIES_JAC{1}.UNIT   = unit;
  Q.GAS_SPECIES_JAC{i}.METHOD = method;
  Q.GAS_SPECIES_JAC{i}.DX     = dx;
  Q.GAS_SPECIES_JAC{1}.P_GRID = p_grid;

  if Q.ATMOSPHERE_DIM >= 2
    Q.GAS_SPECIES_JAC{1}.LAT_GRID = lat_grid;

    if Q.ATMOSPHERE_DIM >= 3
      Q.GAS_SPECIES_JAC{1}.LON_GRID = lon_grid;
    end
  end
end