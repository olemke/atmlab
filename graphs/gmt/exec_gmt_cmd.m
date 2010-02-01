function exec_gmt_cmd(cmd)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% purpose:  
%       Execute a shell command for GMT
%
% Author: Oliver Lemke
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~iscell(cmd), cmd = {cmd}; end

for x = cmd'
    fprintf('%s\n',char(x));
    fullcmd = char(x);
    if atmlab('GMT_CUSTOM_PATH')
        fullcmd = ['PATH=$PATH:' atmlab('GMT_CUSTOM_PATH') ' ' fullcmd];
    end
    ret = system(fullcmd);
    if (ret == 127)
        error(sprintf ('Command not found: "%s"', char(x)))
    end
end

