function command = pslocations(in)
% PSLOCATIONS Adds location markers to a GMT plot.
%
% IN
%         in       struct   options here (see help gmt_plot)
%         command  cell     cell of string commands for systemcall
%
% OUT     command  cell     cell of string commands for systemcall
%
% Created by Oliver Lemke & Salomon Eliasson
% $Id$

default.symbol = 'c'; %circle
default.symbolsize = '5p';
default.symbolfill = '255/255/255';
default.symbolcolor = '255/255/255';
default.justify = 'CM';
default.fontsize = '10p';

command = cell(1,2*length(in.locations));
j = 1;
for i = 1:length(in.locations)
    
    tmp = optargs_struct(in.locations(i),default);
    
    if ~isempty(tmp.symbol)
        %% Make the symbol if it is wanted
        
        % Make the text file containing the coordinates
        txtfile = ['symbol' num2str(i)];
        fid=fopen(txtfile,'w'); cleanup = onCleanup(@() fclose(fid));
        
        fprintf(fid,'%g\t%g\t',tmp.lon,tmp.lat);
        
        command{j} = sprintf('gmt psxy %s -R -J -S%s%s -G%s -Wthinner,%s %s -O -K >> %s.ps',...
            txtfile,tmp.symbol,tmp.symbolsize,tmp.symbolfill,tmp.symbolcolor,in.plotPlacement,in.filename);
        j = j+1;
    end
    if isfield(tmp,'text') && ~isempty(tmp.text)
        %% Print some text on the map
        if isfield(in,'pstext')
            tmpstruct = catstruct(rmfield(in,'pstext'),struct('pstext',tmp));
        else
            tmpstruct = catstruct(in,struct('pstext',tmp));
        end
        command{j} = pstext(tmpstruct,i);
        j = j+1;
    end
end
command = command(1:j-1);