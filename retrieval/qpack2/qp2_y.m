% QP2_Y   Defines recognised fields for qpack2 measurement data
%
%    Allowed formats differ between the fields. For information about a 
%    specific field, type e.g.:
%       qinfo( @qp2_y, 'Y' );
%
%    This function is organised in such way that *qcheck* and *qinfo*
%    can be used.
%
% FORMAT   [Q,I] = qp2_y
%        
% OUT   Q  Setting structure with default values for all recognised fields.
%       I  Includes same fields as Q, where the content of each field
%          is a description string (used by *qinfo*).

% 2009-07-01   Created by Patrick Eriksson.


function [Q,I] = qp2_y
  
%-----------------------------------------------------------------------------
Q.DAY = {};
I.DAY = [ ...
'Measurement time information. All these fields (YEAR, MONTH, ...) are ',...
'numeric scalars. This information is primarily used to extract data from ',...
'the climatology databases.'
];
%-----------------------------------------------------------------------------
Q.F = {};
I.F = [ ...
'Frequency for each value of Y. Not required information. Qpack2 uses ', ...
'this field only for consistency checks.'
];
%-----------------------------------------------------------------------------
Q.HOUR = {};
I.HOUR = [ ...
'Optional data. Allows a more detailed specification of measurement time.',...
'Otherwise as field DAY.'
];
%-----------------------------------------------------------------------------
Q.HSE_P = {};
I.HSE_P = [ ...
'The reference point when enforcing hydrostatic equilibrium. The ',...
'geometrical altitude (HSE_Z) is given for one presssure (HSE_P).'
];
%-----------------------------------------------------------------------------
Q.HSE_Z = {};
I.HSE_Z = [ ...
'The reference point when enforcing hydrostatic equilibrium. The ',...
'geometrical altitude (HSE_Z) is given for one presssure (HSE_P).'
];
%-----------------------------------------------------------------------------
Q.LATITUDE = {};
I.LATITUDE = [ ...
'The geographical position of the measurement.'
];
%-----------------------------------------------------------------------------
Q.LONGITUDE = {};
I.LONGITUDE = [ ...
'The geographical position of the measurement. '
];
%-----------------------------------------------------------------------------
Q.MINUTE = {};
I.MINUTE = [ ...
'Optional data. Allows a more detailed specification of measurement time.',...
'Otherwise as field DAY.'
];
%-----------------------------------------------------------------------------
Q.MONTH = {};
I.MONTH = [ ...
'Measurement time information. All these fields (YEAR, MONTH, ...) are ',...
'numeric scalars. This information is primarily used to extract data from ',...
'the climatology databases.'
];
%-----------------------------------------------------------------------------
Q.SECOND = {};
I.SECOND = [ ...
'Optional data. Allows a more detailed specification of measurement time.',...
'Otherwise as field DAY.'
];
%-----------------------------------------------------------------------------
Q.TNOISE = {};
I.TNOISE = [ ...
'Magnitude of thermal noise, given as 1 standard devation. A scalar or a ',...
'vector having the same length as y. If a scalar, the value is applied for ',...
'all spectrometer channels.'
];
%-----------------------------------------------------------------------------
Q.Y = {};
I.Y = [ ...
'The spectrum.'
];
%-----------------------------------------------------------------------------
Q.YEAR = {};
I.YEAR = [ ...
'Measurement time information. All these fields (YEAR, MONTH, ...) are ',...
'numeric scalars. This information is primarily used to extract data from ',...
'the climatology databases.'
];
%-----------------------------------------------------------------------------
Q.ZA = {};
I.ZA = [ ...
'Line-of-sight zenith angle for the measurement. A scalar value.'
];
%-----------------------------------------------------------------------------
Q.Z_PLATFORM = {};
I.Z_PLATFORM = [ ...
'Altitude (above geoid) of observation platform.'
];
%-----------------------------------------------------------------------------
