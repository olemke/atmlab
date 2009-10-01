% ASG_CREATE_GFS   Creates atmopsheric states including clouds 
%                  based on various input data 
%
%    Creates atmospheric states including clouds, where the spatial
%    structure of the clouds is taken from radar data.
%
%    Reads in Cloudsat radar data from selected parts
%    of the orbits based on the fields of *C*.
%    
%    Prepares data for the sub-function *asg_gen_state*
%    where realisations of atmospheric states are performed,
%    which can either be 1 or 3-d.
%
%    FORMAT [H,lon_data] = asg_create_gfs(Gcs,grids_cs,C,workfolder)
%
% OUT   G1          Modified G format data
%       lon_data    longitudes correspong to C.USE_LATS
% IN    Gcs         Specification of clear sky fields, in gformat.
%       grids_cs    Initial grids for clear sky fields. These grids are used
%                   as put into Q before calling *asg_atmgrids*. Obtained
%                   grids are used e.g. when calling *asg_rndmz* for clear 
%                   sky fields. 
%                   The input is given as an array of vectors, where element  
%                   1 corresponds to Q.P_GRID, element 2 Q.LAT_GRID and 
%                   element 3 Q.LON_GRID. 
%       C           A cloud definition structure with fields
%         DATA           name of datafile to be read in
%         LEG            leg of cloudsat data 
%         USE_LATS       latitude midpoints
%         DLAT           latitude (scalar)
%         LAT_RES        latitude resolution (scalar)
%         LON_GRID       longitude grid 
%         C.P_LIMS       pressure limits
%         DIM            desired dimensionality of data
%         DIMADD         (see asg_dimadd)
%         PROPS
%                    a psd and ssp defintiion structure 
%                    C.PROPS(1) corresponds to the radar frequency             
%                    C.PROPS(2) corresponds to the instrument frequencys 
%                    with fields                    
%             SSP    single scattering properties data
%             PSD    particle size distribution, only 'MH97' and 'Water' works
%             method psd method, only 'gauss-laguerre' works
%             x      particle sizes (see help gauss_laguerre)
%             w      weights
%             x_norm normalistaion factor 
%             shape  particle shape, only 'sphere' works 
%
%
%        Examle usage:                
%        visit asg_demo to see an example how to use this function


%  2009-05-18 created by Bengt Rydberg

function [H,lon_data] = asg_create_gfs(Gcs,grids_cs,C,workfolder)
  
  
%- Load CloudSat data
%
dim=C.DIM;
C.AUX       = {'DEM_elevation','Longitude','TAI_start','Profile_time'};
if dim==3
 lat_limits  = [ C.USE_LATS(1)-C.DLAT/2 C.USE_LATS(end)+C.DLAT/2 ];
end
if dim==1
  lat_limits = [C.USE_LATS(1)-C.LAT_RES C.USE_LATS(end)+C.LAT_RES]; 
end

%make sure we read in also just outside lat_limits
lat_out     = [ lat_limits(1)-0.1 lat_limits(end)+0.1 ];

[PATHSTR,name1,EXT,VERSN] = fileparts(C.DATA);
if strcmp('.zip',EXT)
   unzip(C.DATA,workfolder)
   C.DATA=fullfile(workfolder,name1);
end

[Gdbz,Ddbz] = gfin_cloudsat_dBZe([],[],C.DATA,C.AUX,[],C.LEG,lat_out,[]);



%find out what longitudes USE_LATS correspond to
for li=1:length(C.USE_LATS)
 [lat_m,lat_ind(li)]=min( abs(Gdbz(2).GRID2-C.USE_LATS(li)));
end
lon_ind=find(strcmp({Gdbz.NAME},'Longitude'));
lon_data=Gdbz(3).DATA(lat_ind);


%- reduce the latitude resolution
%  bin the data on a desired grid
%
grids{1} = Gdbz(1).GRID1;
grids{1} = Gdbz(1).GRID1( find( Gdbz(1).GRID1>0 & Gdbz(1).GRID1<24e3 ) );

if dim==3
   grids{2} = lat_limits(1) : C.LAT_RES : lat_limits(end);
else
   grids{2}= sort([C.USE_LATS C.USE_LATS+C.LAT_RES C.USE_LATS-C.LAT_RES]);
end

Gdbz(1).DATA=10.^(Gdbz(1).DATA/10);
[Gdbz,Ddbz]=gf_bin(Ddbz,Gdbz,grids,[1 2]);

