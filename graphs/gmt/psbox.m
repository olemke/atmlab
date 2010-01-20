function psbox(se)
%% my_psbox
% purpose:
%         Makes boxes
%
%
% Author:Salomon Eliasson
%%

colors = se.plot.psbox.colors;
thick = se.plot.psbox.thick;
psbox = se.plot.psbox.psbox;
region = se.plot.region;
proj = se.plot.plotimage.proj;

a=cell(5,1);
for i = 1:length(thick)
    b = psbox(i,1:2);
    t = psbox(i,3:4);
    
    %stdin
    %% get full coordinates
    a{1}=sprintf('%d %d',b(2),b(1));
    a{2}=sprintf('%d %d',b(2),t(1));
    a{3}=sprintf('%d %d',(t(2)+b(2))/2,t(1));
    a{4}=sprintf('%d %d',t(2),t(1));
    a{5}=sprintf('%d %d',t(2),b(1));
    a{6}=sprintf('%d %d',(t(2)+b(2))/2,b(1));
    a{7}=a{1};

    stdin=[a{1},' M\n',a{2},' D\n',a{3},' D\n',a{4},' D\n',a{5},' D\n',a{6},' D\n',a{7},' D'];
    box = sprintf('echo -e "%s" |',stdin);
    box = sprintf('%s psxy -R%s -J%s -A -O',box,region,proj);
    
    % color and size of box
    
    c = colors{i};
    s = thick{i};
    box = sprintf('%s -W%d/%d/%d/%d',box,s,c(1),c(2),c(3));
    box = sprintf('%s -K>> %s.ps',box,se.filename);
    
    command = box;
    
    [test,message] = system(command);
    if test ~= 0
        error (message)
    end
    fprintf('%s\n',command)
end
