function exec_gmt_cmd(cmd)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% purpose:  
%       Execute a shell command for GMT
%
% Author: Oliver Lemke
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~iscell(cmd), cmd = {cmd}; end

for x = cmd
    fprintf('%s\n',char(x));
    ret = system(char(x));
    if (ret == 127)
        error(sprintf ('Command not found: "%s"', char(x)))
    end
end

