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
prtstr=sprintf('%%g',b); % Don't change this!
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
len = size(tmp,1);
ctable(1:len,:) = tmp;

% WHITE
ctable(len+1:len+nw,:) = repmat([255,255,255],nw,1);
len = len+nw;

% RED
tmp = abs([repmat(255,1,TT);vect(TT:-1:1);vect(TT:-1:1)])';
ctable(len+1:end,:) = tmp(end:-1:1,:);


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

% Set Background and forground colors base on the last color minus 2 times
% the gradient of color change used in ctable
if isfield(in,'color_background')
    BG = sscanf(in.color_background,'%f/%f/%f');
else
    tmp = ctable(1,1);
    if (tmp-2*inc)>0
        BG = [tmp-2*inc tmp-2*inc 255];
    else
        BG = [tmp tmp 255-2*inc];
    end
end
if isfield(in,'color_foreground')
    FG = sscanf(in.color_foreground,'%f/%f/%f');
else
    tmp = ctable(end,end);
    if (tmp-2*inc)>0
        FG = [255 tmp-2*inc tmp-2*inc];
    else
        FG = [255-2*inc tmp tmp];
    end
end
if isfield(in,'color_nan')
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

% WHITEBOXES
if ~isfield(in.ctable,'nwhite')
    nw = ceil((length(tickval)-1)/10);
    input = false;
else
    nw = in.ctable.nwhite;
    input=true;
end

assert(nw<length(tickval)-1,...
    ['gmtlab:' mfilename ':input'],'number of white boxes (%g) exceedes nlevels (%g)',...
    nw,length(tickval)-1)


% ADJUST nwhite if ref is on a contour line
if ismember(ref,tickval) && mod(nw,2) 
    % if ref is on one of the edges and nwhite is odd, increase nwhite by 1
    nw = nw+1;
    if input
        warning(['gmtlab:' mfilename ':badInput'],...
            '%s %s nwhite = %.0f to nwhite = %.0f','Reference value is exactly on a contour level,',...
            'i.e in.ctable.nwhite must be an even number. Increasing ',in.ctable.nwhite,nw);
    end
end

% ADJUST nwhite if ref is inbetween contour lines
if ref < tickval(1) || ref > tickval(end)
    warning(['gmtlab:' mfilename ':badInput'],'Reference value is outside the range of tick values')
    
    if ref < tickval(1)
        refnew = tickval(1);
    else
        refnew = tickval(1);
    end 
    logtext(1,'Changed bad reference value ''%d'' to ''%d'' \n',ref,refnew)
    ref=  refnew;
end

if ~ismember(ref,tickval) && ~mod(nw,2) 
    % if ref is in between the edges and nwhite is even, decrease by 1
    nw = nw-1;
    if input
        warning(['gmtlab:' mfilename ':badInput'],...
            '%s %s nwhite = %.0f to nwhite = %.0f','Reference value is inbetween contour levels,',...
            'i.e in.ctable.nwhite must be an odd number. Decreasing ',in.ctable.nwhite,nw);
    end
end

whitedomain = (nw + mod(nw,2))/2;   

% BT bottom ticks
BT = sum(tickval <= ref ) -whitedomain;
% TT top ticks
TT = sum(tickval >= ref ) -whitedomain;

if TT < 0
    % That means that there are less than nw/2 tickvalues higher than the
    % reference. Therefore, I need to adjust nw
    nw = nw+TT;
    TT = 0;
    BT = BT-1;
end
if BT < 0
    % That means that there are less than nw/2 tickvalues below the
    % reference. Therefore, I need to adjust nw
    nw = nw+BT;
    BT = 0;
    TT = TT-1;
end

% remove white boxes if the total number is wrong
if (BT+TT+nw - (length(tickval)-1)) > 0
    dif = BT+TT+nw - (length(tickval)-1);
    while dif > 0
        if nw>0&&dif>0; nw=nw-1;dif=dif-1;end
        if BT>0&&dif>0; BT=BT-1;dif>0;dif=dif-1;end
        if TT>0&&dif>0; TT=TT-1;dif>0;dif=dif-1;end
    end
end

if (BT+TT+nw - (length(tickval)-1)) < 0
    dif = -1 * (BT+TT+nw - (length(tickval)-1));
    % just increase white until it's the right number
    while dif < 0
        nw=nw+1;
        dif=dif+1;
    end
end
assert(BT+TT+nw == length(tickval)-1,['gmtlab:' mfilename ':Bug'],...
    'BT+TT+nw ~= length(tickval)-1')

end