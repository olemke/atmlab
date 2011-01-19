function files = test_gmt(in)
%% TEST_GMT
%
% Purpose: To test variuos aspecs of gmt_plot. Especially before commiting
% changes
%
% IN: (optional) structure of arguments to be used in the gmt_plot call
%     in.test = [1,3,4] is which tests to run. default is to run all tests ([1:5])
%
% $Author$
% $Date$

files = {}; if ~exist('in','var'); in=struct([]); end
default.test = 1:5; % which tests to do (default=all)
in = optargs_struct(in,default); 

[gridded,ungridded] = dummy_data;

files = TEST1(in,gridded,ungridded,files); %TEST: title, unit, basemapaxis (gridded and ungridded)

files{end+1} = TEST2(in,gridded); %TEST: sidebar, nan, projection, center

files{end+1} = TEST3(in,gridded); %TEST: custom color table, header_size, map_width, grid lines

files{end+1} = TEST4(in);         %TEST: contours, nlevels, annotation format, xunit

files = TEST5(in,files);          %TEST: locations, nodata, regions, map details


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

function files = TEST1(in,gridded,ungridded,files)
%% TEST 1: title, unit, basemap_axis (gridded and ungridded)

if ~ismember(1,in.test), return, end %then don't do this test

test.title        = 'gridded: title², unit, basemapaxis ';
test.unit         = 'kg/m²';
test.basemap_axis = 'NeSW'; 

files{end+1} = gmt_plot(catstruct(in,gridded,test),'data');
test.title        = 'ungridded: title², unit, basemapaxis ';
files{end+1} = gmt_plot(catstruct(in,ungridded,test),'data');

function file = TEST2(in,gridded)
%% TEST2: sidebar, nan, projection, center

if ~ismember(2,in.test), file='';return, end %then don't do this test

gridded.data(20:40,20:80) = NaN;
test.title      = 'upper sidebar, NaN, Hammer projection, center';
test.projection = 'H';      % hammer
test.center     = 180;      % Center map at given center longitude
test.datarange  = [160,250];% displayed value range. Sidebar triangles shown for data outside range.

file = gmt_plot(catstruct(in,gridded,test),'data');

function file = TEST3(in,gridded) 
%% TEST3: custom color table, header_size, map_width, grid lines, region

if ~ismember(3,in.test), file=''; return, end %then don't do this test

if ~isfield(in,{'stepsize','nlevels'})
    tmp = cell(1,20);
    tmp{1} = 'blue'; tmp{6} = 'white'; tmp{10} = 'green'; tmp{15} = 'black'; tmp{20} = 'red';
    test.tick_annotations = tmp; % place annotations at the desired intervals
end
test.title = 'custom color, annotations,header_size, map_width, tight grid, NeSW, region';
test.ticks = '30g30/15g15'; % annotations (deg) on major lines (e.g 40 xaxis,20 yaxis)
                            % and plot minor lines (e.g 20 xaxis & yaxis)
test.head_size = 20;              % (GMT default = 36p)
test.map_width = 15;              % (default is 9 inches)
test.region    = '-90/90/-30/90'; % 'lonmin/lonmax/latmin/latmax'

% CUSTOM COLOR TABLE ---
% For your own custom colortable use in.colorrange.colors (see below). Assign a
% color to a relative value, e.g between 0-1, where 0 is for the minimum of the
% datarange and 1 is for the color of the maximum datarange. For example,
test.colorrange.colors  = {{0,'0/0/255'},{0.3,'255/255/255'},...
    {0.5,'0/255/0'},{.7,'0/0/0'},{1,'255/0/0'}};
test.colorrange.color_model = 'RGB';
% makes a colortable that goes from blue to white to green to black to red in RGB format.
% ------------------------

file = gmt_plot(catstruct(in,gridded,test),'data');

function file = TEST4(in)
%% TEST: contours, nlevels, annotation format, xunit

if ~ismember(4,in.test), file=''; return, end %then don't do this test

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
test.legend_orient = 'h';
test.grdcontour.spacing=0.1;
test.grdcontour.range=[0 1];
test.grdcontour.linethick=1;
test.grdcontour.more='-T1c/0.001c:LH';
test.datarange = [0, 1];
test.color_background = '255/0/0';
test.color_foreground = '255/255/0';
test.colorrange.colors = {{0,'0/1/1'},{1,'60/1/1'}};
test.colorrange.color_model = 'HSV';
test.nlevels = 5;

file = gmt_plot (catstruct(in,test), 'data');

function files = TEST5(in,files)
%% TEST: locations, nodata 

if ~ismember(5,in.test), return, end %then don't do this test

names = {'Kiruna','Brisbane','Stuttgart','Bremen','Idukki','Oberstdorf','Tehran','Amsterdam','Lauchhammer','Freiburg'};
lats = [67.85 -27.48 48.83 53.1 9.9 47.3 35.7 52.4 51.5 48];
lons = [20.216 153 9.2 8 77 10.22 51.5 4.77 13.77 7.85];
textcolor = repmat({'black'},1,length(names)); textcolor{1} = 'red';
color = repmat({'green'},1,length(names)); color{3} = 'yellow';
textalign = {'M','R','LM','LB','CL','LT','LT','RM','LM','RM'};
textsize = [15,15,7,7,15,7,15,7,7,7];
shape = repmat({'c0.08i'},1,length(names));shape{3} = 'd0.1i';

for i = 1:length(names)
    test.locations(i).lat = lats(i);
    test.locations(i).lon = lons(i);
    test.locations(i).name = names{i};
    test.locations(i).shape = shape{i};
    test.locations(i).color = color{i};
    test.locations(i).textsize = textsize(i);
    test.locations(i).textcolor= textcolor{i};
    test.locations(i).textalign = textalign{i};
end
test.basemap_axis = 'neSW';
test.title = 'SatGroup locations';
test.nodata = true;
test.region = '-20/160/-30/70';
files{end+1} = gmt_plot(test);

% TEST: mediumregion
for i = 1:length(names)
    test.locations(i).textsize = 15;
end
test.region     = '-10/40/40/70';
%test.figuretype = 'png';
test.title      = 'Europe (medium details in a .png-file)';
files{end+1}    = gmt_plot(test);

% TEST: smallregion
test.title = 'Kiruna (high details)';
test.region = '12/22/65/70';
files{end+1} = gmt_plot(test);