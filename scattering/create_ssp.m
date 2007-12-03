% CREATE_SSP create single scattering properties data and is
%          an interface to mie_scat_data
%
%   OUT     ssp      single scattering data
%   IN      shape    particle shape (only valid is sphere so far)
%   IN      f_grid   frequency grid [Hz]
%   IN      r        particle size [m]
%   OPT
%   IN      T_grid   temperature grid [K]
%   IN      rfr_ind  refractive indices, matrix with dimension
%                    [f_grid, T_grid]
%   IN      za_grid  scattering angle grid []
%   IN      aa_grid  scattering angle grid []
%
% 2007-12-03   Created by Bengt Rydberg 

function ssp=create_ssp(shape,f_grid,r,  T_grid, rfr_index, za_grid, aa_grid)

shape_DEFAULT   = 'sphere';
T_grid_DEFAULT  = [170 200 273];
za_grid_DEFAULT = [0:10:180];
aa_grid_DEFAULT = [];
rfr_index_DEFAULT =[];
set_defaults;

if isempty(rfr_index)
   for i=1:length(f_grid)
     for j=1:length(T_grid)
       rfr_index(i,j) = sqrt(eps_ice_liebe93( f_grid(i), T_grid(j) ));
     end
   end
end

if strcmp(shape,'sphere')
   for i=1:length(r)
     ssp(i) = mie_scat_data(f_grid, T_grid, rfr_index, za_grid, r(i));
   end
else
   error('sphere is the only valid shape option.')
end
