function [data,lat,lon] = binning_fast(in)
%% BINNING_FAST bins ungridded data onto a grid 
%
% Bins ungridded data to a grid using d = in.gridsize where, 
% lat = -90+0.5*d:d:90-0.5*d;
% lon = -180+0.5*d:d:180-0.5*d;
%
% Bins data into cell(lat,lon), where each cell contains a vector of the data that
% belongs to the gridbox.
%
% The structure elements lat,lon,data must be the same size, and the function
% will preserve the variable types.
%
% In:
%           structure containing 
%                       1) data
%                       2) lat
%                       3) lon
%                       4) gridsize
%
% Out:
%                   1) data ( cell )
%                   2) lat  ( vector )
%                   3) lon  ( vector )
%
% 2010-03-04 Salomon Eliasson

% requires: -180 <= lon < 180 
d = in.gridsize;
test = in.lon>180;

in.lon(test)=in.lon(test)-360;
in.lon(in.lon==180)=-180; 
in.lat(in.lat==90)=90-d/2; %put it in the last gridbox

if any(test(:))
    lon = 0+0.5*d:d:360-0.5*d;
else lon = -180+0.5*d:d:180-0.5*d;
end
lat = -90+0.5*d:d:90-0.5*d;

newlon = floor(in.lon/d) + floor(180/d ) + 1;                                         % assign index value
newlat = floor(in.lat/d) + floor(90/d ) + 1;                                          % assign index value
indata = in.data(:);
data = cell(180/d, 360/d);

counts = zeros (size(data), class(indata));
for i = 1:length(indata)                                                        % get counts
    ilon = newlon(i);
    ilat = newlat(i);
    counts(ilat, ilon) = counts(ilat, ilon) + 1;
end

for i = 1:size(counts,1)                                                        %preallocate counts
    for j = 1:size(counts,2)
        data{i, j} = zeros (counts(i, j), 1, class(indata));
    end
end

for i = 1:length(indata)                                                        %loop data
    ilon = newlon(i);
    ilat = newlat(i);
    data{ilat, ilon}(counts(ilat, ilon)) = indata(i);
    counts(ilat, ilon) = counts(ilat, ilon) - 1;
end