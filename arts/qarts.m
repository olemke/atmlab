% QARTS   Defines setting fields for ARTS calculations
%
%    The function provides default values for all recognised fields and a 
%    description of each field. Default value is normally NaN, but
%    exceptions exist when some standard choice exists. To list default
%    values just type 'qarts'.
%
%    This function is organised in such way that *qcheck* and *qinfo*
%    can be used.
%
% FORMAT   [Q,I] = qarts
%        
% OUT   Q  Setting structure with default values for all recognised fields.
%       I  Includes same fields as Q, where the content of each field
%          is a description string (used by *qinfo*).

% 2004-09-07   Created by Patrick Eriksson.


function [Q,I] = qarts
 
%-----------------------------------------------------------------------------
Q.ATMOSPHERE_DIM = NaN;
I.ATMOSPHERE_DIM = [ ...
'As the ARTS WSV with the same name.'
];
%-----------------------------------------------------------------------------
Q.F_GRID = NaN;
I.F_GRID = [ ...
'Has the same functionality as the ARTS WSV with the same name.', ...
'#   Can be given either as the name of a XML file, or as a Matlab',...
' variable'
];
%-----------------------------------------------------------------------------
Q.GAS_SPECIES = [];
I.GAS_SPECIES = [ ...
'Specification of gas species tag groups.', ...
' Atmlab format for tag groups is specified in * arts_tgs_cnvrt*.'
];
%-----------------------------------------------------------------------------
Q.LAT_GRID = NaN;
I.LAT_GRID = [ ...
'Has the same functionality as the ARTS WSV with the same name.', ...
'#   Can be given either as the name of a XML file, or as a Matlab',...
' variable'
];
%-----------------------------------------------------------------------------
Q.LON_GRID = NaN;
I.LON_GRID = [ ...
'Has the same functionality as the ARTS WSV with the same name.', ...
'#   Can be given either as the name of a XML file, or as a Matlab',...
' variable'
];
%-----------------------------------------------------------------------------
Q.P_GRID = NaN;
I.P_GRID = [ ...
'Has the same functionality as the ARTS WSV with the same name.', ...
'#   Can be given either as the name of a XML file, or as a Matlab',...
' variable'
];
%-----------------------------------------------------------------------------
Q.STOKES_DIM = NaN;
I.STOKES_DIM = [ ...
'As the ARTS WSV with the same name.'
];
%-----------------------------------------------------------------------------
