% ARTS_Y   Calculates spectra using ARTS
%
%    Qarts fields for atmosphere, absorption, sensor and RT must be
%    specified.
%
% FORMAT   y = arts_y( Q )
%        
% OUT   y   Spectrum vector.
% IN    Q   Qarts structure.

% 2004-09-17   Created by Patrick Eriksson.


function y = arts_y( Q )

tmpfolder   = create_tmpfolder;

parts = qarts2cfile( 'y' );

S = qarts2cfile( Q, parts, tmpfolder );

cfile = fullfile( tmpfolder, 'cfile.arts' );

qtool( S, cfile, [] );

arts( cfile );

y = xmlLoad( fullfile( tmpfolder, 'y.xml' ) );

delete_tmpfolder( tmpfolder );
