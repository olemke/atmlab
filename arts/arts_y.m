% ARTS_Y   Calculates spectra using ARTS
%
%    Qarts fields for atmosphere, absorption, sensor and RT must be
%    specified.
%
% FORMAT   [y,dy,J,jq,ji] = arts_y( Q )
%        
% OUT   y   Spectrum vector.
%       dy  Estimate of calculation accuracy.
%       J   Jacobian. NaN returned if Q.J not defined.
%       jq  Jacobian quantities. NaN returned if Q.J not defined.
%       ji  Jacobian indices. NaN returned if Q.J not defined.
%           Indices are 1-based (that is, ARTS indices + 1);
% IN    Q   Qarts structure.

% 2004-09-17   Created by Patrick Eriksson.


function [y,dy,J,jq,ji] = arts_y( Q )


%- Avoid unnecessary Jacobian calculations
%
if nargout <= 2
  Q.J = NaN;
end


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

if nargout > 2
  if exist( fullfile( tmpfolder, 'jacobian.xml' ), 'file' )
    J = xmlLoad( fullfile( tmpfolder, 'jacobian.xml' ) );
    if nargout >= 4
      jq = xmlLoad( fullfile( tmpfolder, 'jacobian_quantities.xml' ) );
      ji = xmlLoad( fullfile( tmpfolder, 'jacobian_indices.xml' ) );
      for i = 1 : length(ji)
        for j = 1 : length(ji{i})
          ji{i}{j} = ji{i}{j} + 1;
        end
      end
    end
  else
    J  = NaN;
    jq = NaN;
    ji = NaN;
  end
end


delete_tmpfolder( tmpfolder );
