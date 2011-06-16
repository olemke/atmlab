function out = exec_system_cmd(cmd, varargin)
%
% EXEC_SYSTEM_CMD Executes one or more system commands.
%
% Executes one or more system commands.
%
% If any command returns an error code not equal to 0, this function will
% throw an error with the error identifier 'atmlab:exec_system_cmd:shell'.
%
% IN
%
%   cmd: string or cell array of strings
%
%       Command to pass to the shell. If this is a cell array of strings,
%       each string will be apssed to the shell in turn.
%
%
%   verbose: bool, optional. Defaults to false
%
%       If true, each command with be printed to the screen before it is
%       executed.
%
% OUT
%
%   out: cell array of strings
%
%       For each command passed as input, the output (stdout+stderr)
%       is collected in a string. Those strings are then collected to
%       a cell array of strings. If only one input command was given,
%       this is a cell array with one string.
%
% updated by: Salomon, Gerrit
% Author: Oliver Lemke

if ~iscell(cmd), cmd = {cmd}; end

cmd = cmd(:);

verbose = optargs(varargin, {false});
errID = 'atmlab:exec_system_cmd:shell';
out = cell(1,length(cmd)); i = 1; % keep track of output messages
for x = cmd'
    fullcmd = char(x);
    
    if verbose>0, fprintf('%s\n',fullcmd); end
    
    [ret,out{i}] = system(fullcmd);
    
    if verbose>0 && ~isempty(out{i})
        fprintf('%s\n',out{i}(1:end-1))
    end
    
    if (ret ~= 0)
        if any(~cellfun('isempty',regexp(out{i},...
                {'symbol lookup error',...
                'dyld: Symbol not found',...
                'library version mismatched'},'start')))
            error(errID,[ [ out{i} '\n'],...
                'A shared library conflict occured while running the command.\n'...
                'This may be due to the fact that MATLAB comes with its own versions of some system libraries\n',...
                'To use the system libraries do:\n',...
                'If you are on a MAC, try setenv(''DYLD_LIBRARY_PATH'','''')\n',...
                'If you are using LINUX, try setenv(''LD_LIBRARY_PATH'','''')\n',...
                'If this solves the problem, add the corresponding line to your startup file'])
        else
            error(errID,'Command returned error %d: "%s"', ret, out{i})
        end
    end
    i = i+1;
end

end
