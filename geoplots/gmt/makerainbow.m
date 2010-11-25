function[filecpt] = makerainbow(tickval,prtstr,ptype)

%%%%%%%%%%%%%%%%%%%%% makerainbow %%%%%%%%%%%%%%%%%%%%%%%
%
% Puropose: To create a .cpt file based on the 'rainbow'
%           colourtable
%
% Indata: 1) The data contour values
%         2) The format string for a tidy representation
%         3) The way the data contours were generated
%
% Author: Salomon Eliasson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    ptype = '';
end
if nargin < 2
    prtstr = '%3.2f';
end
if nargin < 1
    disp(' Error: Need to pass data contour values')
end

%print COLORBAR to file
filecpt = sprintf('color_rainbow_%s.cpt',ptype);
fid = fopen(filecpt,'w');

%##################### HEADER ###############################
fprintf(fid,'%s\t%s\n','#cpt file created by:','makerainbow.m');
fprintf(fid,'%s\t%s\n','#For the following contour type:',ptype);
fprintf(fid,'%s\n%s\n','#COLOR_MODEL = +HSV','#'); %currently only hew rainbow
%############################################################
strtot = strcat(prtstr,'\t','%d','\t','%d','\t','%d','\t',...
    prtstr,'\t','%d','\t','%d','\t','%d','\n');

nlevels = length(tickval);
ctable = 300:-300/nlevels: 0;

for ii = 1:nlevels-1
    fprintf(fid,strtot,tickval(ii),round(ctable(ii)),1,1,...
        tickval(ii+1),round(ctable(ii)),1,1);
end

%prefined background and foreground colors
fprintf(fid,'%s\t%i\t%i\t%i\n','B',320/360,61/100,65/100); %Maroon
fprintf(fid,'%s\t%i\t%i\t%i\n','F',1,1,1); %red
fprintf(fid,'%s\t%i\t%i\t%i\n','N',0,0,0.5); %grey
fclose(fid);
