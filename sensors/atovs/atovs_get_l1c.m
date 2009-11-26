% ATOVS_GET_L1C   Converts a file from level 1B to level 1C and reads it.
%
% This function reads ATOVS level 1c data.
%
% FORMAT   data = atovs_get_l1c( filename );
%
% IN    file_name   AMSU l1b filename.
% OUT   data        Data structure. See atovs_read_data for format
%                   description.

% 2009-11-26   Created by Oliver Lemke.

function data = atovs_get_l1c( filename );

tf = create_tmpfolder;
atovs_file = [ tf '/atovs.l1c' ];
try
  cmd = ['zamsu2l1c.sh "' filename '" "' atovs_file '"'];
  [result,err] = system(cmd);
  if result ~= 0
    error(err);
  end
  [data, err] = atovs_read_data( atovs_file );
catch
  delete_tmpfolder(tf);
  error(err);
end

delete_tmpfolder(tf);

