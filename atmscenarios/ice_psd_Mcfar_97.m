% ice_psd_Mcfar_97 returns the particle size distribution in cirrus clouds.
%    
%     Returns a vector with the particle size distribution for
%     a given temperature and ice water content, for a tropical cirrus cloud.
%     The parameterization is based upon the distribution of mass equivalent
%     spheres with diameter Dm=(6M/rhoice)^(1/3), where rhoice is the density
%     of solid ice spheres, and M is the mass of the ice crystal. 
%
%     The parameterization is taken from G.M McFarquhar and A.J Heymsfield,
%     "Parameterization of tropical cirrus ice crystal size distribution
%     and implications for radiative transfer: results from CEPEX",
%     J. Atmos. Sci., 54, 2187-2200, 1997
%
% FORMAT   [x,y] = ice_psd_Mcfar_97(T,IWC)     
%
% OUT      y is a vector with the particle size distribution [#/m³/m]
%          x is a vector from 10^(-6)m to 10^(-3)m with ecah step 10^(-6)m,
%          and represents the mass equivalent diameters of the ice particles.
% 
% IN       T   Temperature [Celsius]
%          IWC Ice water content [g/m3]

% History: 2004-07-19  Created by Bengt Rydberg

function [x,y]=ice_psd_Mcfar_97(T,IWC);

if T>0
   error('Only temperatures smaller or equal to zero are allowed.')
end
a=0.252;b=0.837;IWC0=1;
IWCs100=min(IWC,a*(IWC/IWC0)^(b));
IWCl100=IWC-IWCs100;

rhoice=0.91*1e6;

b=-4.99*1e-3;m=0.0494;
alfas100=(b-m*log10(IWCs100/IWC0))*1e6;

aamu=5.20;bamu=0.0013;
abmu=0.026;bbmu=-1.2*1e-3;
amu=aamu+bamu*T;
bmu=abmu+bbmu*T;
mul100=amu+bmu*log10(IWCl100/IWC0);

aasigma=0.47;basigma=2.1*1e-3;
absigma=0.018;bbsigma=-2.1*1e-4;
asigma=aasigma+basigma*T;
bsigma=absigma+bbsigma*T;
sigmal100=asigma+bsigma*log10(IWCl100/IWC0);

Dm=linspace(1e-6,1e-3,1000);
D0=1e-6;

Nm1=6*IWCs100*alfas100^(5)*Dm/(pi*rhoice*gamma(5)).*exp(-alfas100*Dm);

Nm2=6*IWCl100./(pi^(3/2)*rhoice*sqrt(2)*exp(3*mul100+9/2*sigmal100^(2))*Dm*sigmal100*D0^(3)).*exp(-1/2*((log(Dm/D0)-mul100)/sigmal100).^(2));

Nm=Nm1+Nm2;

x=Dm;
y=Nm;

