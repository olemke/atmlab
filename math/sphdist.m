function dist=sphdist(lat1,lon1,lat2,lon2,radius)
%
%  sphdist calculates the distance between to points given by
%  latitude and longitude coordinates, assuming a perfect sphere
%  with a given radius
% 
%  input: lat1:  latitude of point #1 in degrees
%         lon1:  longitude of point #1 in degrees
%         lat2:  latitude of point #2 in degrees
%         lon2:  longitude of point #2 in degrees
%         radius: radius of the sphere
%
%  output dist: distance between point #1 and #2  
%
%  
  deg2rad = pi/180.;
  ga = (lon1-lon2).*deg2rad;
  a = (90.-lat2).*deg2rad;
  b = (90.-lat1).*deg2rad;
  c = acos(cos(a).*cos(b)+sin(a).*sin(b).*cos(ga));
  dist = radius.*c;

  
