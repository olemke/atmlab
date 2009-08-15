function Td = dew_point(w, p)
% DEW_POINT     Dewpoint temperature Td
%       
%       dewpoint or dewpoint temperature is the temperature to
%       which a given air parcel must be cooled at constant
%       pressure and constant water vapor content in order
%       for saturation to occur.
%       (http://amsglossary.allenpress.com/glossary/search?id=dewpoint1)
%
% FORMAT    Td = dew_point(w, p)
%        
% OUT   Td  dewpoint temperature [K],
% IN    w   mixing ratio [],  it can be a scalar or a vector
%       p   pressure [kPa],  it can be a scalar or a vector
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%
% 2009-08-15   Created by Isaac Moradi.

A = 2.53e8; % kPa
B = 5.42e3; % K
eps = constants('GAS_CONST_DRY_AIR') / ...
    constants('GAS_CONST_WATER_VAPOR');  
Td = B ./ log(A .* eps ./ (w .* p));            

       