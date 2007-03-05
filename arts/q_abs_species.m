% Q_ABS_SPECIES   Adds a gas species to the Q and SX structures
%
%    The method modifies the fields ABS_SPECIES and J.ABS_SPECIES.
%    The field ATMOSPHERE_DIM must be set.
%
%    Example on adding a species, without jacobians:
%       Q = q_abs_species( Q, {'O2-PWR93'} );
%
%    With jacobians:
%       [Q,SX] = q_gas_species( Q,{'H2O-PWR98'},1,SX,D,p_grid,'vmr');
%
% FORMAT   [Q,SX] = q_abs_species( Q, tags, do_j, SX, D, grids [, unit, 
%                                                            method, dx )
%        
% OUT   Q          Modified Q structure.
%       SX         Modified SX structure.
% IN    Q          Original Q structure.
%       tags       Tag names as cell string array.
% OPT   do_j       Flag to do jacobians. Default is 0. If 0, the variables
%                  below are not needed.
%       SX         Original SX structure.
%       D          Covariance definition. See *arts_covmat*.
%       grids      Retrieval grids, as an ArrayOfVector. 
%       unit       Retrieval unit ('rel', 'vmr' or 'nd'). Default is 'rel'.
%       method     Calculation method ('analytical' or 'perturbation').
%                  Default is 'analytical'.
%       dx         Size of perturbations. Ignored if *method* = 'analytical'.
%                  Default is 0.

% 2005-06-23   Created by Patrick Eriksson.


function [Q,SX] = q_abs_species(Q,tags,do_j,SX,D,grids,unit,method,dx)


if nargin < 2  |  ( nargin > 2  &  nargin < 5 )
  error('Number of input arguments must = 2 or >= 6.');
end

%= Set defaults
%
do_j_DEFAULT   = 0;
unit_DEFAULT   = 'rel';
method_DEFAULT = 'analytical';
dx_DEFAULT     = 0;
%
set_defaults;


%= Check input
%
rqre_datatype( 'cellstr', tags );
rqre_bool( 'argument *do_j*', do_j );


i = length(Q.ABS_SPECIES) + 1;


for j = 1 : length(tags)
  Q.ABS_SPECIES{i}{j} = tags{j};
end


if isstruct( Q.J )
  Q.J.ABS_SPECIES(i).DO = do_j;  
end


if do_j
  
  Q.J.ABS_SPECIES(i).UNIT   = unit;
  Q.J.ABS_SPECIES(i).METHOD = method;
  Q.J.ABS_SPECIES(i).DX     = dx;
  Q.J.ABS_SPECIES(i).GRID1  = grids{1};

  if Q.ATMOSPHERE_DIM >= 2
    Q.J.ABS_SPECIES(i).GRID2 = grids{2};

    if Q.ATMOSPHERE_DIM >= 3
      Q.J.ABS_SPECIES(i).GRID3 = grids{3};
    end
  end

  SX.ABS_SPECIES{i} = D;
end