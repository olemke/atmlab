function commands = pspoly(in)
% PSPOLY Make polygons to plot with GMT
%
% IN
%         in       struct   options here (see help gmt_plot)
%         command  cell     cell of string commands for systemcall
%
% OUT     command  cell     cell of string commands for systemcall
%
% Created by Oliver Lemke
% $Id$

colors = in.pspoly.color;
thick = in.pspoly.thick;
pp = in.pspoly.coord;

commands = cell(1,length(pp));

for i = 1:length(pp)    
    %stdin
    %% get full coordinates
    ppcur = pp{i};
    a=cell(size(ppcur,1)+1,1);
    for j = 1:size(ppcur,1)
        a{j}=sprintf('%g %g',ppcur(j,1), ppcur(j,2));
    end
    a{size(ppcur,1)+1}=a{1};
    
    stdin = [a{1},' M\n'];
    for j = 2:size(ppcur,1)
        stdin = [stdin,a{j},' D\n'];
    end
    stdin = [stdin,a{size(ppcur,1)+1},' D'];
    
    txtfile = ['psxy' num2str(i)];
    fid=fopen(txtfile,'w');
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid,stdin);
    
    if strcmp(in.proj(1), 'Q')
        straight = '-A';
    else
        straight = '';
    end
    % -A draw straight lines. Otherwise they are great archs
    
    commands{i} = sprintf('gmt psxy %s -R -J %s -W%s,%s -K -O %s >> %s.ps',...
        txtfile,straight,num2str(thick{i}),colors{i},in.plotPlacement,in.filename);

end