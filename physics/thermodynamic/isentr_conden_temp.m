function Tc = isentr_conden_temp(T, p, w) 
% ISENTR_CONDEN_TEMP    isentropic condensation temperature Tc
%
%    isentropic condensation temperature (Tc) is the temperature
%    at which saturation is reached when moist air is cooled
%    adiabatically with w held constant.
%
% FORMAT    Tc = isentr_conden_temp(T, p, w)
%        
% OUT   Tc  isentropic condensation temperature [K]
% IN    w   mixing ratio [], it is a scalar
%       p   pressure [kPa],  it is a scalar
%       T   temperature [K],  it is a scalar
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%
% 2009-06-08   Created by Isaac Moradi.

A = 2.53e8; % in kPa
B = 5.42e3; % in K
cp=constants('SPECIFIC_HEAT_CONST_PRES');
cv=constants('SPECIFIC_HEAT_CONST_VOL');
k = (cp - cv) / cp; % c is specific heat at constant pressure and volume
eps = constants('GAS_CONST_DRY_AIR') / ...
    constants('GAS_CONST_WATER_VAPOR'); 
T1 = T;
Tc = T1;
Tc1 = Tc - 10;
inv_k = 1 ./ k;
var1 = A .* eps ./ (w .* p);

while abs(Tc1 - Tc) > 0.5
    T1 = T1 - 0.5;
    Tc1 = Tc;               
    var2 = T ./ T1;
    Tc = B ./ log(var1 .* power(var2, inv_k));
end
        
