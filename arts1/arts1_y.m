% ARTS1_Y   Calculates spectra using ARTS1
%
%    Qarts1 fields for atmosphere, absorption and RT must be
%    specified.
%
% FORMAT   y = arts1_y( Q1 )
%        
% OUT   y    Spectrum vector.
% IN    Q1   Qarts1 structure.

% 2004-09-17   Created by Patrick Eriksson.


function y = arts1_y( Q1 )

tmpfolder   = create_tmpfolder;

parts = {'tgs','pf_grids','load_atm','spectroscopy','calc_abs','init_rte',...
         'calc_rte','save_y'};

S = qarts12cfile( Q1, parts, tmpfolder );

cfile = fullfile( tmpfolder, 'cfile.arts' );

qtool( S, cfile, [] );

arts1( cfile );

y = arts1_loadfile( tmpfolder, 'y', 'VECTOR' );

delete_tmpfolder( tmpfolder );
