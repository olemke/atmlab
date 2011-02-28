function filecpt = makepolar(tickval,in)
%%                     makepolar
%
% Puropose: To create a .cpt file based on the 'polar'
%           colourtable that garantees white color around a reference value 
%           (e.g. in.reference = 0)
%
%         
% In:     1) The data contour values
%         2) The format string for a tidy representation
%         3) in  = structure with options (optional)
%
% Out:    file location
%
% What it does:
%             Similar to makecpt -Cpolar, but more fancy. Uses a gradient in
%             the color depending on the number of contours, where the
%             reference is relative to max/min data and the number of boxes
%             that should be white. Gradient is from blue to white to red,
%             and the grandient is equal on both sides of the reference. 
%
% 2011-01-25 created by Salomon Eliasson

% string format to file 
diff = tickval(2)-tickval(1);
b=~isequal(floor(diff),diff);
x=diff;
while x < 0
    b = b+1;
    x = x*10^b;
end
prtstr=sprintf('%%.%df',b);
strtot = strcat(prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\t',...
    prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\n');

% WHITEBOXES
if ~isfield(in,'nwhite')
    nw = ceil((length(tickval)-1)/10);
else
    nw = in.nwhite;
end
% REFERENCE
if ~isfield(in,'reference')
    ref = (max(tickval)+min(tickval))/2;
else ref = in.reference;
end

[BT,TT,nw] = get_white_boxes(tickval,ref,nw);

n_colored_steps = [ length(tickval(1:BT-1)) length(tickval(TT+1:end))];

inc = 255/max(n_colored_steps); % step gradient

ctable = zeros(length(tickval)-1,3);
% BLUE 
for i = 1:BT-1
    ctable(BT-i,:) = abs([255-i*inc,255-i*inc,255]);
end
% WHITE
if ~isempty(BT:TT-1) %empty=nowhite
    ctable(BT:TT-1,:) = repmat(255,nw,3);
end
% RED
for i = 1:length(tickval)-TT
    ctable(TT-1+i,:) = abs([255 255-i*inc,255-i*inc]);
end

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
    BG = in.color_background;
else
    tmp = ctable(1,1);
    if (tmp-2*inc)>0
        BG = [tmp-2*inc tmp-2*inc 255];
    else
        BG = [tmp tmp 255-2*inc];
    end
end
if isfield(in,'color_foreground')
    FG = in.color_foreground;
else
    tmp = ctable(end,end);
    if (tmp-2*inc)>0
        FG = [255 tmp-2*inc tmp-2*inc];
    else
        FG = [255-2*inc tmp tmp];
    end
end
if isfield(in,'color_nan')
    N = in.color_nan;
else
    N = [128 128 128]; %Grey
end
% Background, Foreground, and NaN color
fprintf(fid,'%s\t%3.0f\t%3.0f\t%3.0f\n','B',abs(BG)); %added abs to garantee >0
fprintf(fid,'%s\t%3.0f\t%3.0f\t%3.0f\n','F',abs(FG));
fprintf(fid,'%s\t%3.0f\t%3.0f\t%3.0f\n','N',N);

fclose(fid);

%%%%%%%%%%%%
% SUBFUNCTIONS
%   ||||||
%   vvvvvv

function [BT,TT,nw] = get_white_boxes(tickval,ref,nw)
%% get_white_boxes

% FIND WHITE TICKS
len = 1:length(tickval);
if ~mod(nw,2) %even nwhites
    reftick = len(abs(tickval-ref) == min(abs(tickval-ref)));
    if ~ ( length(reftick)==2 )
        BT = len(reftick)-nw/2;
        TT = len(reftick)+nw/2;
        if BT <= 0, BT = [];end
        if ref > tickval(end), BT = len(end);end
        if TT >= len(end), TT = [];end
        if ref < tickval(1), TT = 1;end
    else
        % right in between 2 ticks
        nw=nw+1;
        disp('Reference is exactly between two ticks. Increasing number of white boxes so that the number is odd instead')
        [BT,TT] = get_white_boxes(tickval,ref,nw);
        return
    end
else % odd nwhites
    if ~ismember(ref,tickval)
        tmp = len(tickval<=ref);
        if ~isempty(tmp)
            BT =  tmp(end);
        else BT = [];
        end
        tmp = len(tickval>=ref);
        if ~isempty(tmp)
            TT = tmp(1);
        else TT = [];
        end
    else
        % right in between 2 ticks
        nw=nw+1;
        disp('Reference is exactly on a tick. Increasing the number of white boxes so that the number is even instead')
        [BT,TT] = get_white_boxes(tickval,ref,nw);
        return
    end
end