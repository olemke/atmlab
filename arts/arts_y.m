% ARTS_Y   Calculates spectra and jacobians using ARTS
%
%    Takes a qarts structure and calculates corresponding spectra.
%
%    Auxilary data and jacobians are also returned. The later requires an
%    active selection through J_DO. Otherwise NaN is returned.
%    variables.
%
% FORMAT   [y,ydata,y_error,y_aux,J,jq,ji] = arts_y( Q [, workfolder] )
%        
% OUT   y            Spectrum vector.
%       ydata        Data to determine frequency, position and LOS for each 
%                    value of *y*. A structure with fields: 
%                    'f', 'pol', 'pos' and 'los', corresponding to *y_f* etc.
%       y_error      Estimate of calculation accuracy (see *y_error*).
%       y_aux        Auxilary data (see *y_aux*).
%       J            Jacobian. NaN returned if Q.J not defined.
%       jq           Jacobian quantities. NaN returned if Q.J not defined.
%       ji           Jacobian indices. NaN returned if Q.J not defined.
%                    Indices are 1-based (that is, ARTS indices + 1);
% IN    Q            Qarts structure.
% OPT   workfolder   If not defined or empty, a temporary folder is created.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored. These files
%                    will be left in the folder. The files are not read if
%                    corresponding output argument is not considered.
%                    Default is [].

% 2004-09-17   Created by Patrick Eriksson.

function [y,ydata,y_error,y_aux,J,jq,ji] = arts_y( Q, workfolder )
%
if nargin < 2, workfolder = []; end
                                                                         %&%
                                                                         %&%
%- Check input                                                           %&%
%                                                                        %&%
rqre_datatype( Q, @isstruct );                                           %&%
rqre_datatype( workfolder, {@isempty,@ischar} );                         %&%


%- Default output
%
y_error = NaN;
y_aux   = NaN;
J       = NaN;
jq      = NaN;
ji      = NaN;


%- Create workfolder?
%
if isempty( workfolder )
  workfolder = create_tmpfolder;
  cu = onCleanup( @()delete_tmpfolder( workfolder ) );
end


%- Avoid unnecessary calculations
%
if nargout < 5
  Q.J_DO = false;
end


%- Run ARTS
%
parts = qarts2cfile( 'y' );    
S     = qarts2cfile( Q, parts, workfolder );
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );
arts( cfile );



y = xmlLoad( fullfile( workfolder, 'y.xml' ) );


if nargout >= 2
  ydata.f   = xmlLoad( fullfile( workfolder, 'y_f.xml' ) );
  ydata.pol = xmlLoad( fullfile( workfolder, 'y_pol.xml' ) );
  ydata.pos = xmlLoad( fullfile( workfolder, 'y_pos.xml' ) );
  ydata.los = xmlLoad( fullfile( workfolder, 'y_los.xml' ) );
end


if nargout >= 3
  y_error = xmlLoad( fullfile( workfolder, 'y_error.xml' ) );
end


if nargout >= 4  
  y_aux = xmlLoad( fullfile( workfolder, 'y_aux.xml' ) );
end

if nargout >= 5  & qarts_isset( Q.J_DO ) &  Q.J_DO
  %
  J = xmlLoad( fullfile( workfolder, 'jacobian.xml' ) );
  %
  if nargout >= 6
    jq = xmlLoad( fullfile( workfolder, 'jacobian_quantities.xml' ) );
    ji = xmlLoad( fullfile( workfolder, 'jacobian_indices.xml' ) );
    for i = 1 : length(ji)
      for j = 1 : length(ji{i})
        ji{i}{j} = ji{i}{j} + 1;
      end
    end
  end
end



