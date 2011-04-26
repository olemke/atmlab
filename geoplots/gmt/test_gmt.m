function [info, files] = test_gmt(in)
% TEST_GMT To test various aspecs of gmt_plot
%
% PURPOSE: To test various aspecs of gmt_plot. Especially before commiting
%          changes
%
% USAGE: [info,files] = test_gmt(in)  
%
% IN   structure of arguments to be additionally used 
%      in the test_gmt call/s. I.e. it will use the default values for each
%      test and the addional options added by the user (which have precedence).
%      -----------
%      in.test: If you only want to run a subset of tests, e.g. in.test =
%      [1,3,4] runs tests 1,3,4. The default behaviour is to run all tests ([1:7])
%
%      -----------
%
%
% OUT: files = cellarray of paths to created figures
%      info  = cellarray of information about each test. The information is
%              also displayed at the end of the run.
%
% created by Salomon Eliasson
% $Id$

files = {}; info = {};
if ~exist('in','var'); in=struct([]); end

% SET some defaults
default.test      = 1:7; % which tests to do (default=all)
default.verbosity = gmtlab('VERBOSITY');
od = isfield(in,'outdir');
default.outdir    = gmtlab('OUTDIR');
in = optargs_struct(in,default); 
assert(isnumeric(in.test),sprintf('atmlab:%s:bad_input',mfilename),...
    'in.test must be numeric')

% for the final pdfs
if isequal(in.test,1:7)
    in.cols = [2 2 2 1 3 1];
else
    in.cols = 2;
end

if ~ischar(in.outdir)
    in.outdir = tempdir;
    in.outdir = in.outdir(1:end-1);
end 

warning('off','gmtcatstruct:DuplicatesFound') %I'm intentially doing this often

[gridded,ungridded] = dummy_data;

%TEST: polar, reference, nlevels, sidebar
[files,info]               = TEST1(in,gridded,files,info);

%TEST: title, unit (gridded and ungridded)
[files,info]               = TEST2(in,gridded,ungridded,files,info);

%TEST: sidebar, nan, projection, center
[files{end+1},info{end+1}] = TEST3(in,gridded); 

%TEST: contours, nlevels, annotation format, xunit
[files{end+1},info{end+1}] = TEST4(in);         

%TEST: custom color table, header_size, map_width, grid lines
[files{end+1},info{end+1}] = TEST5(in,gridded); 

%TEST: locations, nodata, regions, map details
[files,info]               = TEST6(in,files,info);          

%TEST: pspolygon, basemap_axis
[files{end+1},info{end+1}] = TEST7(in);

% PUT all figure in one pdf
files{end+1} = combine_pdfs(files,...
    struct('filename','all_tests','cols',in.cols,'valign','b'));

% DISPLAY combined plot
exec_gmt_cmd(sprintf('%s %s&',gmtlab('pdfviewer'),files{end}));

files = files(~cellfun('isempty',files));
info = info(~cellfun('isempty',info));

% DISPLAY information about the tests
disp(' ')
disp(' ')
cellfun(@disp,info,'uniformoutput',false)
disp('Look at help gmt_plot for more detailed descriptions of options ')
disp('specified here. I suggest looking at the call for each test in test_gmt')
disp('if you want to see an example on how to create these figures.')
disp('All the tests where merged onto one pdf using combine_pdfs.m.')

warning('on','gmtcatstruct:DuplicatesFound')

if ~od && ~ischar(gmtlab('OUTDIR'))
    a = sprintf('Files are saved in your tempdir (%s)',in.outdir);
    in.outdir = in.outdir(1:end-1);
    b = 'It is better to set a default directory.';
    c = 'I.e by setting gmtlab(''OUTDIR'',''<Somewhere>''), e.g. in startup.m';
    d = 'Setting this, or inputting a valid directory: in.outdir will suppress this message.';
    warning('warning:input:outdir','%s\n%s\n%s\n%s',a,b,c,d)
end

%%%%%%%%%%%%%%%%%
% SUB FUNCTIONS
%    |||||||
%    vvvvvvv

