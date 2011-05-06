function [out,ret] = exec_system_cmd(cmd, verbose)
%
% EXEC_SYSTEM_CMD Executes a system command.
%
% Execute a shell command for GMT.
%
% IN    cmd      Command string
%
% OUT   out      A cell containing all stdouts (One for every system call)
%
%
% OPT   verbose   Set to true to echo the command.
%
% updated by: Salomon
% Author: Oliver Lemke

if ~iscell(cmd), cmd = {cmd}; end

cmd = cmd(:);

if ~exist('verbose', 'var'), verbose=1; end
errID = 'amtlab:exec_system_cmd:shell';
out = cell(1,length(cmd)); i = 1; % keep track of output messages
for x = cmd'
    fullcmd = char(x);
    
    if verbose>0, fprintf('%s\n',fullcmd); end
    
    [ret,out{i}] = system(fullcmd);
    
    if verbose>0 && ~isempty(out{i})
        fprintf('%s\n',out{i}(1:end-1))
    end
    
    if (ret == 127)
        if any(regexp(out{i},{'symbol lookup error','library version mismatched'}))
            error(errID,[ [ out{i} '\n'],...
                'A shared library conflict occured while running the command.\n'...
                'This may be due to the fact that MATLAB comes with its own versions of some system libraries\n',...
                'To use the system libraries do:\n',...
                'If you are on a MAC, try setenv(''DYLD_LIBRARY_PATH'','''')\n',...
                'If you are using LINUX, try setenv(''LD_LIBRARY_PATH'','''')\n',...
                'If this solves the problem, add the corresponding line to your startup file'])
        else
            error(errID,'Command not found: "%s"', fullcmd)
        end
    elseif (ret ~= 0)
        error(errID,'Command returned error %d: "%s"', ret, out{i})
    end
    i = i+1;
end

