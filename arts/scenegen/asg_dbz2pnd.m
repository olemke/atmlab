%asg_dbz2pnd calculates iwc and pnd fields
%
% FORMAT   G=asg_dbz2pnd( D, G, Q, P)
% 
% OUT      G        Modified gformat data,now including
%                   IWC and PND data
% IN       D        G format definition structure 
%          G        original gformat data 
%          Q        Qarts setting structure.            
%          P        conversion structure of length 2
%                   P(1) corresponds to the radar frequency                       
%                   P(2) corresponds to the instrument frequencys 
%                   with fields                  
%            SSP    single scattering properties    
%            PSD    particle size dist. choice
%                   'MH97' is the only valid option
%            method method for calculating particle
%                   number density fields
%                   'gauss-laguerre' is the only valid option
%            x      particle diameter (see function gauss_laguerre
%                   for help)                     
%            w      weights
%            x_norm normalisation factor 
%            shape  particle shape
%                   'sphere' is the only valid option 
%
%  2007-11-13 created by Bengt Rydberg

function [G,D]= asg_dbz2pnd( D, G, Q ,P);


for i=1:length(G)
    if strcmp(G(i).DATA_NAME,'Radar_Reflectivity')
       dBZ=G(i).DATA;
    end
    if strcmp(G(i).DATA_NAME,'Temperature')
       T=G(i).DATA;
    end
end

if length(P)~=2
   error('P structure must be of length 2')
end

if ~exist('T','var') & ~exist('dBZ','var')
   error('G must hold Temperature and Radar_Reflectivity data')
end

if isempty(Q.F_GRID)
   error('Q.F_GRID must be specified')
end

if strcmp(P(1).method,'gauss-laguerre')
   len=length(P(1).SSP);
   if length(P(1).x)~=len & length(P(1).w)~=len
      error('mismatch in size between P(1).SSP,P(1).x, and P(1).w')
   end
   for i=1:len
       %radar backscattering per particle
       Q_b1(:,i)=4*pi*squeeze(P(1).SSP(i).pha_mat_data(1,:,end,1,1,1,1))';
   end
   %create the look-up-table
   lambda=3e8/P(1).SSP(1).f_grid;
   nwater=sqrt(eps_water_liebe93(P(1).SSP(1).f_grid,273.15));
   Kwater=( abs( (nwater.^2-1)./ (nwater.^2+2) ) ).^2;
   IWCv=logspace(-3.65,0.5,100);
   Tv=200:2:273;
   T_grid=P(1).SSP(1).T_grid;
   %loop over Tv and IWCv to find dBZ(T,IWC)
   for j=1:length(Tv)
       sigma_b=interp1(T_grid,Q_b1,Tv(j));
       for i=1:length(IWCv)
           if strcmp(P(1).PSD,'MH97')
              y(i,:) = ice_psd_Mcfar_97(Tv(j),IWCv(i),P(1).x,1);
              Y(i,:) = gauss_laguerre_apply(y(i,:)',P(1).x,P(1).w,P(1).x_norm);
           else
             error('MH97 is the only valid option for P.PSD')
           end
       end
       Z(j,:)=lambda^4 /(pi^5)/Kwater*...
                           sum([Y.*[ones(length(IWCv),1)*sigma_b]]');
   end
   dBZm=10*log10(Z*1e18);

   %re-arrange the look-up-table [IWC(T,dBZ)]
   dBZv=[-49:1:30];
   for i=1:size(dBZm,1)
       IWCC(i,:)=interp1(dBZm(i,:),IWCv,dBZv);
   end
   IWC=interp2(dBZv,Tv,IWCC,dBZ,T);
   IWC(isnan(IWC))=0;
   
   %put in IWC in G
   glen=length(G);   
   G(glen+1)=G(glen);
   G(glen+1).NAME='IWC field';
   G(glen+1).DATA=IWC;
   G(glen+1).DATA_NAME='IWC';
   G(glen+1).DATA_UNIT='gm-3';
   G(glen+1).SOURCE='';
   
   %setting in PND fields in G
   Ni=length(P(2).x);
   if ~strcmp(P(2).shape,'sphere')
      error('sphere is the only valid option for P.shape')
   end
   if strcmp(P(2).PSD,'MH97')
      y=zeros(length(IWC(:)),Ni);
      ivec=find(IWC);
      for i=ivec'
          y(i,:) = ice_psd_Mcfar_97(T(i),IWC(i),P(2).x,1);
      end
      Y = gauss_laguerre_apply(y',P(2).x,P(2).w,P(2).x_norm);
      for i=1:Ni
          G(glen+1+i)=G(glen+1);
          G(glen+1+i).DATA=reshape(Y(i,:),size(IWC));
          G(glen+1+i).PROPS=P(2).SSP(i);
          G(glen+1+i).NAME=['Particles ',num2str(P(2).x(i)*1e6),' um'];
          G(glen+1+i).DATA_NAME=['Particle number density'];
          G(glen+1+i).DATA_UNIT=['m-3'];
      end
   end
else 
  error('gauss-laguerre is the only valid method')
end


