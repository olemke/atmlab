function filecpt = hardcoded_colors(tickval,prtstr,colors)
%% hardcoded_colors
%
% Assume RGB input colors
% IN: 
%     tickval: tickvales. length = nlevels+1
%     prtstr : format string for gridded values
%     colors : cell of RGB colors. The last 2 values correspond to Background
%              and Foreground colors. For 3 nlevels with black F and white B:
%              e.g {[255 0 0],[0 255 0],[0 0 255],[0 0 0],[255 255 255]}

% string format to file 
strtot = strcat(prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\t',...
    prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\n');

filecpt = 'own_colortable.cpt';
fid = fopen(filecpt,'w');

fprintf(fid,'%s\n%s\n','#COLOR_MODEL = RGB','#');

for ii = 1:length(tickval)-1
    fprintf(fid,strtot,tickval(ii),colors{ii}(1),colors{ii}(2),colors{ii}(3),...
        tickval(ii+1),colors{ii}(1),colors{ii}(2),colors{ii}(3));
end

%prefined background and foreground colors
fprintf(fid,'%s\t%i\t%i\t%i\n','B',colors{end-1}(1),colors{end-1}(2),colors{end-1}(3));
fprintf(fid,'%s\t%i\t%i\t%i\n','F',colors{end}(1),colors{end}(2),colors{end}(3));
fprintf(fid,'%s\t%i\t%i\t%i\n','N',128,128,128); %grey (For NaNs)

fclose(fid);