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
% $Author$
% $Date$


BG = [0,0,139]; % background colour (low extreme)
FG = [128,0,0]; % foreground colour (high extreme)

% string format to file 
strannot = isfield(in,'tick_annotations') && ~isempty(in.tick_annotations);
if strannot
    strtot = strcat(prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\t',...
        prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f',' ;%s','\n');
else
    strtot = strcat(prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\t',...
        prtstr,'\t','%3.0f','\t','%3.0f','\t','%3.0f','\n');
end

if ~in.sidebar
   sidebars = [tickval(1) tickval(end)];
   tickval = tickval(2:end-1);
end
nlevels = length(tickval)-1;
if ~isfield(in,'reference')
    ref = (max(tickval)+min(tickval))/2;
else ref = in.reference;
end
% tick closest to reference
reftick = tickval(abs(tickval-ref) == min(abs(tickval-ref))); reftick = reftick(1);

% Get white boxes
if ~isfield(in,'whiteboxes')
   whites = set_white_bars(length(tickval));
else whites = in.whiteboxes;
end

if ref == reftick && mod(nlevels,2)
    whites = whites+1;
end

if mod(whites,2) %odd
    R = ref;
else R = reftick;
end

% find closest surrounding tickval to the chosen reference
bf = tickval(tickval < R);
af = tickval(tickval > R);
n_colored_steps = [length(bf) - mod(whites,2) - floor(whites/2), ...
    length(af) - mod(whites,2) - floor(whites/2)];


inc = 255/(max(n_colored_steps));
% BELLOW ref
bottom_color_incr = 0:inc:255-inc;
bottom_color_incr = bottom_color_incr(end-n_colored_steps(1)+1:end);
% ABOVE ref
top_color_incr = 255-inc:-inc:0;
top_color_incr = top_color_incr(1:n_colored_steps(2));

%% Make the array of colors
if ~in.sidebar
    ctable = zeros(nlevels+2, 3);
    ctable(1,:,:) = BG;
    ctable(end,:,:) = FG;
    tickval = [sidebars(1) tickval sidebars(2)];
    x = 2;
else
    ctable = zeros(nlevels, 3);
    x = 1;
end

%blue
for i = 1:length(bottom_color_incr)
    ctable(x,:) = [bottom_color_incr(i) bottom_color_incr(i) 255];
    x = x+1;
end

%white (refers to number of white boxes)
for i = 1:whites
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

for ii = 1:nlevels+2*~in.sidebar
    if strannot
    fprintf(fid,strtot,tickval(ii),ctable(ii,1),ctable(ii,2),ctable(ii,3),...
        tickval(ii+1),ctable(ii,1),ctable(ii,2),ctable(ii,3),in.tick_annotations{ii});
        
    else
    fprintf(fid,strtot,tickval(ii),ctable(ii,1),ctable(ii,2),ctable(ii,3),...
        tickval(ii+1),ctable(ii,1),ctable(ii,2),ctable(ii,3));
    end
end

% incase the reference is far from the middle of the range, don't use the
% predefined BG or FG
if length(top_color_incr) - length(bottom_color_incr) > 2
    col = top_color_incr(length(bottom_color_incr)+2);
    BG = [col col 255]; 
elseif length(bottom_color_incr) - length(top_color_incr) > 2
    col = bottom_color_incr(end-(length(top_color_incr)+1));
    FG = [255 col col]; 
end

fprintf(fid,'%s\t%3.0f\t%3.0f\t%3.0f\n','B',BG); %Navy
fprintf(fid,'%s\t%3.0f\t%3.0f\t%3.0f\n','F',FG); %Maroon
fprintf(fid,'%s\t%3.0f\t%3.0f\t%3.0f\n','N',128,128,128); %grey

fclose(fid);

%%%%%%%%%%%%
% SUBFUNCTIONS
%   ||||||
%   vvvvvv

function whitebars = set_white_bars(mxwbs)
%% set the number of white boxes in the legend

if mxwbs >= 20
    whitebars =3+mod(mxwbs,2);
elseif mxwbs >= 10
    whitebars =2+~mod(mxwbs,2);
elseif mxwbs >= 6
    whitebars = 1+mod(mxwbs,2);
else
    whitebars = ~mod(mxwbs,2);
end