function exec_gmt_cmd(cmd)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% purpose:  
%       Execute a shell command for GMT
%
% Author: Oliver Lemke
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~iscell(cmd), cmd = {cmd}; end

for x = cmd'
    fullcmd = char(x);

    fprintf('%s\n',fullcmd);

    ret = system(fullcmd);
    if (ret == 127)
        error('Command not found: "%s"', fullcmd)
    end
end