function [gridded,ungridded] = dummy_data
%% dummy data
% GENERATE MAIN DATA 

gridded.lat    = -90:90;
gridded.lon    = -180:180;
gridded.data   = zeros(length(gridded.lat),length(gridded.lon));
ungridded.data = zeros(length(gridded.lat)*length(gridded.lon),1);
ungridded.lon  = zeros(size(ungridded.data));
ungridded.lat  = zeros(size(ungridded.data));
ug=1;
for j=0:180
    for i=0:360
        gridded.data(j+1,i+1)=sin(((i+180)/360)*pi+pi/2)* cos((j/180)*pi+pi/2)*100+160;
        
        ungridded.data(ug) = gridded.data(j+1,i+1);
        ungridded.lat(ug)  = j - 90;
        ungridded.lon(ug)  = i - 180;
        ug = ug+1;
    end
end


function [files,info]        = TEST1(in,gridded,files,info)
%% TEST: Difference plot, reference=0, nlevels, sidebar
t=1;
if ~ismember(t,in.test), return, end %then don't do this test

test.display = false; % no just put them all in one pdf using conbine_pdfs
%% Test 1a


gridded.data = gridded.data-200;  % for difference 
test.ctable = 'mypolar';
test.reference = 0;
test.legend.sidebar = 3; % both above and below
test.header_offset = -.5; %move the header down a bit because of smaller header size
test.basemap_axis = 'neSW';
test.title = 'Diff plot,ref=0,sidebar=3 (above and below)';
a0 = sprintf('Test%.0fa',t);
test.filename = a0;
files{end+1} = gmt_plot(catstruct(gridded,test,in),'data');

a = ' demonstrates the mypolar-colortable which is similar to polar.cpt';
b = 'Using in.ctable=''mypolar'' you can define where the reference value';
c = 'should be (here in.reference = 0). The white color is centered around this value.';
d = 'in.basemap_axis = ''nSeW'' is tested, and means that the south (S) and west(W)';
e = 'axes are labelled. in.sidebar = 3 is tested and means that triangles';
f = 'above and below legend-range are shown to indicate the color of data outside the datarange';
g = 'defined by in.datarange = [min max]. The title offset is set to -0.5 here (moving it down)';
h = 'using in.header_offset = -0.5; See help gmt_plot for more details on these options';
info{end+1} = sprintf('%s%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',a0,a,b,c,d,e,f,g,h);

test.legend.sidebar = 2; % above only
test.basemap_axis = 'NEsw';
test.nlevels = 15; 
test.nwhite = 6;
test.header_size = 20;
test = rmfield(test,'header_offset');
test.title = 'Diff plot,nlevels=15,nwhite=6,sidebar=2 (above only),header';
a0 = sprintf('Test%.0fb',t);
test.filename = a0;
files{end+1} = gmt_plot(catstruct(gridded,test,in),'data');

a = ' demonstrates that you can change the number of intervals that are';
b = 'colored white around the reference value when using the mypolar-colortable,';
c = 'here in.nwhite = 6. You can also change the number of data intervals ';
d = '(here in.nlevels = 15), change in.headersize (here in.headersize = 20)';
e = 'or decide to only have the sidebar for values above the datarange (here in.sidebar=2)';
info{end+1} = sprintf('%s%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',a0,a,b,c,d,e);

function [files,info] = TEST2(in,gridded,ungridded,files,info)
%% TEST: title, unit (gridded and ungridded)
t = 2;
if ~ismember(t,in.test), return, end %then don't do this test
test.display = false; % no just put them all in one pdf using conbine_pdfs

test.title        = 'gridded: title², unit';
test.unit         = 'kg/m²';
test.basemap_axis = 'neSW'; 
test.legend.position = '9.35i/2i/3i/.5i'; %('x-displacement/y-displacement/height/width')
test.legend.tick_spacing = 25;
a0 = sprintf('Test%.0fa',t);
test.filename = a0;
files{end+1} = gmt_plot(catstruct(gridded,test,in),'data');

