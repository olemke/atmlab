% ice_psd_Ivanova_01 returns the particle size distribution in cirrus clouds.
%    
%     Returns a vector with the particle size distribution 
%     for a given temperature and ice water content and a vector
%     with the corresponding particle sizes, for a mid-latitude
%     cirrus cloud. This parameterization is based on the distribution
%     of maximum dimension of the particle shapes, and are based on 
%     measurements of ice crystals in the range 10^-6 m to 10^-3 m.  
%         
%     The parameterization is taken from Ivanova et al.
%     "A GCM parameterization for bimodal size spectra and ice mass 
%     removal rates in mid-latitude cirrus clouds"
%     Atmospheric Research 59-60, 89-113, 2001
%     
% FORMAT   [x,y] = ice_psd_Ivanova_01(T,IWC,Dmin,Dmax,n,shape)     
%
% OUT      y is a vector with the particle size distribution [#/m³/m]
%          x is a vector from Dmin to Dmax with  n points [m], 
%          and represents the maximum  dimensions of the ice particles.
%
% IN       T     Temperature [Celsius]
%          IWC   Ice water content [g/m3]
%          Dmin  Minimum dimension of ice crystals [m]
%          Dmax  Maximum dimension of ice crystals [m]
%          n     number of points from Dmin to Dmax
%          shape 1=planar polycrystals
%                2=bulett rosettes
%                3=hexagonal plates
%                4=hexagonal columns     
%
% History: 2004-07-19  Created by Bengt Rydberg

function [x,y]=ice_psd_Ivanova_01(T,IWC,Dmin,Dmax,n,shape);

if T>0
   error('Only temperatures smaller or equal to zero are allowed.')
end
if Dmin<1e-6
   error('Only Dmin larger than 10^-6 m is allowed.')
end
if Dmax>1e-3
   disp('Warning: This parameterization is based on ice crystals smaller than 10^-3 m.')
end
if ((shape~=1) && (shape~=2) && (shape~=3) && (shape~=4))
   error('Only shape 1,2,3,or 4 are allowed.')
end
musm=3.24;
mulg=2.64;
Dsm=27.4*1e-6;
lambdasm=(3.24+1)/Dsm;
Dlg=337.7*exp(0.01754*T)*1e-6;
lambdalg=(mulg+1)/Dlg;

rhosi=0.92*1e6;

if shape==1
   %constants for planar polycrystals
   alfa1=1.21;alfa2=6.96;
   betasm=2.897;betalg=2.45;
   alfasm=alfa1*rhosi*1e-18*(1e6/2)^(betasm);
   alfalg=alfa2*rhosi*1e-18*(1e6/2)^(betalg);
   IWCsmn=0.11+0.89*exp(-(Dlg*1e6/50)^2);
end

if shape==2
   %constants for bulett rosettes
   betasm=2.75;betalg=betasm;
   alfasm=0.0260*(1e2)^betasm;alfalg=alfasm;
   L=-0.00009524*Dlg*1e6+0.1200;
   IWCsmn=L+(1-L)*exp(-(Dlg*1e6/45)^2);
end

if shape==3
   %constants for hexagonal plates
   betasm=2.45;betalg=betasm;
   alfasm=0.00739*(1e2)^betasm;
   alfalg=alfasm;
   IWCsmn=0.11+0.89*exp(-(Dlg*1e6/50)^2);
end

if shape==4
   %constants for hexagonal columns
   betasm=2.91;betalg=1.91;
   alfasm=0.1677*(1e2)^betasm;
   alfalg=0.00166*(1e2)^betalg;
   L=0.0009722*Dlg*1e6-0.05833;
   IWCsmn=L+(1-L)*exp(-(Dlg*1e6/85)^2);
end

IWClgn=1-IWCsmn;
IWCsm=IWC*IWCsmn;
IWClg=IWC*IWClgn;

Nosm=IWCsm*lambdasm^(betasm+musm+1)/(alfasm*gamma(betasm+musm+1));
Nolg=IWClg*lambdalg^(betalg+mulg+1)/(alfalg*gamma(betalg+mulg+1));

x=linspace(Dmin,Dmax,n);
Nmsm=Nosm*x.^(musm).*exp(-lambdasm*x);
Nmlg=Nolg*x.^(mulg).*exp(-lambdalg*x);
Nm=Nmsm+Nmlg;
y=Nm;
