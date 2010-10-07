function filecpt = makepolar(tickval,prtstr,in)
%%                     makepolar
%
% Puropose: To create a .cpt file based on the 'polar'
%           colourtable that garantess white color around a reference value (e.g. in.reference = 0)
%
%         
% In:     1) The data contour values
%         2) The format string for a tidy representation
%         3) in  = structure with options (optional)
%
% Out:    file location
%
% What it does:
%             In the same mannner as makecpt -Cpolar,
%             except that here the reference 1 or 3 contour levels
%             colored white if the number of contours is
%             odd depending on the number of nlevels. If the number of contour 
%             lines is even the reference 0, 2 boxes will be white.
%
% $Id$

% string format to file 
strtot = strcat(prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\t',...
    prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\n');

nlevels = length(tickval)-1;
if ~isfield(in,'reference')
    ref = (max(tickval)+min(tickval))/2;
else ref = in.reference;
end

% find closest surrounding tickval to the chosen reference
bf = tickval(tickval < ref);
af = tickval(tickval > ref);
tickvalref = [bf(end) af(1)];

% Set #boxes above and bellow reference value and get # white boxes
[n_colored_steps,whitebars] = get_nboxes(tickval,tickvalref,nlevels);

% Make the array of colors for the 'side' with the largest number of boxes
% base the shade of 'blue' or 'red' based on the color shade from the side that
% is longest for an even 'color-slope'

longest = n_colored_steps == max(n_colored_steps);
if longest(1)
    bottom_color_incr = [0:n_colored_steps(1)-1]*255/n_colored_steps(1);
    top_color_incr = bottom_color_incr(n_colored_steps(2):-1:1); 
else
    top_color_incr = [n_colored_steps(2)-1: -1: 0]*255/n_colored_steps(2);
    bottom_color_incr = top_color_incr(n_colored_steps(1):-1:1);
end

%% Make the array of colors

x = 1;
ctable = zeros(nlevels, 3);

%blue
for i = 1:length(bottom_color_incr)
    ctable(x,:) = [bottom_color_incr(i) bottom_color_incr(i) 255];
    x = x+1;
end

%white
for i = 1:whitebars
    ctable(x,:) = [255 255 255];
    x = x+1;
end

%red
for i = 1:length(top_color_incr)
    ctable(x,:) = [255 top_color_incr(i) top_color_incr(i)];
    x = x+1;
end

%% Make a cptfile out of it

filecpt = 'mypolar.cpt';
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

%%%%%%%%%%%%
% SUBFUNCTIONS
%   ||||||
%   vvvvvv

function [n_colored_steps,whitebars] = get_nboxes(tickval,tickvalref,nlevels)
%% Set #boxes above and bellow white boxes and get # white boxes

% middle: mostly redundent but sometimes tickvalref consists of 2 values
middle = (tickvalref(end)+tickvalref(1))/2;  

% # boxes on both sides of the ref
bboxes = sum( tickval < middle);
tboxes = sum( tickval > middle);

% number of white boxes in legend
whitebars = min([set_white_bars(bboxes-1), set_white_bars(tboxes-1)]);

% find the number of colored steps on both sides of the reference
n_colored_steps = [bboxes tboxes]-whitebars;

% for mod(nlevels,2)==0 we need more whitebars
whitebars = nlevels - sum(n_colored_steps); 

function whitebars = set_white_bars(mxwbs)
%% set the number of white boxes in the legend
if mxwbs >= 11
    whitebars =2;
elseif mxwbs >=1
    whitebars = 1;
else
    whitebars = 0;
end