% ARTS_Y   Calculates spectra and jacobians using ARTS
%
%    Takes a qarts structure and calculates corresponding spectra, and 
%    associated jacobians (if J_DO is set). As a minimum, a frequency grid,
%    an atmosphere, a surface and clear-sky RTE variables must be specified.
%
% FORMAT   [y,ydata,dy,J,jq,ji] = arts_y( Q [, workfolder] )
%        
% OUT   y            Spectrum vector.
%       ydata        Data to determine frequency, position and LOS for each 
%                    value of *y*. A structure with fields: 
%                    'f', 'pol', 'pos' and 'los', corresponding to *y_f* etc.
%       dy           Estimate of calculation accuracy (see *y_error*).
%       J            Jacobian. NaN returned if Q.J not defined.
%       jq           Jacobian quantities. NaN returned if Q.J not defined.
%       ji           Jacobian indices. NaN returned if Q.J not defined.
%                    Indices are 1-based (that is, ARTS indices + 1);
% IN    Q            Qarts structure.
% OPT   workfolder   If not defined or empty, a temporary folder is created.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored. These files
%                    will be left in the folder. The files are not read if
%                    corresponding output argument not is considered.
%                    Default is [].

% 2004-09-17   Created by Patrick Eriksson.


function [y,ydata,dy,J,jq,ji] = arts_y( Q, workfolder )

%- Default values
%
workfolder_DEFAULT = [];
%
set_defaults;


%- Check input
%
rqre_datatype( 'struct', Q );
rqre_datatype( {'empty','char'}, workfolder );


%- Default output
%
dy = NaN;
J  = NaN;
jq = NaN;
ji = NaN;


folder_created = 0;
%
if isempty( workfolder )
  workfolder     = create_tmpfolder;
  folder_created = 1;
end


%- Avoid unnecessary jacobian calculations
%
if nargout < 4
  Q.J_DO = 0;
end


try
  %
  parts = qarts2cfile( 'y' );    
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



y = xmlLoad( fullfile( workfolder, 'y.xml' ) );



if nargout >= 2
  ydata.f   = xmlLoad( fullfile( workfolder, 'y_f.xml' ) );
  ydata.pol = xmlLoad( fullfile( workfolder, 'y_pol.xml' ) );
  ydata.pos = xmlLoad( fullfile( workfolder, 'y_pos.xml' ) );
  ydata.los = xmlLoad( fullfile( workfolder, 'y_los.xml' ) );
end


if nargout >= 3
  dy = xmlLoad( fullfile( workfolder, 'y_error.xml' ) );
end


if nargout >= 4  &  Q.J_DO
  %
  J = xmlLoad( fullfile( workfolder, 'jacobian.xml' ) );
  %
  if nargout >= 5
    jq = xmlLoad( fullfile( workfolder, 'jacobian_quantities.xml' ) );
    ji = xmlLoad( fullfile( workfolder, 'jacobian_indices.xml' ) );
    for i = 1 : length(ji)
      for j = 1 : length(ji{i})
        ji{i}{j} = ji{i}{j} + 1;
      end
    end
  end
end



if folder_created
  delete_tmpfolder( workfolder );
end

