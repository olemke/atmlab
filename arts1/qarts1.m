% QARTS1   Defines setting fields for ARTS1 calculations
%
%    The function provides default values (NaN except for arrays where [] is 
%    used) for all recognised fields and a description of each field.
%
%    This function is organised in such way that *qcheck* and *qinfo*
%    can be used.
%
% FORMAT   [Q,I] = qarts1
%        
% OUT   Q  Setting structure including all recognised fields,
%          all set to NaN.
%       I  Includes same fields as Q, where the content of each field
%          is a description string (usewd by *qinfo*).

% 2004-09-07   Created by Patrick Eriksson.


function [Q,I] = qarts1
 
%-----------------------------------------------------------------------------
Q.APRIORI_PTZ = NaN;
I.APRIORI_PTZ = [ ...
'Acts as ARTS1 WSV with same name. Specified as a file name.', ...
' Can be NaN if USE_RAW_ATMOSPHERE = 0.'
];
%-----------------------------------------------------------------------------
Q.APRIORI_VMR = NaN;
I.APRIORI_VMR = [ ...
'Acts as ARTS1 WSV with same name. Specified as a file name without', ...
' extensions.', ...
' Can be NaN if USE_RAW_ATMOSPHERE = 0.'
];
%-----------------------------------------------------------------------------
Q.F_MONO = NaN;
I.F_MONO = [ ...
'As ARTS1 WSV with same name.', ...
' For allowed input formats see P_ABS.'
];
%-----------------------------------------------------------------------------
Q.LINESHAPE = NaN;
I.LINESHAPE = [ ...
'The line shape to use. The same line shape is used for all tag groups.', ...
' Shall be a string.', ...
' Do "arts -d ineshape_per_tgDefine" to list valid options.'
];
%-----------------------------------------------------------------------------
Q.LINESHAPE_CUTOFF = NaN;
I.LINESHAPE_CUTOFF = [ ...
'The line shape cut-off to apply. The same cut-off is used for all tag', ...
' groups. A value of -1 means no cut-off.', ...
' Do "arts -d ineshape_per_tgDefine" for further information.'
];
%-----------------------------------------------------------------------------
Q.LINESHAPE_FACTOR = NaN;
I.LINESHAPE_FACTOR = [ ...
'The line shape normalisation factor to apply. The same factor is used', ...
' for all tag groups. Shall be a string.', ...
' Do "arts -d ineshape_per_tgDefine" for valid options.'
];
%-----------------------------------------------------------------------------
Q.P_ABS = NaN;
I.P_ABS = [ ...
'As ARTS1 WSV with same name.', ...
' Can either be a vector, or name of a relevant file. File names must end', ...
' with .aa or .ab to indicate which ARTS1 data format that is used.' 
];
%-----------------------------------------------------------------------------
Q.T_ABS = NaN;
I.T_ABS = [ ...
'As ARTS1 WSV with same name.', ...
' For allowed input formats see P_ABS. Can be NaN if USE_RAW_ATMOSPHERE = 1.'
];
%-----------------------------------------------------------------------------
Q.TGS = [];
I.TGS = [ ...
'Specification of species tag groups.', ...
' Atmlab format for tag groups is specified in * arts_tgs_cnvrt*.'
];
%-----------------------------------------------------------------------------
Q.USE_RAW_ATMOSPHERE = NaN;
I.USE_RAW_ATMOSPHERE = [ ...
'Boolean to decide if T_ABS, Z_ABS and VMRS shall be used (option 0) or',...
' APRIORI_PTZ and APRIORI_VMRS (option 1).'
];
%-----------------------------------------------------------------------------
Q.VMRS = NaN;
I.VMRS = [ ...
'As ARTS1 WSV with same name.', ...
' For allowed input formats see P_ABS. Can be NaN if USE_RAW_ATMOSPHERE = 1.'
];
%-----------------------------------------------------------------------------
Q.Z_ABS = NaN;
I.Z_ABS = [ ...
'As ARTS1 WSV with same name.', ...
' For allowed input formats see P_ABS. Can be NaN if USE_RAW_ATMOSPHERE = 1.'
];
%-----------------------------------------------------------------------------


