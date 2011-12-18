% CONSTANTS   Phyiscal and math constants
%
%    This function returns physical constants. It gives an 
%    error message, if the constant is not defined. If no constant is
%    given, the function's list of available constants are shown.
%
%    The following constants are defined:
%        
%       SPEED_OF_LIGHT             [m/s]
%       BOLTZMANN_CONST            [J/K]
%       PLANCK_CONST               [Js]
%       AVOGADRO                   [1/mol]
%       STEFANBOLTZMANN            [J.K-1.m-2.s-1] Total blackbody emission is STEFANBOLTZMANN*T^4
%       CBGR                       [K] Temperature of cosmic background radiation 
%       EARTH_RADIUS               [m] Equatorial radius of the earth.
%       EARTH_RADIUS_MEAN          [m] Mean radius of the earth.
%       EARTH_STANDARD_GRAVITY     [m/s^2] As defined from CGPM in m/s^2
%       EARTHORBIT_RADIUS          [m] Radius of the Earth orbit, around the Sun  
%       NAUTICAL_MILE              [m] 1 nautical mile 
%       SUN_RADIUS                 [m] Sun radius
%       DEG2RAD                    [rad] Conversion from degrees to radians
%       RAD2DEG                    [deg] Conversion from radians to degrees
%       GAS_CONST_DRY_AIR          [J.kg-1e4.K-1] Gas constant for dry air
%       GAS_CONST_WATER_VAPOR      [J.kg-1.K-1] Gas constant for water vapor
%       SPECIFIC_HEAT_CP_DRY_AIR   [J.kg-1.K-1] Specific heat at constant pressure, at sea level, and at 0°C
%       SPECIFIC_HEAT_CV_DRY_AIR   [J.kg-1.K-1] Specific heat at constant pressure 
%       LATENT_HEAT_VAPORIZATION   [J.kg-1] Latent heat of vaporization of water vapor
%
%        
% OUT   const   Value of the constant.
%       unit    string name of the associated unit
%
% IN    name    Name of the constant.   (if empty, the list of constants are shown)
%   
%
% FORMAT   const = constants(name); or
%          [const,unit] = constants(name);
%
% 2002-12-12   Created by Claudia Emde and Patrick Eriksson.
% 2011-12-7    modified by Salomon Eliasson
% $Id$

