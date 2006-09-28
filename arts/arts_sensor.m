% ARTS_SENSOR   Calculates sensor response matrix using ARTS
%
%   Calculates the sensor response matrix. This needs that fields 
%   Q.SENSOR_RESPONSE holds a definition of the sensor responses
%   (see *qarts_sensor*). The sensor output variables are all part
%   of Qarts (e.g. SENSOR_RESPONSE, SENSOR_RESPONSE_F and ANTENNA_DIM).
%
%   This functioon can be used to pre-calculate the sensor response for
%   later ARTS calculations.
%
%   The sensor variables are either read into Matlab and stored in
%   corresponding Q-field (filenames=0), or the Q-fileds are set to the 
%   name of produced files (filenames=1). The later option requires that
%   *workfolder* is set.
%
% FORMAT   Q = arts_sensor( Q [, workfolder, filenames ] )
%        
% OUT   Q   Qarts structure with sensor fields set.
% IN    Q   Qarts structure.
% OPT   workfolder   If not defined or empty, a temporary folder is created.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored. These files
%                    will be left in the folder. The files are not read if
%                    corresponding output argument not is considered.
%                    Default is [].
%       filenames    See above. Default is 0.

% 2006-09-28   Created by Patrick Eriksson.


function Q = arts_sensor( Q, workfolder, filenames )


%- Default values
%
workfolder_DEFAULT = [];
filenames_DEFAULT  = 0;
%
set_defaults;


%- Check input
%
rqre_datatype( 'struct', Q );
rqre_datatype( {'empty','char'}, workfolder );
rqre_bool( 'Input argument *filenames*', filenames );
%
if isempty( workfolder )  &  filenames
  error( 'The option *filenames* requires that *workfolder* is defined*.' );
end


folder_created = 0;
%
if isempty( workfolder )
  workfolder   = create_tmpfolder;
end


try
  %
  parts = qarts2cfile( 'sensor' );
  S     = qarts2cfile( Q, parts, workfolder );
  cfile = fullfile( workfolder, 'cfile.arts' );
  qtool( S, cfile, [] );
  arts( cfile );

  if filenames
    Q.SENSOR_RESPONSE     = fullfile( workfolder, 'sensor_response.xml' );
    Q.SENSOR_RESPONSE_F   = fullfile( workfolder, 'sensor_response_f.xml' );
    Q.SENSOR_RESPONSE_ZA  = fullfile( workfolder, 'sensor_response_za.xml' );
    Q.SENSOR_RESPONSE_AA  = fullfile( workfolder, 'sensor_response_aa.xml' );
    Q.SENSOR_RESPONSE_POL = fullfile( workfolder, 'sensor_response_pol.xml' );
    Q.ANTENNA_DIM         = fullfile( workfolder, 'antenna_dim.xml' );
    Q.MBLOCK_ZA_GRID      = fullfile( workfolder, 'mblock_za_grid.xml' );
    Q.MBLOCK_AA_GRID      = fullfile( workfolder, 'mblock_aa_grid.xml' );
  else
    Q.SENSOR_RESPONSE = ...
             xmlLoad( fullfile( workfolder, 'sensor_response.xml' ) );
    Q.SENSOR_RESPONSE_F = ...
             xmlLoad( fullfile( workfolder, 'sensor_response_f.xml' ) );
    Q.SENSOR_RESPONSE_ZA = ...
             xmlLoad( fullfile( workfolder, 'sensor_response_za.xml' ) );
    Q.SENSOR_RESPONSE_AA = ...
             xmlLoad( fullfile( workfolder, 'sensor_response_aa.xml' ) );
    Q.SENSOR_RESPONSE_POL = ...
             xmlLoad( fullfile( workfolder, 'sensor_response_pol.xml' ) );
    Q.ANTENNA_DIM = ...
             xmlLoad( fullfile( workfolder, 'antenna_dim.xml' ) );
    Q.MBLOCK_ZA_GRID = ...
             xmlLoad( fullfile( workfolder, 'mblock_za_grid.xml' ) );
    Q.MBLOCK_AA_GRID = ...
             xmlLoad( fullfile( workfolder, 'mblock_aa_grid.xml' ) );
  end  

  if folder_created
    delete_tmpfolder( workfolder );
  end

catch
  if folder_created
    delete_tmpfolder( workfolder );
  end
  rethrow(lasterror);
end