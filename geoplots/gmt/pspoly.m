function pspoly(in)
%% my_psbox
% purpose:
%         Makes boxes
%
%
% Author:Salomon Eliasson
%%

colors = in.plot.pspoly.colors;
thick = in.plot.pspoly.thick;
pp = in.plot.pspoly.pspoly;
region = in.plot.region;
proj = in.plot.plotimage.proj;

for i = 1:size(pp,1)    
    %stdin
    %% get full coordinates
    a=cell(size(ppcur,1)+1,1);
    ppcur = pp{i};
    for j = 1:size(ppcur,1)
        a{j}=sprintf('%d %d',ppcur(j,1), ppcur(j,2));
    end
    a{size(ppcur,1)+1}=a{1};
    
    stdin = [a{1},' M\n'];
    for j = 2:size(ppcur,1)
        stdin = [stdin,a{j},' D\n'];
    end
    stdin = [stdin,a{size(ppcur,1)+1},' D'];
    
    command = sprintf('echo -e "%s" |',stdin);
    command = sprintf('%s psxy -R%s -J%s -A',command,region,proj);
    
    if ~isempty(dir(sprintf('%s.ps',in.filename)))
        command = sprintf('%s -O',command);
    end
    
    % color and size of box
    
    c = colors{i};
    s = thick{i};
    command = sprintf('%s -W%d/%d/%d/%d',command,s,c(1),c(2),c(3));
    command = sprintf('%s -K>> %s.ps',command,in.filename);

    exec_gmt_cmd(command)
end
