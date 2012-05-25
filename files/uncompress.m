function filename = uncompress(compfile,tmpdir)
%% uncompress
%
% Purpose: uncompress a file and return the name of the uncompressed file
%
% IN        compfile        full path to compressed file
%           tmpdir          The directory you want to uncompress it into (optional)
%
% OUT       filename        The fullpath to the uncompressed filename.
%                           Empty if the file was never uncompressed.
%
% NOTE
%           Known compression formats are .gz, .zip, and .bz2
%
% Salomon Eliasson
% $Id$

if nargin==1
    tmpdir = atmlab('WORK_AREA');
end

[~,tmpfile,fend] = fileparts(compfile);

filename = '';
switch fend
    case '.zip'
        out = exec_system_cmd(sprintf('unzip %s -d %s',compfile,tmpdir),atmlab('DEBUG'));
        filename =  strtrim(out{1}(strfind(out{1}, 'inflating:')+length('inflating:')+1:end));
    case '.gz'
        filename = fullfile(tmpdir,tmpfile);
        exec_system_cmd(sprintf('gunzip -c %s > %s',compfile,filename),atmlab('DEBUG'));
    case '.bz2'
        filename = fullfile(tmpdir,tmpfile);
        exec_system_cmd(sprintf('bunzip2 -c %s > %s',compfile,filename),atmlab('DEBUG'));
end