% constants that changed values since 2011-12-7
%
%Boltzmann_const
%1.380662e-23 -> 1.3806488e-23
% Planck constant
% 6.626180e-34 -> 6.62606957e-34
% Avogadro constant
% 6.0225e23 -> 6.02214129e23
% CBGR
% 2.735 -> 2.725
% EARTH_RADIUS
% 6.378e6 -> 6.3781e6 (and write that this is the equatorial radius)
% EARTHORBIT_AXIS
% 1.495e11 -> 1.49598261e11 (aplies to the semi-maxis axis of the
%                            orbit (1.00000261AU) 
% SUN_RADIUS
% 6.960e8 -> 6.955e8
% DEG2RAD
% 0.01745329251994 -> pi/180
% RAD2DEG
% 57.2957795130823 -> 180/pi
% GAS_CONST_DRY_AIR
% 287-> 287.04
% SPECIFIC_HEAT_CONST_PRES
% 1005 -> 1003.5
% LATENT_HEAT_VAPORIZATION
% 2501e3 -> 2257e3

function [const,unit] = constants(name)

% You can add new constants here. The names should be self-explanatory
% and the constants are sorted alphabetically. You also have to add the 
% name of the constant in the help section above, so that the help command 
% gives out a complete list of constants. Aslo add their name to the
% subfunction below so they will be included in the output structure of all
% available constants (if nargin ==0). In the switch case, remember to also
% list along with the constant's value, its unit, and a reference.

if nargin ==0
    const = ifnargin0;
    return
end
   
switch name

case 'SPEED_OF_LIGHT'
    %ref: http://en.wikipedia.org/wiki/Speed_of_light
    const = 2.99792458e8;
    unit  = 'ms^{-1}';
    
case 'BOLTZMANN_CONST'
    %ref: http://en.wikipedia.org/wiki/Boltzmann_constant
    const = 1.3806488e-23;
    unit  = 'JK^{-1}';
    
case 'PLANCK_CONST'
    %ref: http://en.wikipedia.org/wiki/Planck_constant
    const = 6.62606957e-34;
    unit  = 'Js';
    
case 'AVOGADRO'
    %ref: http://physics.nist.gov/cgi-bin/cuu/Value?na|search_for=avogadro
    const = 6.02214129e23;
    unit  = 'mol^{-1}';
    
case 'STEFANBOLTZMANN'
    const = 2*pi^5*constants('BOLTZMANN_CONST')^4 / ...
                (15*constants('PLANCK_CONST')^3*constants('SPEED_OF_LIGHT')^2);
    unit = 'JK^{-4}m^{-2}s^{-1}';

case 'CBGR'
    %ref: http://en.wikipedia.org/wiki/Cosmic_background_radiation
    const = 2.725;
    unit = 'K';
    
case 'EARTH_RADIUS'
    %ref: http://en.wikipedia.org/wiki/Earth (equatorial radius)
    const = 6.3781e6;
    unit  = 'm';
    
case 'EARTH_RADIUS_MEAN'
    %ref: http://en.wikipedia.org/wiki/Earth (mean radius)
    const = 6.371e6;
    unit  = 'm';
    
case 'EARTH_STANDARD_GRAVITY'
    % ref: http://en.wikipedia.org/wiki/Standard_gravity
    const = 9.80665;
    unit  = 'ms^{-2}';
        
case 'EARTHORBIT_RADIUS'
    % ref: http://en.wikipedia.org/wiki/Earth (Semi-major axis)
    const = 1.49598261e11;
    unit  = 'm';
    
case 'NAUTICAL_MILE'
    % ref: http://en.wikipedia.org/wiki/Nautical_mile
    const = 1852;
    unit  = 'm';
    
case 'SUN_RADIUS'
    % ref: http://en.wikipedia.org/wiki/Sun
    const = 6.955e8;
    unit  = 'm';

case 'DEG2RAD'
    const = pi/180;
    unit = 'rad';
    
case 'RAD2DEG'
    const = 180/pi;
    unit = 'deg';

case 'GAS_CONST_DRY_AIR'
    %ref: http://en.wikipedia.org/wiki/Gas_constant
    const = 287.04;
    unit  = 'Jkg^{-1}K^{-1}';
    
case 'GAS_CONST_WATER_VAPOR'
    % ref: http://en.wikipedia.org/wiki/Water_vapor
    const = 461.5; 
    unit  = 'Jkg^{-1}K^{-1}';
    
case 'SPECIFIC_HEAT_CP_DRY_AIR'
    %ref: 56
    const = 1003.5; 
    unit  = 'Jkg^{-1}K^{-1}';
    
case 'SPECIFIC_HEAT_CV_DRY_AIR'
    % ref: 
    const = 718;
    unit  = 'Jkg^{-1}K^{-1}';
    
case 'LATENT_HEAT_VAPORIZATION'
    % ref: http://en.wikipedia.org/wiki/Enthalpy_of_vaporization
    const = 2257e3;
    unit  = 'Jkg^{-1}';
otherwise
    error(['atmlab:' mfilename ':badInput'],['Unknown constant: ', name])
end      

% make sure there's something for unit
if ~exist('unit','var'), unit = ''; end

function const_struct = get_constants_struct
% A structure with the same information as the switch case (+units)

name  = {'SPEED_OF_LIGHT','BOLTZMANN_CONST','PLANCK_CONST','AVOGADRO',...
    'STEFANBOLTZMANN','CBGR','EARTH_RADIUS','EARTH_RADIUS_MEAN','EARTH_STANDARD_GRAVITY',...
    'EARTHORBIT_RADIUS','NAUTICAL_MILE','SUN_RADIUS','DEG2RAD','RAD2DEG',...
    'GAS_CONST_DRY_AIR','GAS_CONST_WATER_VAPOR','SPECIFIC_HEAT_CP_DRY_AIR',...
    'SPECIFIC_HEAT_CV_DRY_AIR','LATENT_HEAT_VAPORIZATION'};

value = cell(1,length(name));
unit  = cell(1,length(name));

for i = 1:length(name)
    [value{i},unit{i}] = constants(name{i});
end

const_struct = struct('name',name,'value',value,'unit',unit);

function const_struct = ifnargin0
% if you only want to see what constants there are

const_struct = get_constants_struct;
fprintf('The constants listed in this function are:\n\n')
for i = 1:length(const_struct),
    fprintf('%s = %d [%s]\n',...
        const_struct(i).name,const_struct(i).value,const_struct(i).unit);
end
fprintf('\nUSAGE: e.g. 6378000 = constants(''EARTH_RADIUS'') or\n')
fprintf('USAGE: e.g. [6378000,''m''] = constants(''EARTH_RADIUS'')\n')