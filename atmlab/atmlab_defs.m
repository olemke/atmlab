% ATMLAB_DEFS   Defaults for Atmlab user settings.
%
%    A structure of the type used for the Atmlab personal settings is created
%    where all fields are set to be empty.
%
%    Only fields defined here are valid setting options.
%
% FORMAT   A = atmlab_defs
%        
% OUT   A   A structure with just empty fields.

% 2007-04-10   Copied from atmlab.m by Oliver Lemke.

function A = atmlab_defs

A.AMI_PATH          = NaN;
A.ARTS_PATH         = NaN;
A.ARTS_XMLDATA_PATH = NaN;
A.ARTS1_DATA_PATH   = NaN;
A.ARTS1_HDF         = NaN;
A.ARTS1_PATH        = NaN;
A.DEBUG             = 0;
A.EXTRAP            = 0;
A.FMODEL_VERBOSITY  = 0;
A.SCREEN_WIDTH      = 70;
A.VERBOSITY         = 1;
A.WORK_AREA         = NaN;

