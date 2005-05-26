% QARTS_BATCH   Defines setting fields for ARTS batch calculations
%
%    The function provides default values for all recognised fields and a 
%    description of each field. Default value is normally NaN, but
%    exceptions exist when some standard choice exists. To list default
%    values just type 'qarts_batch'.
%
%    This function is organised in such way that *qcheck* and *qinfo*
%    can be used.
%
% FORMAT   [B,I] = qarts_batch
%        
% OUT   B  Setting structure with default values for all recognised fields.
%       I  Includes same fields as B, where the content of each field
%          is a description string (used by *qinfo*).

% 2005-05-26   Created by Patrick Eriksson.


function [B,I] = qarts_batch
 

%-----------------------------------------------------------------------------
B.CALC_AGENDA = {'RteCalc{}'};
I.CALC_AGENDA = [ ...
'Corresponds directly to ARTS WSV *batch_calc_agenda*.'
];
%-----------------------------------------------------------------------------
B.DATA = [];
I.DATA = [ ...
'Batch data. This field is a cell array where each element shall have the ',...
'the fields:', ...
'#   WSV  : The ARTS WSV to which the data shall be transfered.', ...
'#   TYPE : The ARTS data type of the WSV.', ...
'#   X    : The actual batch data. This variable shall accordingly be of ', ...
'one dimension higher than the WSV type. ', ...
'# For example, if *sensor_los* shall be modified, then you do something ', ...
'like:', ...
'#   Q.BATCH.DATA{1}.WSV  = ''sensor_los'';', ...
'#   Q.BATCH.DATA{1}.TYPE = ''Matrix'';', ...
'#   Q.BATCH.DATA{1}.X    = 113.3+randn(5,1,1)*0.05;'
];
%-----------------------------------------------------------------------------
B.N = NaN;
I.N = [ ...
'Number of batch cases to run.'
];
%-----------------------------------------------------------------------------
B.POST_AGENDA = {'Ignore(ybatch){}','DoNothing(ybatch){}'};
I.POST_AGENDA = [ ...
'Corresponds directly to ARTS WSV *batch_post_agenda*.', ...
'#   Conversion of radiances to other units is included automatically, ', ...
'where output unit follows *Q.Y_UNIT*. Neither saving to file needs to be ',...
'inluded in this agenda.'
];
%-----------------------------------------------------------------------------

