% ice_psd_Donovan_03 returns the particle size distribution in cirrus clouds.
%    
%     Returns a vector with the particle size distribution for a 
%     given temperature and ice water content, for a midlatitude cirrus cloud.
%     The uncertainty regarding the habits of the ice crystals is large.
%     The parameterization here is based on the distribution of
%     maximum dimension of complex polycrystals, which is  consistent
%     with the average observed behaviour. 
%
%     The parameterization is taken from Donovan.
%     "Ice cloud effective particle size parameterization based
%     on combined lidar, radar reflectivity, and mean Doppler
%     velocity measurements"
%     J. of Geophys. res., vol. 108, NO. D18, 4573, 2003
%
% FORMAT   [x,y] = ice_psd_Donovan_03(T,IWC)     
%
% OUT      y is a vector with the particle size distribution [#/m³/m]
%          x is a vector from 10^(-6)m to 10^(-3)m with ecah step 10^(-6)m,
%          and represents the maximum dimensions of complex polycrystals. 
%
% IN       T   Temperature [Celsius]
%          IWC Ice water content [g/m3]

% History: 2004-07-19  Created by Bengt Rydberg


function [x,y]=sizedistribution(T,IWC) 


if T>0
   error('Only temperatures below or equal to zero are allowed.')
end
if T<-70
   error('Only tempertaures larger or equal to -70 are allowed.')
end
if IWC<0.001
   error('Only IWC larger than or equal to 0.001 are allowed')
end
if IWC>1.0
   error('Only IWC smaller or equal to 1.0 are allowed')
end
gammas=4.24;gammal=3.64;
Rms=20.1623;rms=Rms/(gammas+2)*1e-6;
A0a=502.88;A1a=109.56;
A0b=7.66;A1b=1.92;
R0=A0a+A1a*log10(IWC);
Ra=A0b+A1b*log10(IWC);
Rml=R0+Ra*T;
rml=Rml/(gammal+2)*1e-6;
Nl_Ns=[0.006409 0.007934 0.01089 0.01459 0.01851 0.02243 0.02625 0.02994;
       0.006119 0.007603 0.01222 0.01809 0.02402 0.02970 0.03510 0.04027;
       0.006078 0.007328 0.01350 0.02134 0.02894 0.03650 0.04279 0.04927;             0.006081 0.007068 0.01493 0.02478 0.03400 0.04256 0.05070 0.05859;             0.000000 0.006859 0.01627 0.02789 0.03851 0.04838 0.05783 0.06704;
       0.000000 0.006669 0.01773 0.03114 0.04321 0.05449 0.06536 0.07600;
       0.000000 0.006523 0.01909 0.03408 0.04747 0.06005 0.07226 0.08424];
IWCv=[0.001 0.0033 0.01 0.033 0.10 0.33 1.0]';
Tv=[-70:10:0];
Nl_Ns=interp2(Tv,IWCv,Nl_Ns,T,IWC,'cubic');     
             
alfa1=4.3;beta1=2.88;alfa2=1.38;beta2=2.88;alfap2=145.73;betap2=1.88;
rho=0.91e-12;
d1=linspace(1e-6,1e-5,100);d2=linspace(1.01*1e-5,1e-3,900);
m1=rho*alfa1*(d1*1e6/2).^(beta1);
m2=rho*(alfa2*(d2*1e6/2).^(beta2)+alfap2*(d2*1e6/2).^(betap2));

N1=1/rms/gamma(gammas).*(d1/2/rms).^(gammas-1).*exp(-d1/2/rms);
N2=Nl_Ns/rml/gamma(gammal).*(d2/2/rml).^(gammal-1).*exp(-d2/2/rml);

Ns=IWC/((N1*m1'+N2*m2')*1e-6);
  
D=linspace(1e-6,1e-3,1000); 
dN=Ns/rms/gamma(gammas).*(D/2/rms).^(gammas-1).*exp(-D/2/rms)+Nl_Ns*Ns/rml/gamma(gammal).*(D/2/rml).^(gammal-1).*exp(-D/2/rml);

y=dN;
x=D;