if dim==1
 for i=1:length(C.USE_LATS)
   l_ind(i)=find(Gdbz(1).GRID2==C.USE_LATS(i));
 end
 for i=[1 2 3 5]
   if i==1
    Gdbz(i).DATA=Gdbz(i).DATA(:,l_ind);
   else
    Gdbz(i).DATA=Gdbz(i).DATA(l_ind);
   end
   Gdbz(i).GRID2=Gdbz(i).GRID2(l_ind);
 end
end


Gdbz(1).DATA=10*log10(Gdbz(1).DATA);
Gdbz(1).DATA(find(Gdbz(1).DATA<=-50))=-50;

% Switch to pressure grid. Sort data in order to get decreasing pressures and
% increasing latitudes.
%
tai_ind=find(strcmp({Gdbz.NAME},'TAI_start'));
pt_ind=find(strcmp({Gdbz.NAME},'Profile_time'));
dbz_ind=find(strcmp({Gdbz.NAME},'Radar_Reflectivity'));
mjd1=date2mjd(1993,1,1,0,0,0);
sec_of_day=60*60*24;
mjd=mjd1+(Gdbz(tai_ind).DATA+mean(Gdbz(pt_ind).DATA))/sec_of_day;
DOY = mjd2doy(mjd);
Gdbz(dbz_ind).GRID1= z2p_cira86(Gdbz(dbz_ind).GRID1,mean(lat_limits),DOY );
Ddbz.GRID1_NAME='Pressure';
Ddbz.GRID1_UNIT='Pa';
%

% Set DIMADD or similar fields based on fields of C.
%
if dim==3
 grids_dbz{3} = C.LON_GRID;
 Gdbz(dbz_ind).DIMADD=C.DIMADD;
end
%

%- Set Gdbz.GRID1
%
% Get out part of Gdbz that is inside the selected 
%C.P_LIMS and latitude limits .
%
grids_dbz{1} = Gdbz(dbz_ind).GRID1;
if dim==3

 limits=[fliplr(C.P_LIMS);lat_limits];
 [Gdbz(dbz_ind),Ddbz]=gf_crop(Ddbz,Gdbz(dbz_ind),limits,[1 2]);

else
 
 limits=[fliplr(C.P_LIMS)];
 [Gdbz(dbz_ind),Ddbz]=gf_crop(Ddbz,Gdbz(dbz_ind),limits,[1]);

end
 
%

%add the psd and ssp properties of the assumed particles
% 
Gdbz(dbz_ind).PROPS=C.PROPS;

%- Prepare data for each selected latitude
%
for ip = 1 : length(C.USE_LATS)
 
  Gcs1 = Gcs;
  %- Extract CloudSat data
  %  
  if dim==3

   lat  = [C.USE_LATS(ip)-C.DLAT/2 C.USE_LATS(ip)+C.DLAT/2];
   limits=[fliplr(C.P_LIMS);lat];
   [G(ip),Ddbz]=gf_crop(Ddbz,Gdbz(dbz_ind),limits,[1 2]);
   %place the grid on 0 degree latitude/ not for this case
   %G(ip).GRID2= round( [G(ip).GRID2-mean(G(ip).GRID2)]*1000)/1000;
   grids_dbz{2} = G(ip).GRID2;

  else

   G(ip)=Gdbz(1);
   G(ip).DATA=Gdbz(1).DATA(:,ip);
   G(ip).GRID2= Gdbz(1).GRID2(ip);

  end 

  
  %- Temperature, water vapor, and ozone possibly from ECMWF
  %  just use as little data as necessary
  % 
  t_ind=find(strncmp(lower({Gcs1.NAME}),'temperature',11)); 
  h_ind=find(strncmp(lower({Gcs1.NAME}),'water',5));
  o_ind=find(strncmp(lower({Gcs1.NAME}),'o3',2));
  s_ind=find(strncmp(lower({Gcs1.NAME}),'surface',7));
  Q = qarts;
  Q.P_GRID=grids_cs{1};

  if dim==3

   lim1=round(C.USE_LATS(ip)-C.DLAT/2);
   lim2=round(C.USE_LATS(ip)+C.DLAT/2);
   if ip==1
      lat_grid=grids_cs{2};
   end
   %the lat grid around the cloudbox
   add_lat_grid=[ lim1-3 lim1-1 lim1-0.01 lim1 ...
                 C.USE_LATS(ip)-1 C.USE_LATS(ip) C.USE_LATS(ip)+1 ...
                 lim2 lim2+0.01 lim2+1 lim2+3];
   grids_cs{2}=unique(sort([lat_grid,add_lat_grid])); 
   Q.LAT_GRID=grids_cs{2};
   Q.LON_GRID=grids_cs{3}; 
   Q.ATMOSPHERE_DIM = 3;
   Q = asg_atmgrids( asgD, Gcs1, Q );

  else
   
    Q.ATMOSPHERE_DIM = 2;
    Q.LAT_GRID=C.USE_LATS(ip);
  
  end

  
  if Q.P_GRID(end)==Q.P_GRID(end-1)
     Q.P_GRID=Q.P_GRID(1:end-1);
  end
 
  Gcs1([t_ind,s_ind,h_ind,o_ind])= asg_regrid( asgD,...
                                Gcs1([t_ind,s_ind,h_ind,o_ind]) , Q ); 
  

  %- Generate a single scene
  %
  %see sub-function

  [H{ip}] = asg_gen_state( Gcs1, grids_cs, G(ip), ...
					      grids_dbz, Q,dim);
  
  
