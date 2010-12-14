function [head, line] = avhrr_define_gac_l1b

% avhrr_define_gac_l1b Get AVHRR GAC L1B header and line definitions
%
% Reads the AVHRR L1B header and line definitions from HTML pages
% in ATMLAB_DATA.
%
% FORMAT
%
%   [head, line] = avhrr_define_gac_l1b
%
% OUT
%
%   head    struct
%   line    struct
%
% $Id$

% See ATMLAB_DATA_PATH/sensors/avhrr/README for how to regenerate this
% mat-file if necessary

matfile = fullfile(atmlab('ATMLAB_DATA_PATH'), 'sensors', 'avhrr', 'gac_version4.mat');
S = load(matfile);
head = S.head;
line = S.line;

end
