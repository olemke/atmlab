% ARTS_Y   Calculates spectra using ARTS
%
%    Qarts fields for atmosphere, absorption, sensor and RT must be
%    specified.
%
% FORMAT   [y,dy,J,ji] = arts_y( Q )
%        
% OUT   y   Spectrum vector.
%       dy  Estimate of calculation accuracy.
%       J   Jacobian. NaN returned if Q.JACOBIAN_DO=0.
%       ji  Jacobian indices. NaN returned if Q.JACOBIAN_DO=0.
%           Indices are 1-based (that is, ARTS indices + 1);
% IN    Q   Qarts structure.

% 2004-09-17   Created by Patrick Eriksson.


function [y,dy,J,ji] = arts_y( Q )

tmpfolder   = create_tmpfolder;

parts = qarts2cfile( 'y' );

S = qarts2cfile( Q, parts, tmpfolder );

cfile = fullfile( tmpfolder, 'cfile.arts' );

qtool( S, cfile, [] );


arts( cfile );


if isstruct( Q.CLOUDBOX )  
  if strcmp(upper(Q.CLOUDBOX.METHOD),'MC')
    dy = xmlLoad( fullfile( tmpfolder, 'mc_error.xml' ) );
  else
    dy = NaN;
  end
else
  dy = NaN;
end

y = xmlLoad( fullfile( tmpfolder, 'y.xml' ) );

if Q.JACOBIAN_DO
  J = xmlLoad( fullfile( tmpfolder, 'jacobian.xml' ) );
  ji = xmlLoad( fullfile( tmpfolder, 'jacobian_indices.xml' ) );
  for i = 1 : length(ji)
    for j = 1 : length(ji{i})
      ji{i}{j} = ji{i}{j} + 1;
    end
  end
else
  J  = NaN;
  ji = NaN;
end

delete_tmpfolder( tmpfolder );