end
clear G
G=H;


function [G] = ...
        asg_gen_state(Gcs,grids_cs,Gdbz,grids_dbz,Q,dim)

 D = asgD;

 %- Create clear sky fields
 %
 if dim==3
    Gcs = asg_dimadd( D, Gcs, Q );
 end

 Gcs = asg_regrid( D, Gcs, Q );
 Gcs = asg_fixed_relhumid( D, Gcs );
 Gcs = asg_rndmz( D, Gcs );
 Gcs = asg_hydrostat( D, Gcs, Q );


 %- Determine grids for dbz field
 %
 
 Q.P_GRID   = grids_dbz{1};
 if dim==3
    Q.LAT_GRID = grids_dbz{2};
    Q.LON_GRID = grids_dbz{3};
 end
 %
 
 %- Create final dbz field(s)
 %
 if dim==3
  Q = asg_atmgrids( D, Gdbz, Q );
  Gdbz.DATA=10.^(Gdbz.DATA/10);
  Gdbz = asg_dimadd( D, Gdbz, Q );
  Gdbz.DATA=10*log10(Gdbz.DATA);
  Gdbz = asg_regrid( D, Gdbz, Q );
 end


 
 %- Make re-gridding of clear sky fields
 %
 % Hydrostatic eq. does not necesserily apply at "new" points
 %
 
 if dim==1
    Q.ATMOSPHERE_DIM=1;
 end

 Q.P_GRID=250/16e3;
 if dim==3
  Q.LAT_GRID=0.001;
  Q.LON_GRID=0.001;
 end
 Q = asg_atmgrids( D, [Gcs Gdbz], Q );
 Gcs = asg_regrid( D, Gcs, Q );
 Gcs = asg_hydrostat( D, Gcs, Q );  


 %- Pad dbz fields with zeros
 %
 % These fields do not need to match grids in Q. A reinterpolation is anyhow 
 % done in ARTS
 %
 if dim==1
    Gdbz.DIMS=[1];
 end
 
 Gdbz = asg_zeropad( D, Gdbz, Q);
 
 
 

 %As we fill data field with zeros, but the unit is in dBZe
 % we give all zero valued data the minimum value (-50 )
 Gdbz.DATA(find(Gdbz.DATA==0))=min(Gdbz.DATA(:));  

 %- Convert dbz field(s) to pnd fields but first regrid atmospheric fields
 %  to the dbz grid
 %
 Q1          = Q;
 Q1.P_GRID   = Gdbz.GRID1;
 if dim==3
    Q1.LAT_GRID = Gdbz.GRID2;
    Q1.LON_GRID = Gdbz.GRID3;
 end
 Gcs1        = asg_regrid( D, Gcs, Q1 );
 %

 Gdbz = asg_dbz2pnd( D, [Gcs1 Gdbz], Q ,Gdbz.PROPS);
 Gdbz = Gdbz(length(Gcs1)+1:end);

 %- Modify water vapour to match cloud distribution
 %
 ind1=find(strcmp('Water vapour',{Gcs.NAME}));
 if  Gcs(ind1).SPCFC.MOD_RH 

   if dim==1
      ind1=find(strcmp('IWC field',{Gdbz.NAME}));
      Gdbz(ind1).DIMS=[1 2]; 
      %this is just to make it work (dimensionality is 1)
   end
   Gcs=asg_iwc_relhumid_lv(D,Gcs,Gdbz,Q);
   Gcs = asg_hydrostat( D, Gcs, Q );

 end

 G = [Gcs Gdbz];

return