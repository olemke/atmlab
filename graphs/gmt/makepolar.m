function filecpt = makepolar(tickval,prtstr)
%%                     makepolar
%
% Puropose: To create a .cpt file based on the 'polar'
%           colourtable
%
% Indata: 1) The data contour values
%         2) The format string for a tidy representation
%
% Out:    The file location of:
%         1) The colour table
%
% What it does:
%             1) In the same mannner as makecpt -Cpolar,
%                 except that here the reference 3 contour levels
%                 are colored white if the number of contours is
%                 odd. If the number of contour lines is even the
%                 reference 2 boxes will be white. If nlevels < 10 the
%                 the reference box is white for odd numbers and none
%                 are white for even
%
%
% Author: Salomon Eliasson


if nargin < 1
    error('Need to pass data contour values')
end
if nargin < 2
    prtstr = '%3.2f';
end

strtot = strcat(prtstr,'\t','%d','\t','%d','\t','%d','\t',...
    prtstr,'\t','%d','\t','%d','\t','%d','\n');

nlevels = length(tickval)-1;

if mod(nlevels,2) == 1 && nlevels >= 11 % odd  number of contours

    zm = 5; %number of white boxes in the middle
    
    steps=(nlevels -2 -zm)/2; % increments between blue->white (white->red)
    
elseif mod(nlevels,2) == 1 && nlevels < 11 %odd
    zm = 3;
    steps=(nlevels -2 -zm)/2;
elseif mod(nlevels,2) == 0 && nlevels >= 10 %even
    zm = 4;
    steps=(nlevels -2 -zm)/2;
elseif mod(nlevels,2) == 0 && nlevels < 10 %even
    zm = 2;
    steps=(nlevels -2 -zm)/2;
end

% from blue to white and from white to red
beg=[0 0 255];
endd=[255 0 0];
ctable=zeros(nlevels,3,'uint16');
ctable(1,:)=beg;
for i=1:steps
    ctable(i+1,:)=beg+[i * 255/(steps+1),i * 255/(steps+1), 0];
end
ctable(i+2:i+2+zm-1,:) = 255;
k=i+2+zm;
for i=1:steps
    ctable(k,:)=beg+[255,255-i*255/(steps+1), -i*255/(steps+1)];
    k=k+1;
end
ctable(end,:)=endd;

%print COLORBAR to file
filecpt = 'color_polar.cpt';
fid = fopen(filecpt,'w');

%##################### HEADER ###############################
fprintf(fid,'%s\t%s\n','#cpt file created by:','makepolar.m');
fprintf(fid,'%s\n%s\n','#COLOR_MODEL = RGB','#');
%############################################################

for ii = 1:nlevels
    fprintf(fid,strtot,tickval(ii),ctable(ii,1),ctable(ii,2),ctable(ii,3),...
        tickval(ii+1),ctable(ii,1),ctable(ii,2),ctable(ii,3));
end

%prefined bachground and foreground colors
fprintf(fid,'%s\t%i\t%i\t%i\n','B',0,0,139); %Navy
fprintf(fid,'%s\t%i\t%i\t%i\n','F',139,28,98); %Maroon4
fprintf(fid,'%s\t%i\t%i\t%i\n','N',128,128,128); %grey

fclose(fid);
