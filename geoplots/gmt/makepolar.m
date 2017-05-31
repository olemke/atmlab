function filecpt = makepolar(tickval,in)
% MAKEPOLAR create a .cpt-file based on the 'polar' but with extra options
%
% PURPOSE: To create a .cpt file based on the 'polar'
%           colourtable that garantees white color around a reference value
%           (e.g. in.reference = 0)
%
%
% IN      tickval     [%f,%f,etc]        The data contour values
%         in          struct             options here (see help gmt_plot)
%
% Out:    filecpt     %s                 fullpath to colortable-file
%
% What it does:
%             Similar to makecpt -Cpolar, but more fancy. Uses a gradient in
%             the color depending on the number of contours, where the
%             reference is relative to max/min data and the number of boxes
%             that should be white. Gradient is from blue to white to red,
%             and the grandient is equal on both sides of the reference.
%
% Created by Salomon Eliasson
% $Id$

% string format to file
diff = tickval(2)-tickval(1);
b=~isequal(floor(diff),diff);
x=diff;
while x < 0
    b = b+1;
    x = x*10^b;
end
prtstr=sprintf('%%g',b); %#ok<CTPCT> % Don't change this!
strtot = strcat(prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\t',...
    prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\n');

% REFERENCE
if ~isfield(in.ctable,'reference')
    ref = (max(tickval)+min(tickval))/2;
else ref = in.ctable.reference;
end

[BT,TT,nw] = get_white_boxes(tickval,ref,in);

n_colored_steps = [BT TT];

N = max(n_colored_steps);
inc = 255/N; % step gradient
vect = 255-(1:N)*inc;

ctable = zeros(length(tickval)-1,3);

% BLUE
tmp = abs([vect(BT:-1:1);vect(BT:-1:1);repmat(255,1,BT)])';
ctable(1:BT,:) = tmp;

% WHITE
ctable(BT+1:BT+nw,:) = repmat([255,255,255],nw,1);

% RED
tmp = abs([repmat(255,1,TT);vect(TT:-1:1);vect(TT:-1:1)])';
ctable(BT+nw+1:end,:) = tmp(end:-1:1,:);


%% Make a cptfile out of it

filecpt = 'mypolar.cpt';
fid = fopen(filecpt,'w');
%##################### HEADER ###############################
fprintf(fid,'%s\t%s\n','#cpt file created by:','makepolar.m');
fprintf(fid,'%s\n%s\n','#COLOR_MODEL = RGB','#');
%############################################################

for ii = 1:length(tickval)-1
    fprintf(fid,strtot,tickval(ii),ctable(ii,1),ctable(ii,2),ctable(ii,3),...
        tickval(ii+1),ctable(ii,1),ctable(ii,2),ctable(ii,3));
end

% Set Background and forground colors base on the last color minus 3 times
% the gradient of color change used in ctable
if isfield(in,'forcedColorBack')
    BG = sscanf(in.color_background,'%f/%f/%f');
else
    BG = max([ctable(1,:)-[5,5,3]*inc;0,0,0],[],1);
end
if isfield(in,'forcedColorFore')
    FG = sscanf(in.color_foreground,'%f/%f/%f');
else
    FG = max([ctable(end,:)-[3,5,5]*inc;0,0,0],[],1);
end
if isfield(in,'forcedColorNaN')
    N = sscanf(in.color_nan,'%f/%f/%f');
else
    N = [128 128 128]; %Grey
end
% Background, Foreground, and NaN color
fprintf(fid,'%s\t%3.0f\t%3.0f\t%3.0f\n','B',abs(BG)); %added abs to garantee >0
fprintf(fid,'%s\t%3.0f\t%3.0f\t%3.0f\n','F',abs(FG));
fprintf(fid,'%s\t%3.0f\t%3.0f\t%3.0f\n','N',abs(N));

fclose(fid);

end
%%%%%%%%%%%%
% SUBFUNCTIONS
%   ||||||
%   vvvvvv



function [BT,TT,nw] = get_white_boxes(tickval,ref,in)
%% get_white_boxes

if ~isfield(in.ctable,'nwhite')
    in.ctable.nwhite=ceil(in.nlevels/10);
end

centers = tickval(2:end)-(tickval(2:end)-tickval(1:end-1))/2;

for i = 1:length(tickval)-1
    % I want to find inbetween where the reference is
    
    if centers(i)<ref, below=i;end
    if centers(i)>ref, above=i;break;end
end


if (in.ctable.nwhite>0) && exist('above','var')
    
    windex=below:above;
    while length(windex)<in.ctable.nwhite
        if (windex(1)-1)<1 || (windex(end)+1)==in.nlevels
            break
        end
        windex = [windex(1)-1,windex,windex(end)+1]; %#ok<AGROW>
    end
    nw = length(windex);
    
    if nw ~= in.ctable.nwhite
        logtext(1,['Changed number of white boxes from %i to %i ',...
            'to match the tick better together with reference = %f\n'],in.ctable.nwhite,nw,ref);
    end
    
    %if sum(nearref)>nw; nw=nw+1; end
    
    % BT bottom ticks
    BT = length(1:windex(1)-1);
    % TT top ticks
    TT = length(windex(end)+1:length(centers));
else
    BT = sum(centers<ref);
    TT = sum(centers>ref);
    nw = 0;
end

end