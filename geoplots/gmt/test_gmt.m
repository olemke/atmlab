function files = test_gmt(in)
%% TEST_GMT
%
% Purpose: To test variuos aspecs of gmt_plot. Especially before commiting
% changes
%
% IN: (optional) structure of arguments to be used in the gmt_plot call
%
% $Author$
% $Date$

% GENERATE MAIN DATA 
if ~exist('in','var'), in = struct([]);end
test.lat = -90:90;
test.lon = -180:180;
data = zeros(length(test.lat),length(test.lon));
for j=0:180
    for i=0:360
        data(j+1,i+1)=sin(((i+180)/360)*pi+pi/2)* cos((j/180)*pi+pi/2)*100+160;
    end
end

files = {};
% TEST TITLE
test.title = 'title² and unit';
test.data = data;
files{end+1} = gmt_plot(catstruct(in,test,struct('unit','kg/m²')),'data');
% 
% % TEST SIDEBAR, NAN, PROJECTION, CENTER
test.data(20:30,20:30) = NaN;
test.title = 'upper sidebar, nan, Hammer projection, center';
files{end+1} = gmt_plot(catstruct(in,test,struct('projection','H','center',180,'datarange',[160,250])),'data');

% TEST custom color table, header_size, map_width, grid lines, NeSW
test.title = 'custom color, annotations,header_size, map_width, tight grid, NeSW, region';
test.data = data;
a.colorrange.colors      = {{0,'0/0/255'},{0.3,'255/255/255'},{0.5,'0/255/0'},{.7,'0/0/0'},{1,'255/0/0'}};
a.colorrange.color_model = 'RGB';
tmp = cell(1,20);
tmp{1} = 'blue'; tmp{6} = 'white'; tmp{10} = 'green'; tmp{15} = 'black'; tmp{20} = 'red';
a.tick_annotations = tmp; clear tmp
files{end+1} = gmt_plot(catstruct(in,test,a,struct('ticks','30g30/15g15','head_size',20,'map_width',15,'basemap_axis','NeSW','region','-90/90/-30/90')),'data');

clear test;
% TEST CUSTOM CONTOURS
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

files{end+1} = gmt_plot (test, 'data');

clear test
% TEST LOCATIONS
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
    %
    test.locations(i).color = color{i};
    test.locations(i).textsize = textsize(i);
    test.locations(i).textcolor= textcolor{i};
    test.locations(i).textalign = textalign{i};
end
test.title = 'SatGroup locations';
test.nodata = true;
test.region = '-20/160/-30/70';
files{end+1} = gmt_plot(test);
