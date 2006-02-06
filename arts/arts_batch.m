% ARTS_Y   Calculates spectra using ARTS
%
%    Qarts fields for atmosphere, absorption, sensor and RT must be
%    specified.
%
% FORMAT   [y,dy] = arts_y( Q )
%        
% OUT   y   Spectrum vector.
%       dy  Estimate of calculation accuracy.
% IN    Q   Qarts structure.

% 2004-09-17   Created by Patrick Eriksson.


function Y = arts_batch( Q )

tmpfolder   = create_tmpfolder;

parts = qarts2cfile( 'batch' );

S = qarts2cfile( Q, parts, tmpfolder );

cfile = fullfile( tmpfolder, 'cfile.arts' );

qtool( S, cfile, [] );

arts( cfile );

Y = xmlLoad( fullfile( tmpfolder, 'ybatch.xml' ) );

delete_tmpfolder( tmpfolder );


