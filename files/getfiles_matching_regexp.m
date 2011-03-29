function files = getfiles_matching_regexp(datadir,regularexp)
%% getfiles_matching_regexp
%
% Purpose: List all files that match regular expression in directory and
% its subdirectories
%
% USAGE: files = getfiles_matching_regexp('directory','regexp')
%
% IN: 
%     datadir   directory to look at   e.g. '.'
%     regexp    regular expression     e.g. '.m$e4' ($ signals the end of the filename)
%
%
%
% OUT: files    cell of matching file names
%
%
% 28/3-2011 created by Salomon Eliasson

if isempty(dir(datadir))
    error('atmlab:input','Directory: %s\nDoes not exist',datadir)
end

% MAKE a list of files using UNIX find (regular files only)
command = sprintf('find ''%s'' -type f',datadir);
files = exec_gmt_cmd(command,gmtlab('VERBOSITY'));

% use \n for one file per cell element from string output
files = regexp(files{1},'\n','split');

% Apply the regular expression rule to filter out unwanted files
files = files(~cellfun('isempty',regexp(files,regularexp)));