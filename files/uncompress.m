function [filename,fail] = uncompress(compfile,tmpdir)
%% uncompress
%
% Purpose: uncompress a file and return the name of the uncompressed file
%
% IN        compfile        full path to compressed file
%           tmpdir          The directory you want to uncompress it into (optional)
%
% OUT       filename        The fullpath to the uncompressed fail
%           fail            true if the operation failed
%
% NOTE
%           If the file doesn't end with .gz or .zip, it just streams
%           through and infile = outfile, and the tmpdir is not used
%
% Salomon Eliasson
% $Id$

if nargin==1
    tmpdir = atmlab('WORK_AREA');
end

[~,tmpfile,fend] = fileparts(compfile);

switch fend
    case '.zip'
        [out,test] = exec_system_cmd(sprintf('unzip %s -d %s',compfile,tmpdir),atmlab('VERBOSITY'));
        filename =  strtrim(out{1}(strfind(out{1}, 'inflating:')+length('inflating:')+1:end));
        fail = logical(test);
    case '.gz'
        filename = fullfile(tmpdir,tmpfile);
        [~,test] = exec_system_cmd(sprintf('gunzip -c %s > %s',compfile,filename),atmlab('VERBOSITY'));
        fail = logical(test);
    otherwise
        filename= compfile;
        fail = false;
end
