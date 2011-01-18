function filecpt = hardcoded_colors(tickval,prtstr,in)
%% hardcoded_colors
%
% Assume RGB input colors
% IN: 
%     tickval: tickvales. length = nlevels+1
%     prtstr : format string for gridded values
%     colors : cell of RGB colors. The ist value and last value correspond
%     to the foreground and background colors respectively. For 3 nlevels with black F and white B:
%              e.g {[0 0 0],[255 0 0],[0 255 0],[0 0 255],[255 255 255]};
%     NaNs are grey
%
% 13/12-2010
% Salomon Eliasson

colors = in.ctable_colors;

% string format to file 
strtot = strcat(prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\t',...
    prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\n');

filecpt = 'own_colortable.cpt';
fid = fopen(filecpt,'w');

fprintf(fid,'%s\n%s\n','#COLOR_MODEL = RGB','#');

s = in.sidebar; %make room in colors{} for sidebar color if it exists

for ii = 1:length(tickval)-1
    if strannot
        fprintf(fid,strtot,tickval(ii),colors{ii+s}(1),colors{ii+s}(2),colors{ii+s}(3),...
            tickval(ii+1),colors{ii+s}(1),colors{ii+s}(2),colors{ii+s}(3),in.tick_annotations{ii});
    else
        fprintf(fid,strtot,tickval(ii),colors{ii+s}(1),colors{ii+s}(2),colors{ii+s}(3),...
            tickval(ii+1),colors{ii+s}(1),colors{ii+s}(2),colors{ii+s}(3));
    end
end

%prefined background and foreground colors
fprintf(fid,'%s\t%i\t%i\t%i\n','B',colors{1}(1),colors{1}(2),colors{1}(3));
fprintf(fid,'%s\t%i\t%i\t%i\n','F',colors{end}(1),colors{end}(2),colors{end}(3));
fprintf(fid,'%s\t%i\t%i\t%i\n','N',128,128,128); %grey (For NaNs)

fclose(fid);