% CONSTANTS   Phyiscal and math constants
%
%    This function returns physical constants. It gives an 
%    error message, if the constant is not defined.
%
%    The following constants are defined:
%        
%       SPEED_OF_LIGHT
%       BOLTZMANN_CONST
%       PLANCK_CONST  
%       AVOGADRO            [1/mol]
%       STEFANBOLTZMANN     Total blackbody emission is STEFANBOLTZMANN*T^4
%       CBGR                Temperature of cosmic background radiation 
%       EARTH_RADIUS        Standard value for the Earth radius. Selected value
%                           gives a circumference of 360*60 nautical miles.
%       EARTHORBIT_RADIUS   Radius of the Earth orbit, around the Sun  
%       NAUTICAL_MILE       1 nautical mile 
%       SUN_RADIUS          Sun radius
%       DEG2RAD             Conversion from degrees to radians
%       RAD2DEG             Conversion from radians to degrees
%
% FORMAT   const = constants(name);
%        
% OUT   const   Value of the constant.  
% IN    name    Name of the constant.

% 2002-12-12   Created by Claudia Emde and Patrick Eriksson.


function const = constants(name)

% You can add new constants here. The names should be self-explanatory
% and the constants are sorted alphabetically. You also have to add the 
% name of the constant in the list above, so that the help command 
% gives out a complete list of constants.

switch name

case 'SPEED_OF_LIGHT'
    const = 2.99792458e8;

case 'BOLTZMANN_CONST'
    const = 1.380662e-23;

case 'PLANCK_CONST'
    const = 6.626180e-34;

case 'AVOGADRO'
    const = 6.0225e23;

case 'STEFANBOLTZMANN'
    const = 2*pi^5*constants('BOLTZMANN_CONST')^4 / ...
                (15*constants('PLANCK_CONST')^3*constants('SPEED_OF_LIGHT')^2);

case 'CBGR'
    const = 2.735;

case 'EARTH_RADIUS'
    const = 6.3667e6;

case 'EARTHORBIT_RADIUS'
    const = 1.495e11;

case 'NAUTICAL_MILE'
    const = 1852;

case 'SUN_RADIUS'
    const = 6.960e8;

case 'DEG2RAD'
    const = 0.01745329251994;

case 'RAD2DEG'
    const = 57.29577951308232;

otherwise
    error(strcat('Unknown constant: ', name))
end      