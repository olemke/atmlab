% constants(name)
%
%    This function returns physical constants. It gives an 
%    error message, if the constant is not defined.
%
%    The following constants are defined:
%        
%       BOLTZMANN_CONST
%       PLANCK_CONST  
%       SPEED_OF_LIGHT
%
% FORMAT   const = constants(name);
%        
% OUT   const   Value of the constant.  
% IN    name    Name of the constant.

% 2002-12-12   Created by Claudia Emde.


function const = constants(name)

% You can add new constants here. The names should be self-explanatory
% and the constants are sorted alphabetically. You also have to add the 
% name of the constant in the list above, so that the help command 
% gives out a complete list of constants.

switch name
case ('BOLTZMANN_CONST')
    const = 1.380662e-23;
case ('PLANCK_CONST')
    const = 6.626180e-34;
case ('SPEED_OF_LIGHT')
    const = 2.99792458e8;
otherwise
    error(strcat('Unknown constant: ', name))
end      