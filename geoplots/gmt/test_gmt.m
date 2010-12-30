function test_gmt
%% TEST_GMT
%
%
%
% $ID$

test.lat = -90:90;
test.lon = -180:180;
for j=0:180
    for i=0:360
        test.data(j+1,i+1)=sin(((i+180)/360)*pi+pi/2)* cos((j/180)*pi+pi/2)*100+160;
    end
end

gmt_plot(catstruct(test,struct('title','test title²','unit','kg/m²')),'data');
