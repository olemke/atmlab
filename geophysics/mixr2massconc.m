%=============================================================
% massconc = mixr2massconc( mixr, pres, temp)
%
% Calculates mass concentration from mass mixing ratio assuming
% a mixture of an atmospheric species and dry air.
%  
% Input:    mixr       mass mixing ratio vector of species [kg/kg]
%           pres       atmopsheric pressures [Pa]
%           temp       absolute temperature [K]
%
% Output:   massconc   mass concentration [kg/m3]
%
% Carlos Jimenez 2014-02-12
%=============================================================

function massconc = mixr2massconc( mixr, pres, temp )
  
%= density of dry air
rho =  airdensity( pres, temp ); % kg / m3

%= mass concentration
massconc = rho .* mixr;  % kg / m3

return


