% ARTS1_ABSORPTION   Calculates absorption using ARTS1
%
%    Qarts1 fields for atmosphere and absorption must be specified.
%
% FORMAT   [A,At] = arts1_absorption( Q1 )
%        
% OUT   A    Total absorption. Corresponds to arts1 WSV *abs*.
%       At   Absorption per tag group.Corresponds to arts1 WSV *abs_per_tg*.
% IN    Q1   Qarts1 structure.

% 2004-09-30   Created by Patrick Eriksson.


function [A,At] = arts1_abs( Q1 )

tmpfolder   = create_tmpfolder;

parts = {'tgs','pf_grids','load_atm','spectroscopy','calc_abs','save_abs'};

if nargout > 1
  parts = { parts{:}, 'save_abs_per_tg' };
end

S = qarts12cfile( Q1, parts, tmpfolder );

cfile = fullfile( tmpfolder, 'cfile.arts' );

qtool( S, cfile, [] );

arts1( cfile );

A = arts1_loadfile( tmpfolder, 'abs', 'Matrix' );

if nargout > 1
  At = arts1_loadfile( tmpfolder, 'abs_per_tg', 'AOMatrix' );
end

delete_tmpfolder( tmpfolder );
