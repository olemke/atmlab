% ice_psd_Ivanova_01 returns the particle size distribution in cirrus clouds.
%    
%     Returns a vector with the particle size distribution 
%     for a given temperature and ice water content, for a mid-latitude
%     cirrus cloud. This parameterization is based on the distribution
%     of maximum dimension of planar polycrystals, the assumption of 
%     planar polycrystals enters twice in the scheme and cancel out
%     each other, and Ivanova state the scheme is shape independent.  
%         
%     The parameterization is taken from Ivanova et al.
%     "A GCM parameterization for bimodal size spectra and ice mass 
%     removal rates in mid-latitude cirrus clouds"
%     Atmospheric Research 59-60, 89-113, 2001
%     
% FORMAT   [x,y] = ice_psd_Ivanova_01(T,IWC)     
%
% OUT      y is a vector with the particle size distribution [#/m³/m]
%          x is a vector from 10^(-6)m to 10^(-3)m with ecah step 10^(-6)m, 
%          and represents the maximum  dimensions of the ice particles.
%
% IN       T   Temperature [Celsius]
%          IWC Ice water content [g/m3]

% History: 2004-07-19  Created by Bengt Rydberg

function [x,y]=ice_psd_Ivanova_01(T,IWC);

if T>0
   error('Only temperatures smaller or equal to zero are allowed.')
end
Dsm=27.4*1e-6;
lambdasm=(3.24+1)/Dsm;
musm=3.24;
mulg=2.64;

rhosi=0.91*1e6;
alfa1=1.21;alfa2=6.96;
betasm=2.897;betalg=2.45;

alfasm=alfa1*rhosi*1e-18*(1e6/2)^(betasm);
alfalg=alfa2*rhosi*1e-18*(1e6/2)^(betalg);

Dlg=337.7*exp(0.01754*T)*1e-6;
lambdalg=(mulg+1)/Dlg;

IWCsmn=0.11+0.89*exp(-(Dlg/(50*1e-6))^(2));
IWClgn=1-IWCsmn;
IWCsm=IWC*IWCsmn;
IWClg=IWC*IWClgn;
Nosm=IWCsm*lambdasm^(betasm+musm+1)/(alfasm*gamma(betasm+musm+1));
Nolg=IWClg*lambdalg^(betalg+mulg+1)/(alfalg*gamma(betalg+mulg+1));
D=linspace(1e-6,1e-3,1000);
Nmsm=Nosm*D.^(musm).*exp(-lambdasm*D);
Nmlg=Nolg*D.^(mulg).*exp(-lambdalg*D);
Nm=Nmsm+Nmlg;

x=D;
y=Nm;

