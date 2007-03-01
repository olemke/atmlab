% ARTS_BATCH   ARTS batch calculations
%
%    Qarts fields for atmosphere, absorption, sensor and RT must be
%    specified.
%
% FORMAT   Y = arts_y( Q [, workfolder ] )
%        
% OUT   Y   Batch spectra.
% IN    Q   Qarts structure.
% OPT   workfolder   If not defined or empty, a temporary folder is created.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored. These files
%                    will be left in the folder. The files are not read if
%                    corresponding output argument not is considered.
%                    Default is [].

% 2004-09-17   Created by Patrick Eriksson.


function Y = arts_batch( Q, workfolder )


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

  parts = qarts2cfile( 'batch' );

  S = qarts2cfile( Q, parts, workfolder );

  cfile = fullfile( workfolder, 'cfile.arts' );

  qtool( S, cfile, [] );

  arts( cfile );

  Y = xmlLoad( fullfile( workfolder, 'ybatch.xml' ) );

  if folder_created
    delete_tmpfolder( workfolder );
  end


catch
  if folder_created
    delete_tmpfolder( workfolder );
  end

  rethrow(lasterror);
end
