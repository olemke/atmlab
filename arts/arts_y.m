% ARTS_Y   Calculates spectra using ARTS
%
%    Qarts fields for atmosphere, absorption, sensor and RT must be
%    specified.
%
% FORMAT   [y,dy,J,jq,ji] = arts_y( Q [, workfolder] )
%        
% OUT   y   Spectrum vector.
%       dy  Estimate of calculation accuracy.
%       J   Jacobian. NaN returned if Q.J not defined.
%       jq  Jacobian quantities. NaN returned if Q.J not defined.
%       ji  Jacobian indices. NaN returned if Q.J not defined.
%           Indices are 1-based (that is, ARTS indices + 1);
% IN    Q   Qarts structure.
% OPT   workfolder   If not defined or empty, a temporary folder is created.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored. These files
%                    will be left in the folder. The files are not read if
%                    corresponding output argument not is considered.
%                    Default is [].

% 2004-09-17   Created by Patrick Eriksson.


function [y,dy,J,jq,ji] = arts_y( Q, workfolder )


%- Default values
%
workfolder_DEFAULT = [];
%
set_defaults;


%- Check input
%
rqre_datatype( 'struct', Q );
rqre_datatype( {'empty','char'}, workfolder );


folder_created = 0;
%
if isempty( workfolder )
  workfolder     = create_tmpfolder;
  folder_created = 1;
end


try
  %
  parts = qarts2cfile( 'y+j' );
  S     = qarts2cfile( Q, parts, workfolder );
  cfile = fullfile( workfolder, 'cfile.arts' );
  qtool( S, cfile, [] );
  arts( cfile );

catch
  if folder_created
    delete_tmpfolder( workfolder );
  end
  rethrow(lasterror);
end


if isstruct( Q.CLOUDBOX )  
  if strcmp(upper(Q.CLOUDBOX.METHOD),'MC')
    dy = xmlLoad( fullfile( workfolder, 'mc_error.xml' ) );
  else
    dy = NaN;
  end
else
  dy = NaN;
end

if nargout >= 1
  %
  y = xmlLoad( fullfile( workfolder, 'y.xml' ) );
  %
  if nargout >= 3
    %
    J = xmlLoad( fullfile( workfolder, 'jacobian.xml' ) );
    %
    if nargout >= 4
      jq = xmlLoad( fullfile( workfolder, 'jacobian_quantities.xml' ) );
      ji = xmlLoad( fullfile( workfolder, 'jacobian_indices.xml' ) );
      for i = 1 : length(ji)
        for j = 1 : length(ji{i})
          ji{i}{j} = ji{i}{j} + 1;
        end
      end
    end
  end
end


if folder_created
  delete_tmpfolder( workfolder );
end
