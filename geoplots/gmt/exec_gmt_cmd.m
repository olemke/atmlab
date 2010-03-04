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
    
    if atmlab('GMT_CUSTOM_PATH')
        fullcmd = ['PATH=$PATH:' atmlab('GMT_CUSTOM_PATH') ' ' char(x)];
    else
        fullcmd = char(x);
    end
    ret = system(fullcmd);
    if (ret == 127)
        error('Command not found: "%s"', char(x))
    end
end

