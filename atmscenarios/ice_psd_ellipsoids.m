% ice_psd_ellipsoids  translates particle size distribution for a given
%                     particle size distribution into a distribution of
%                     mass equivalent ellipsoids in cirrus clouds,
%                     and returns the new distribution.
%    
%     Returns a vector with the particle size distribution 
%     for a given temperature, ice water content, and particle
%     size distribution, and a vector with the corresponding 
%     particle mass equivalent ellipsoids diameter, for a 
%     cirrus cloud.
%     The ellipsoids "diameters" are D,Da,Db, where D is the
%     major diameter,Da/D=a, and Db/D=b.   
%     This function takes a given exponential or gamma bimodal size 
%     distribution, which is based on the assumption of a certain
%     habit of the ice crystals, and by using mass - diameter relations,
%     translates the distribution into an exponential or gamma bimodal
%     size distribution of mass equivalent ellipsoids.
%     
%     The treatment of a gamma bimodal size distribution is taken 
%     from Ivanova et al.
%     "A GCM parameterization for bimodal size spectra and ice mass 
%     removal rates in mid-latitude cirrus clouds"
%     Atmospheric Research 59-60, 89-113, 2001
% 
%     The mass - diameter relations are taken from Donovan 
%     "Ice cloud effective particle size parameterization based
%     on combined lidar, radar reflectivity, and mean Doppler
%     velocity measurements"
%     J. of Geophys. res., vol. 108, NO. D18, 4573, 2003
% 
%     and Mitchell
%     "Use of mass and area dimensional power laws for determining
%     precipitation particle terminal velocities"
%     J. of Atm. Sci., vol 53, No. 12, 1710-1723, 1996
%    
% FORMAT   [x,y] = ice_psd_ellipsoids(T,IWC,Dmin,Dmax,n,a,b,psd)     
%
% OUT      y is a vector with the particle size distribution [#/m³/m]
%          x is a vector from Dmin to Dmax with  n points, 
%          and represents the major diameter of the mass 
%          equivalent ellipsoids.
%
% IN       T     Temperature [Celsius]
%          IWC   Ice water content [g/m3]
%          Dmin  Minimum dimension of ice crystals [m]
%          Dmax  Maximum dimension of ice crystals [m]
%          n     Number of points from Dmin to Dmax
%          a     Aspect ratio 0<a<=1 
%          b     Aspect ratio 0<b<=1 (a=b=1 for spheres)
%          psd   The specific particle size distribution
%                one wants to translate
%                1=ice_psd_Ivanova_01(planar polycrystals)
%                2=ice_psd_Ivanova_01(bullet rosettes)
%                3=ice_psd_Ivanova_01(hexagonal plates)
%                4=ice_psd_Ivanova_01(hexagonal columns)
%                5=ice_psd_Donovan_03(complex polycrystals) 
%                6=ice_psd_Donovan_03(compact polycrystals)     
%                7=ice_psd_Mitchell_99(planar polycrystals)
%
% History: 2004-07-19  Created by Bengt Rydberg

function [x,y]=ice_psd_ellipsoids(T,IWC,Dmin,Dmax,n,a,b,psd);

if T>0
   error('Only temperatures smaller or equal to zero are allowed.')
end
if a<=0
   error('Only aspect ratio a larger than zero is allowed.')
end
if a>1
   error('Only aspect ratio a equal or smaller to one is allowed.')
end
if b<=0
   error('Only aspect ratio b larger than zero is allowed.')
end
if b>1
   error('Only aspect ratio b equal or smaller to one is allowed.')
end
if ((psd~=1) && (psd~=2) && (psd~=3) && (psd~=4) && (psd~=5) && (psd~=6) && (psd~=7))
   error('Only psd 1,2,3,4,5,6, and 7 are allowed.')
end

if psd==1
   %mass - diameter constants for planar polycrystals  
   alfa1=1.21; beta1=2.897;
   alfa2=6.96;beta2=2.45;
   alfap2=0;betap2=0;
   rho=0.92*1e6;
   [x1,y1]=ice_psd_Ivanova_01(T,IWC,1e-6,1e-3,1000,1);
end

if psd==2
   %mass - diameter constants for bulett rosettes
   betasm=2.75;betalg=betasm;
   alfasm=0.0260*(1e2)^betasm;alfalg=alfasm;
   rho=0.92*1e6;
   [x1,y1]=ice_psd_Ivanova_01(T,IWC,1e-6,1e-3,1000,2);
end

if psd==3
   %mass - diameter constants for hexagonal plates
   betasm=2.45; betalg=betasm;
   alfasm=0.00739*(1e2)^betasm;
   alfalg=alfasm;
   rho=0.92*1e6;
   [x1,y1]=ice_psd_Ivanova_01(T,IWC,1e-6,1e-3,1000,3);
end

if psd==4
   %mass - diameter constants for hexagonal columns
   betasm=2.91;betalg=1.91;
   alfasm=0.1677*(1e2)^betasm;
   alfalg=0.00166*(1e2)^betalg;
   rho=0.92*1e6;
   [x1,y1]=ice_psd_Ivanova_01(T,IWC,1e-6,1e-3,1000,4);
end

if psd==5
   %mass - diameter constants for complex polycrystals
   alfa1=4.3;beta1=2.88;
   alfa2=1.38;beta2=2.88;
   alfap2=145.73;betap2=1.88;
   rho=0.91*1e6;
   [x1,y1]=ice_psd_Donovan_03(T,IWC,1e-6,1e-3,1000,1); 
end

if psd==6
   %mass - diameter constants for compact polycrystals
   alfa1=3.73;beta1=2.88;
   alfa2=0.84;beta2=2.88;
   alfap2=144.96;betap2=1.88;
   rho=0.91*1e6;
   [x1,y1]=ice_psd_Donovan_03(T,IWC,1e-6,1e-3,1000,2); 
end

if psd==7
   %mass - diameter constants for planar polycrystals
   alfa1=1.21; beta1=2.897;
   alfa2=6.96;beta2=2.45;
   alfap2=0;betap2=0;
   rho=0.91*1e6;
   [x1,y1]=ice_psd_Mitchell_99(T,IWC,1e-6,1e-3,1000);
end

d1=linspace(1e-6,1e-4,100);
d2=linspace(1.01e-4,1e-3,900);

if ((psd==1)|| (psd==5) || (psd==6) || (psd==7))
   m1=rho*1e-18*alfa1*(d1*1e6/2).^(beta1);
   m2=rho*1e-18*(alfa2*(d2*1e6/2).^(beta2)+alfap2*(d2*1e6/2).^(betap2));
   D1=((6*alfa1/pi/a/b*(d1*1e6/2).^beta1).^(1/3))*1e-6;
   D2=((6/pi/a/b*(alfa2*(d2*1e6/2).^beta2+alfap2*(d2*1e6/2).^betap2)).^(1/3))*1e-6;
end

if ((psd==2) || (psd==3) || (psd==4))
   m1=alfasm*d1.^betasm;
   m2=alfalg*d2.^betalg;
   D1=(6*alfasm/rho/pi/a/b*d1.^betasm).^(1/3);
   D2=(6*alfalg/rho/pi/a/b*d2.^betalg).^(1/3);
end
  
  
D0=zeros(1,1000);
D0(1,1:100)=D1;
D0(1,101:1000)=D2(1,1:900);

Nsm=0;
for n=1:1:100
    Nsm=Nsm+y1(n)*1e-6;
end;
Dsm=D1*1e-6*y1(1:100)'/Nsm;

Nlg=0;
for n=101:1:1000
    Nlg=Nlg+y1(n)*1e-6;
end
Dlg=D0(101:1000)*1e-6*y1(101:1000)'/Nlg;

IWCsm=1e-6*m1*y1(1:100)';

IWC11=0;
for i=1:1:100
    IWC11=IWC11+rho*pi/6*a*b*(D0(i))^3*y1(i)*1e-6;
    if IWC11>=IWCsm/2
       break
    end
end
Dsmm=D0(i);

IWClg=1e-6*m2(1:900)*y1(101:1000)';

IWC22=0;
for i=101:1:1000
    IWC22=IWC22+rho*pi/6*a*b*(D0(i))^3*y1(i)*1e-6;
    if IWC22>=IWClg/2
       break
    end
end
Dlmm=D0(i);

beta=3;
musm=((beta+0.67)*Dsm-Dsmm)/(Dsmm-Dsm);
mulg=((beta+0.67)*Dlg-Dlmm)/(Dlmm-Dlg);

if psd==7
   musm=0;
   mulg=0;
end

lambdasm=(musm+1)/Dsm;
lambdalg=(mulg+1)/Dlg;

N0sm=Nsm*lambdasm^(musm+1)/gamma(musm+1);
N0lg=Nlg*lambdalg^(mulg+1)/gamma(mulg+1);

if psd==7
   N0sm=IWCsm*lambdasm^(beta+1)/(rho*pi/6*a*b*gamma(beta+1));
   N0lg=IWClg*lambdalg^(beta+1)/(rho*pi/6*a*b*gamma(beta+1));
end

x=linspace(Dmin,Dmax,n);
y=N0sm*x.^musm.*exp(-lambdasm*x)+N0lg*x.^mulg.*exp(-lambdalg*x);
