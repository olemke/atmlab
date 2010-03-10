function exec_gmt_cmd(cmd, silent)
%
% EXEC_GMT_CMD Executes a system command.
%
% Execute a shell command for GMT.
%
% IN    cmd      Command string
%
% OPT   silent   Set to true to not echo the command.
%
% Author: Oliver Lemke

if ~iscell(cmd), cmd = {cmd}; end

cmd = cmd(:);

if ~exist('silent', 'var'), silent=false; end

for x = cmd'
    fullcmd = char(x);

    if ~silent, fprintf('%s\n',fullcmd); end

    ret = system(fullcmd);
    if (ret == 127)
        error('Command not found: "%s"', fullcmd)
    end
end

