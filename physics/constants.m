% constants(name)
%
%    This function returns physical constants. It gives an 
%    error message, if the constant is not defined.
%
% FORMAT   const = constants(name);
%        
% OUT   const   Value of the constant.  
% IN    name    Name of the constant.

% 2002-12-12   Created by Claudia Emde.


function const = constants(name)

switch name
case ('PLANCK_CONST')
    const = 6.626180e-34;
case ('BOLTZMANN_CONST')
    const = 1.380662e-23;
case ('SPEED_OF_LIGHT')
    const = 2.99792458e8;
otherwise
    error(strcat('Unknown constant: ', name))
end      