a = ' demonstrates that you can include some special';
b = 'characters in in.title and in.unit. This test uses ';
c = 'gridded data, where size(data) = [length(lat),length(lon)]';
d = 'You can also change the size and position of the legend';
e = '(here in.legend.position = ''9.35i/2i/3i/.5i''; %(''x-displacement/y-displacement/height/width''))';
f = 'Here the tick-interval is fixed to every 25th level using in.legend.tick_spacing = 25';
info{end+1} = sprintf('%s%s\n%s\n%s\n%s\n%s\n%s\n',a0,a,b,c,d,e,f);

test = rmfield(test,'legend');
test.title           = 'ungridded: legend, coastlines';
test.coast.width     = 1;
test.coast.color     = '255/255/255';
a0 = sprintf('Test%.0fb',t);
test.filename        = a0;
test.unit            = 'kg/m²';
files{end+1} = gmt_plot(catstruct(ungridded,test,in),'data');

a = ' demonstrates the same data as Test2a except in an ungridded form';
b = 'isequal(size(in.data),size(in.lat),size(in.lon))==1. This is e.g. good';
c = 'for plotting satellite granule data directly. You can also change the';
d = 'color of the coastlines, e.g. in.coast.color = ''255/255/255.''';
info{end+1} = sprintf('%s%s\n%s\n%s\n%s\n',a0,a,b,c,d);

function [file,info] = TEST3(in,gridded)
%% TEST: sidebar, nan, projection, center

t = 3;
if ~ismember(t,in.test), file='';info='';return, end %then don't do this test
test.display = false; % no just put them all in one pdf using conbine_pdfs
gridded.data(20:40,20:80) = NaN;
test.title      = 'upper sidebar, NaN, Hammer projection, center';
test.projection = 'H';      % hammer
test.center     = 180;      % Center map at given center longitude
test.datarange  = [160,250];% displayed value range. Sidebar triangles shown for data outside range.
a0 = sprintf('Test%.0f',t);
test.filename = a0;
file = gmt_plot(catstruct(gridded,test,in),'data');

a = ' demonstrates the Hammer projection (using in.projection = ''H''),';
b = 'one of many available projections. The test also demonstrates that you can';
c = 'easily change the center of the projection to e.g. 180E using in.center = 180.';
d = 'The grey region in the map indicates NaN values, and an extra NaN color box';
e = 'is automatically added below the vertical legend. You can suppress the extra';
f = 'NaN-legend using in.nanlegend = false. The upper sidebar is automatically shown';
g = 'if there are data larger than in.datarange(2), given via in.datarange = [v1,v2].';
h = 'The color for these values can be changed using';
i = 'in.color_foreground (default is ''255/255/255'' (white))';
info = sprintf('%s%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',a0,a,b,c,d,e,f,g,h,i);

function [file,info] = TEST4(in)
%% TEST: contours, nlevels, annotation format, xunit

t = 4;
if ~ismember(t,in.test), file=''; info = ''; return, end %then don't do this test
test.display = false; % no just put them all in one pdf using conbine_pdfs

test.lat = -90:90;
test.lon = -180:180;
for j = test.lat
    for i = test.lon
        test.data(j+91,i+181) = ((0.1*sin((j+91)/18*pi))+sin((j+91)/180*pi))*(0.1*cos(i/36*pi)+cos(i/360*pi));
    end
end

test.title = 'contours, HSV colours, horiz. legend';
test.unit = 'No unit';
test.xunit = 'No unit either';
test.projection = 'H';
test.nlevels = 10;
test.tick_annotation_format = '%.1lf';
test.legend.orientation = 'h';
test.contourline.spacing=0.1;
test.contourline.range=[0 1];
test.contourline.linethick=1;
test.contourline.more='-T1c/0.001c:LH';
test.datarange = [0, 1];
test.color_background = '255/0/0';
test.color_foreground = '255/255/0';
test.colorrange.colors = {{0,'0/1/1'},{1,'60/1/1'}};
test.colorrange.color_model = 'HSV';
test.nlevels = 5;
a0 = sprintf('Test%.0f',t);
test.filename = a0;
file = gmt_plot (catstruct(test,in), 'data');

