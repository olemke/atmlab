function out = exec_gmt_cmd(cmd, verbose)
%
% EXEC_GMT_CMD Executes a system command.
%
% Execute a shell command for GMT.
%
% IN    cmd      Command string
%
% OUT   out      A cell containing all stdouts
%
%
% OPT   verbose   Set to true to echo the command.
%
% Author: Oliver Lemke & Salomon Eliasson

if ~iscell(cmd), cmd = {cmd}; end

cmd = cmd(:);

if ~exist('verbose', 'var'), verbose=1; end

out = cell(1,length(cmd)); i = 1; % keep track of output messages
for x = cmd'
    fullcmd = char(x);

    if verbose>0, fprintf('%s\n',fullcmd); end

    [ret,out{i}] = system(fullcmd);
    
    if verbose>0 && ~isempty(out{i})
        fprintf('%s\n',out{i}(1:end-1))
    end
    
    if (ret == 127)
        error('atmlab:shell','Command not found: "%s"', fullcmd)
    end
    i = i+1;
end

