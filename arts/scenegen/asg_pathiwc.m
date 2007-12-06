%ASG_PATHIWC calulates iwc and iwp along geometric propagation path
%
%     This function calculates the geometric propagation
%     path from the sensor to the tangent point in steps 
%     of 100 m. The IWC field in G is simply linearly
%     3-D interpolated (in altitude, latitude,longitude)
%     on this path. Reguired data in G is IWC and Altitude
%     field. 
%
%OUT  P.z   altitude along propagation path
%     P.lat latitude along propagation path
%     P.lon longitude along propagation path
%     P.iwc ice water content along propagation path
%     P.iwp vertical ice water path above the tangent point
%    
%IN   D   Gformat definition structure.
%     G   ASG data.
%     Q   Qarts setting structure
%         Only Q.SENSOR_LOS and Q.SENSOR_POS are considered
%

% 2007-12-06   Created by Bengt Rydberg

function P=asg_pathiwc(D,G,Q)


%find the data of interest
iwc_ind=find(strcmp({G.NAME},'IWC field'));
alt_ind=find(strcmp({G.NAME},'Altitude field'));

if isempty( iwc_ind )
   error('G must contain IWC field')
end

if isempty( alt_ind )
   error('G must contain Altitude field')
end

pos=Q.SENSOR_POS;
los=Q.SENSOR_LOS;

[x,y,z,dx,dy,dz] = arts_poslos2cart( pos(1),pos(2),pos(3),los(1),los(2) );

%find the propagation path from the sensor to the tangent point
%

deg2rad = constants( 'DEG2RAD' );

%the length from the sensor to the tangent point
l_sen=(pos(1))*cos((180-Q.SENSOR_LOS(1))*deg2rad);

%length of each step
l_step=1e2;

%make a vector of propagation steps
l_sen=unique([ [0:l_step:l_sen] l_sen]);

%the propagation path in cartesian cord.
[x,y,z]=deal(x+dx*l_sen,y+dy*l_sen,z+dz*l_sen);

%the propagation path in spherical cord.
[r,lat,lon] = arts_cart2sph(x,y,z);

%regrid the altitude field on the IWC field resolution
Q1=Q;
Q1.P_GRID=G(iwc_ind).GRID1;
Q1.LAT_GRID=G(iwc_ind).GRID2;
Q1.LON_GRID=G(iwc_ind).GRID3;
H=asg_regrid(D,G(alt_ind),Q1);

%interpolate the iwc field data on the propagation path
[X,Y,Z]=meshgrid(G(iwc_ind).GRID2,H.DATA(:,1,1),G(iwc_ind).GRID3);

%the geoid radius at the tangent point
re    = interp1( [-90:1:90], wgs84( 2, [-90:1:90]), lat(end) );

IWC=interp3(X,H.DATA,Z,G(iwc_ind).DATA,lat,r-re,lon);

%set all nan values to 0
IWC(find(isnan(IWC)))=0;

P.z=r-re;
P.lat=lat;
P.lon=lon;
P.iwc=IWC;
P.iwp=sum( (P.z(1:end-1)-P.z(2:end)) .* (IWC(1:end-1)+IWC(2:end))/2 );









