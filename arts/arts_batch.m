% ARTS_BATCH   Performs ARTS batch calculations
%
%    Largely as *arts_y* but calculates several spectra in a single run,
%    batch calculations. The data to be changed between each spectrim is
%    stored in Q.BATCH, with details drescribed in qartsBatch.
%
% FORMAT   Q = arts_sensor( Q [, workfolder] )
%        
% OUT   Y            Calculated spectra.
% IN    Q            Qarts structure.
% OPT   workfolder   If not defined or empty, a temporary folder is created.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored.

% 2007-10-22   Created by Patrick Eriksson.

function Y = arts_batch( Q, workfolder )
%
if nargin < 2
  workfolder = [];
end
                                                                 %&%
                                                                 %&%
%= Check input                                                   %&%
%                                                                %&%
rqre_nargin(2,nargin);                                           %&%
%                                                                %&%
rqre_datatype( Q, @isstruct );                                   %&%
rqre_datatype( workfolder, {@isempty,@ischar} );                 %&%


folder_created = 0;
%
if isempty( workfolder )
  workfolder     = create_tmpfolder;
  folder_created = 1;
end


try
  %
  parts = qarts2cfile( 'Batch' );
  S     = qarts2cfile( Q, parts, workfolder );
  cfile = fullfile( workfolder, 'cfile.arts' );
  strs2file( cfile, S );
  arts( cfile );

catch
  if folder_created
    delete_tmpfolder( workfolder );
  end
  rethrow(lasterror);
end

Y = xmlLoad( fullfile( workfolder, 'ybatch.xml' ) );

if folder_created
  delete_tmpfolder( workfolder );  
end