a = ' demonstrates contour maps (see contour options in help gmt_plot), ';
b = 'where you can optionally choose to show highs and lows in the of the data.';
c = 'It also demonstrated that you can have x and y-labels';
d = '(in.xunit=''no unit either'' and in.unit=''no unit'') around the legend';
e = 'Using the custom colortable (in.colorrange) you can also use';
f = 'in.colorrange.color_model = ''HSV'' instead of the default ''RGB''';

info = sprintf('%s%s\n%s\n%s\n%s\n%s\n%s\n',a0,a,b,c,d,e,f);

function [file,info] = TEST5(in,gridded) 
%% TEST: custom color table, header_size, map_width, grid lines, region
t = 5;

if ~ismember(t,in.test), file=''; info = ''; return, end %then don't do this test
test.display = false; % no just put them all in one pdf using conbine_pdfs

% Add some annotations some intervals.
if ~isfield(in,{'stepsize','nlevels'}) 
    % assuming we have 20 levels, test the following
    tmp = cell(1,20);
    tmp{1} = 'blue'; tmp{6} = 'light blue'; tmp{10} = 'green'; tmp{15} = 'black'; tmp{20} = 'red';
    test.legend.tick_annotations = tmp; 
end
test.title = 'custom legend and sub-region';
test.ticks = '30g30/15g15'; % annotations (deg) on major lines (e.g 40 xaxis,20 yaxis)
                            % and plot minor lines (e.g 20 xaxis & yaxis)
test.head_size = 20;              % (GMT default = 36p)
test.map_width = 17;              % (default is 9 inches)
test.region    = '-130/130/-30/30'; % 'lonmin/lonmax/latmin/latmax'
test.basemap_axis = 'NeSW';
test.legend.tick_centering = true;

% CUSTOM COLOR TABLE ---
% For your own custom colortable use in.colorrange.colors (see below). Assign a
% color to a relative value, e.g between 0-1, where 0 is for the minimum of the
% datarange and 1 is for the color of the maximum datarange. For example,
test.colorrange.colors  = {{0,'0/0/255'},...
    {0.3,'255/255/255'},...
    {0.5,'0/255/0'},...
    {.7,'0/0/0'},...
    {1,'255/0/0'}};
test.colorrange.color_model = 'RGB';
% makes a colortable that goes from blue to white to green to black to red in RGB format.
% ------------------------
a0 = sprintf('Test%.0f',t);
test.filename = a0;

file = gmt_plot(catstruct(gridded,test,in),'data');

a = ' demonstrates that you can easily make your own custom colortable using in.colorrange.';
b = 'You can also insert your own legend annotations to be used instead of';
c = 'data values using in.legend.tick_annotations. You can also change in.mapwidth,';
d = 'in.headersize, the tick spacing for the axis using in.ticks,';
e = 'and in this test its demonstrated how to confine the figure to certain';
f = 'geographical regions using in.region = ''lonmin/lonmax/latmin/latmax''';
g = 'The legend is also automatically made horizontal if the base/height > 3';
h = 'This can easily be overridden by setting in.orientation.orientation = ''v'' ';
info = sprintf('%s%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',a0,a,b,c,d,e,f,g,h);

function [files,info] = TEST6(in,files,info)
%% TEST: locations, nodata 
t = 6;
a0 = sprintf('Test%.0f',t);
if ~ismember(t,in.test), return, end %then don't do this test
test.display = false; % no just put them all in one pdf using conbine_pdfs

names    = {'Kiruna','Brisbane','Stuttgart','Bremen','Idukki',...
    'Oberstdorf','Amsterdam','Lauchhammer','Freiburg'};
