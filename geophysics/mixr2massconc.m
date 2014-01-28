%=============================================================
% massconc = mixr2massconc( mixr, pres, temp)
%
% Calculates mass concentration from mass mixing ratio assuming
% a mixture of an atmospheric species and dry air.
%  

% Input:    mixr   mass mixing ratio vector of species [Kg/Kg]
%           pres   atmopsheric pressures [Pa]
%           temp   atmosphewric temperature [K]
%
% Output:   mixr   vector of VMR-values [m3/m3]
%
% Carlos Jimenez 2014
%=============================================================

function massconc = mixr2massconc( mixr, pressure, temp )
  
%= specific gas constant for dry air 
Re = 287.058; % Pa * m3 /(kg·K)

%= density of dry air
rho =  pressure ./ (Re * temp);   % Kg / m3

%= mass concentration
massconc = rho .* mixr;  % Kg / m3

return


