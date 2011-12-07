% CONSTANTS   Phyiscal and math constants
%
%    This function returns physical constants. It gives an 
%    error message, if the constant is not defined. If no constant is
%    given, the functions list of available constants are shown.
%
%    The following constants are defined:
%        
%       SPEED_OF_LIGHT
%       BOLTZMANN_CONST
%       PLANCK_CONST  
%       AVOGADRO                   [1/mol]
%       STEFANBOLTZMANN            Total blackbody emission is STEFANBOLTZMANN*T^4
%       CBGR                       Temperature of cosmic background radiation 
%       EARTH_RADIUS               Standard value for the Earth radius. Selected value
%                                   gives a circumference of 360*60 nautical miles.
%       EARTH_STANDARD_GRAVITY     As defined from CGPM in m/s^2
%       EARTHORBIT_RADIUS          Radius of the Earth orbit, around the Sun  
%       NAUTICAL_MILE              1 nautical mile 
%       SUN_RADIUS                 Sun radius
%       DEG2RAD                    Conversion from degrees to radians
%       RAD2DEG                    Conversion from radians to degrees
%       GAS_CONST_DRY_AIR          Gass constant for dry air in J.kg-1.K-1
%       GAS_CONST_WATER_VAPOR      Gass constant for dry air in J.kg-1.K-1
%       SPECIFIC_HEAT_CONST_PRES   Specific heat at constant pressure J.kg-1.K-1
%       SPECIFIC_HEAT_CONST_VOL    Specific heat at constant pressure J.kg-1.K-1
%       LATENT_HEAT_VAPORIZATION   Latent heat of vaporization J.kg-1
%
% FORMAT   const = constants(name); or
%          [const,unit] = constants(name);
%        
% OUT   const   Value of the constant.
%       unit    string name of the associated unit
%
% IN    name    Name of the constant.   (if empty, the list of constants are shown)
%   
%
% 2002-12-12   Created by Claudia Emde and Patrick Eriksson.
% 2011-12-7    modified by Salomon Eliasson

function [const,unit] = constants(name)

% You can add new constants here. The names should be self-explanatory
% and the constants are sorted alphabetically. You also have to add the 
% name of the constant in the list above, so that the help command 
% gives out a complete list of constants.

if nargin ==0
    ifnargin0
    return
end
   
switch name

case 'SPEED_OF_LIGHT'
    const = 2.99792458e8;
    unit  = 'm/s';
    
case 'BOLTZMANN_CONST'
    const = 1.380662e-23;
    unit  = 'J/K';
    
case 'PLANCK_CONST'
    const = 6.626180e-34;
    unit  = 'Js';
    
case 'AVOGADRO'
    const = 6.0225e23;
    unit  = '1/mol';
    
case 'STEFANBOLTZMANN'
    const = 2*pi^5*constants('BOLTZMANN_CONST')^4 / ...
                (15*constants('PLANCK_CONST')^3*constants('SPEED_OF_LIGHT')^2);

case 'CBGR'
    const = 2.735;
    
case 'EARTH_RADIUS'
    const = 6.378e6;
    unit  = 'm';
    
case 'EARTH_STANDARD_GRAVITY'
    const = 9.80665;
    unit  = 'm/s^2';
        
case 'EARTHORBIT_RADIUS'
    const = 1.495e11;
    unit  = 'm';
    
case 'NAUTICAL_MILE'
    const = 1852;
    unit  = 'm';
    
case 'SUN_RADIUS'
    const = 6.960e8;
    unit  = 'm';

case 'DEG2RAD'
    const = 0.01745329251994;

case 'RAD2DEG'
    const = 57.29577951308232;

case 'GAS_CONST_DRY_AIR'
    const = 287;
    unit  = 'J/(kg K)';
    
case 'GAS_CONST_WATER_VAPOR'
    const = 461.5; 

case 'SPECIFIC_HEAT_CONST_PRES'
    const = 1005; 
    unit  = 'J/(kg K)';
    
case 'SPECIFIC_HEAT_CONST_VOL'
    const = 718;
    
case 'LATENT_HEAT_VAPORIZATION'
    const = 2501e3;
    unit  = 'J/Kg';
otherwise
    error(['atmlab:' mfilename ':badInput'],['Unknown constant: ', name])
end      

% make sure there's something for unit
if ~exist('unit','var'), unit = ''; end

function const_struct = get_constants_struct
% A structure with the same information as the switch case (+units)

name  = {'SPEED_OF_LIGHT','BOLTZMANN_CONST','PLANCK_CONST','AVOGADRO',...
    'STEFANBOLTZMANN','CBGR','EARTH_RADIUS','EARTH_STANDARD_GRAVITY',...
    'EARTHORBIT_RADIUS','NAUTICAL_MILE','SUN_RADIUS','DEG2RAD','RAD2DEG',...
    'GAS_CONST_DRY_AIR','GAS_CONST_WATER_VAPOR','SPECIFIC_HEAT_CONST_PRES',...
    'SPECIFIC_HEAT_CONST_VOL','LATENT_HEAT_VAPORIZATION'};

value = cell(1,length(name));
unit  = cell(1,length(name));

for i = 1:length(name)
    [value{i},unit{i}] = constants(name{i});
end

const_struct = struct('name',name,'value',value,'unit',unit);

function ifnargin0
% if you only want to see what constants there are

const_struct = get_constants_struct;
fprintf('The constants listed in this function are:\n\n')
for i = 1:length(const_struct),
    fprintf('%s = %d [%s]\n',...
        const_struct(i).name,const_struct(i).value,const_struct(i).unit);
end
fprintf('\nUSAGE: e.g. 6378000 = constants(''EARTH_RADIUS'') or\n')
fprintf('USAGE: e.g. [6378000,''m''] = constants(''EARTH_RADIUS'')\n')