lats     = [67.85 -27.48 48.83 53.1 9.9 47.3 52.4 51.5 48];
lons     = [20.216 153 9.2 8 77 10.22 4.77 13.77 7.85];
textcolor= repmat({'black'},1,length(names)); textcolor{1} = 'red';
color    = repmat({'green'},1,length(names)); color{3} = 'yellow';
textalign= {'LM','RB','LM','LB','CB','LT','RM','LM','RM'};
textsize = [15,15,7,7,15,7,7,7,7];
shape    = repmat({'c'},1,length(names));shape{3} = 'd';
sze      = repmat({.08},1,length(names)); sze{3} = .1;

for i = 1:length(names)
    test.locations(i).lat = lats(i);
    test.locations(i).lon = lons(i);
    test.locations(i).name = names{i};
    test.locations(i).shape = shape{i};
    test.locations(i).size = sze{i};
    test.locations(i).color = color{i};
    test.locations(i).textsize = textsize(i);
    test.locations(i).textcolor= textcolor{i};
    test.locations(i).textalign = textalign{i};
end
test.basemap_axis = 'neSW';
test.title = 'SatGroup locations';
test.nodata = true;
test.region = '-20/160/-30/70';
test.filename = sprintf('Test%.0fa',t);
files{end+1} = gmt_plot(catstruct(test,in));

% TEST: mediumregion
for i = 1:length(names)
    test.locations(i).textsize = 15;
end
test.region     = '-10/30/45/70';
test.title      = 'Europe';
test.coast.rivers = 'r';
test.filename = sprintf('Test%.0fb',t);
files{end+1}    = gmt_plot(catstruct(test,in));

% TEST: smallregion
test.title = 'Kiruna (high details)';
test.region = '16/22/66.2/70';
test.coast.rivers = 'a';
test.filename = sprintf('Test%.0fc',t);
files{end+1} = gmt_plot(catstruct(test,in));

a = ' demonstrates that you can plot points and text on a map using';
b = 'in.locations (see help gmt_plot), and demonstrates that there are';
c = 'several map resolutions available.';
d = 'The available file types in.figuretype are ''pdf'',''eps'',''png'', and ''tif''';
info{end+1} = sprintf('%s%s\n%s\n%s\n%s\n',a0,a,b,c,d);

function [file,info] = TEST7(in)
%% TEST: pspolygon
t = 7;
if ~ismember(t,in.test), file=''; info = '';return, end %then don't do this test
test.display = false; % no just put them all in one pdf using conbine_pdfs

% REGIONS FROM eliasson11:assessing_acp
a = [-12    80    16   100;...
    -8   100    14   155;...
   -12   155    10   175;...
    35   -70    45   -40;...
    45   -55    60   -10;...
    33   145    40   180;...
    40   160    50   180;...
    36  -180    50  -160;...
    40  -160    55  -135;...
   -27  -110   -18   -72;...
   -18  -130     2   -82;...
   -30   -15    -5    10;...
   -20   -30    -5   -15;...
   -16    15    -5    30;...
    -5    11     0    33;...
     0     0     8    34;...
   -14   -72    -5   -50;...
    -5   -79     0   -56;...
     0   -80    10   -60];

reg = polygoninize_regions(a);

% special for swl
reg{end+1}= [-180  -60; -180 -45];reg{end+1}= [-180  -45; -80 -45];
reg{end+1}= [-80  -45; -80 -60];reg{end+1}= [-80  -60; -180 -60];
reg{end+1}= [-50  -60; -50 -45];reg{end+1}= [-50  -45; 60 -45];
reg{end+1}= [60  -45; 180 -45];reg{end+1}= [180  -45; 180 -60];
reg{end+1}= [180  -60; 60 -60];reg{end+1}= [60  -60; -50 -60];

test.pspoly = reg;
test.pspolycolor = {'g' 'k' 'r' 'g' 'k' 'r' 'b' 'g','g','g','g','g','g','g','g','g','g','g'};
test.nodata=true;
test.basemap_axis='nWeS';
a0 = sprintf('Test%.0f',t);
test.filename = a0;
file = gmt_plot(catstruct(test,in));

a = ' demonstrates that you can draw polygons on a map, using in.pspoly.';
b = 'E.g. useful if you want to draw regions of interest on a map';

info = sprintf('%s%s\n%s\n',a0,a,b);