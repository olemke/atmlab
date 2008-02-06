%ASG_CLOUDSAT_ECMWF reads in cloudsat ecmwf data
%
%  reads in temperature, humidity, and ozone on
%  gformat data. The ecmwf data from the cloudsat
%  files only extends up to approximately 25 km.
%
%  OUT G        gformat data 
%  
%  IN  data     name of datafiles
%      leg      leg of cloudsat
%      grids_cs grids
%
% example usage:
%  leg=2;
%  datadir='/home/bengt/CIWSIR/Dataset_gen/CloudSAT_data/Data/';
%  data=[datadir,'2006166131201_00702_CS_ECMWF-AUX_GRANULE_P_R03_E00.hdf'];
%  latitude=[-90 90];
%  [G,D]=asg_cloudsat_ecmwf(data,leg,latitude)

function [G,D]=asg_cloudsat_ecmwf(data,leg,grids_cs)

if leg==2

    [G,D]=gfin_cloudsat_ecmwf([],[],data,[],leg,[-90 90]);

else
    %read in both leg 1 and 3
    
    [G1,D]=gfin_cloudsat_ecmwf([],[],data,[],1,[-90 0]);
    [G2,D]=gfin_cloudsat_ecmwf([],[],data,[],3,[0 90]);
    
    %merge leg 1 and 3

    for i=1:4
        G(i)=G1(i);
        G(i).DATA=[G2(i).DATA G1(i).DATA];
        G(i).GRID2=[vec2col(G2(i).GRID2)' vec2col(G1(i).GRID2)'];
    end

end

%get the ecmwf data on a pressure grid
%G(1) holds pressure data on an altitude grid
%G(2:end) holds atmospheric data on an altitude grid
%
%take the pressure grid closest to 0 degree latitude
%as the pressure grid to interpolate the data on

lat_ind=min( find( abs(G(1).GRID2)==min( abs(G(1).GRID2) ) ) );
p_grid_ecmwf=G(1).DATA(:,lat_ind);

%remove negative values of this grid
p_grid_ecmwf=p_grid_ecmwf( find( p_grid_ecmwf>0 ) );

%create a lower resolution lat_grid_ecmwf
%lat_grid_ecmwf=[G(1).GRID2(1) G(1).GRID2(2:500:end-1)  G(1).GRID2(end)]; 
for i=1:length(grids_cs{2})
    [m1,ind1]=min(abs(G(1).GRID2-grids_cs{2}(i)));
    lat_grid_ecmwf(i)= G(1).GRID2(ind1);
end

%now interpolate the data on this p_grid_ecmwf
%and lat_grid_ecmwf
%interp linearly and extrap to the closest value 
  

for i=1:length(G)-1

    G(i+1).GRID1=p_grid_ecmwf;
    G(i+1).GRID2=grids_cs{2};
    
    DATA=zeros(length(p_grid_ecmwf),length(lat_grid_ecmwf));
    DATA_extrap=zeros(length(p_grid_ecmwf),length(lat_grid_ecmwf));
    
    for j=1:length(lat_grid_ecmwf)
        ind_j=min(find(lat_grid_ecmwf(j)==G(1).GRID2));
        ind_p=find(G(1).DATA(:,ind_j)>0);
        
        DATA_extrap(:,j)=interp1(log(G(1).DATA(ind_p,ind_j)),...
                          G(i+1).DATA(ind_p,ind_j),...
                          log(p_grid_ecmwf),'nearest','extrap');
        
        DATA(:,j)=interp1(log(G(1).DATA(ind_p,ind_j)),...
                          G(i+1).DATA(ind_p,ind_j),...
                          log(p_grid_ecmwf));
    end

    DATA(find(isnan(DATA)))=DATA_extrap(find(isnan(DATA)));
    G(i+1).DATA=DATA;

end
 
G=G(2:4);
G(1).NAME= 'Temperature field';
G(1).DATA_UNIT='K';

%now the units for humidity and ozone are specific humidity
%we want them in vmr

Ma=28.966; %molecular mass of dry air
Mw=18.016; %molecular mass of water
Mo=47.998; %molecular mass of ozone 

h2o_vmr=Ma/Mw*G(2).DATA.* (1./(1-G(2).DATA*(1+Ma/Mw)));

%h2o_unk is a for calculating ozone vmr
h2o_unk=(1-G(2).DATA)./(Ma/Mw*G(2).DATA+1-G(2).DATA);

G(2).DATA=h2o_vmr; 
G(2).NAME='Water vapour';
G(2).DATA_NAME='Volume mixing ratio';

G(3).DATA=G(3).DATA.*(Ma*h2o_unk+Mw*h2o_vmr)/Mo;
G(3).NAME='Ozone';
G(3).DATA_NAME='Volume mixing ratio';

D.GRID1_NAME='Pressure';
D.GRID1_UNIT='Pascal';