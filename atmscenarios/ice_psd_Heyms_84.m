% ice_psd_Heyms_84 returns the particle size distribution in cirrus clouds.
%    
%     Returns a vector with the particle size distribution 
%     for a given temperature, for a midlatitude cirrus cloud.
%     This parameterization is based on the temperature averaged 
%     distribution of maximum dimension of ice particles, and ice 
%     water content. 
%
%     This parameterization is taken from Heymsfield and Platt,
%     "A parameterization of the particle size spectrum of ice clouds
%     in terms of the ambient temperature and ice water content"
%     J. Atmos. Sci., vol.41, No.5, 846-855, 1984
%
% FORMAT   [x,y] = ice_psd_Heyms_84(T)     
%
% OUT      y is a vector with the particle size distribution [#/m³/m]
%          x is a vector from 2*10^(-5)m to 3*10^(-3)m with ecah 
%          step 10^(-6)m, and represents the maximum  dimensions 
%          of the ice particles.
%  
% IN       T   Temperature [Celsius]


% History: 2004-07-19  Created by Bengt Rydberg


function [x,y]=ice_psd_Heyms_84(T)

if T>-20
  error('Only temperatures below or eqaul to -20  are allowed')
end
if T<-60
  error('Only temperatures larger than or equal to -60 are allowed')
end
if T<=-20 & T>-25
   IWCmean=0.027;
   N100_IWC=5.17*10^(3);B1=-2.56;N1000_IWC=12.0;B2=-3.74;
   elseif T<=-25 & T>-30
      IWCmean=0.025;      
      N100_IWC=7.00*10^(3);B1=-2.51;N1000_IWC=10.4;B2=-4.49;
   elseif T<=-30 & T>-35
      IWCmean=0.0175;
      N100_IWC=7.43*10^(3);B1=-2.21;N1000_IWC=13.7;B2=-3.94;
   elseif T<=-35 & T>-40
      IWCmean=0.0126;
      N100_IWC=1.98*10^(4);B1=-2.29;N1000_IWC=10.3;B2=-4.37;
   elseif T<=-40 & T>-45
      IWCmean=0.0034;
      N100_IWC=7.50*10^(3);B1=-3.23;N1000_IWC=4.86;B2=-3.23;
   elseif T<=-45 & T>-50
      IWCmean=0.0025;
      N100_IWC=5.60*10^(3);B1=-3.15;N1000_IWC=4.00;B2=-3.15;
   elseif T<=-50 & T>-55
      IWCmean=0.0018;
      N100_IWC=3.89*10^(3);B1=-3.83;N1000_IWC=0.86;B2=-3.83;
   elseif T<=-55 &T>=-60
      IWCmean=0.0009;
      N100_IWC=5.58*10^(3);B1=-3.85;N1000_IWC=8.06;B2=-3.85;
end

A1=N100_IWC/100^(B1);
A2=N1000_IWC/1000^(B2);
D0=(A2/A1)^(1/(B1-B2));

N=zeros(1,2980);
   if D0>20 & D0<3000
      D0=round(D0);
      Dd=1e-6*D0;
      D1=linspace(2*1e-5,Dd,D0-20);
      D2=linspace(Dd,3*1e-3,3000-D0);
      A1=N100_IWC*1e6/0.0001^(B1);
      A2=N1000_IWC*1e6/0.001^(B2);
      N2=A2.*D2.^(B2)*IWCmean;
      N1=A1.*D1.^(B1)*IWCmean;
      N(1,1:1:D0-20)=N1(1,1:1:D0-20);
      N(1,D0-20+1:1:3000-20)=N2(1,1:1:3000-D0);
   elseif D0<=20
          D2=linspace(2*1e-5,3*1e-3,2980);
          A2=N1000_IWC*1e6/0.001^(B2);
          N2=A2.*D2.^(B2)*IWCmean;
          N=N2;
   elseif D0>3000
          D1=linspace(2*1e-5,3*1e-3,2980);
          A1=N100_IWC*1e6/0.0001^(B1);
          N1=A1.*D1.^(B1)*IWCmean;
          N=N1;
  end

x=linspace(2*1e-5,3*1e-3,2980);
y=N;
