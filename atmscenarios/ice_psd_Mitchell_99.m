% ice_psd_Mitchell_99  returns the particle size distribution in cirrus clouds.
%    
%     Returns a vector with the particle size distribution 
%     for a given temperature and ice water content and a vector
%     with the corresponding particle sizes, for a tropical
%     cirrus cloud. This parameterization is based on the distribution
%     of maximum dimension of planar polycrystals, and are based on 
%     measurements of ice crystals in the range 10^-6 m to 10^-3 m.  
%         
%     The parameterization is taken from Mitchell et al.
%     "A GCM parameterization of bimodal size spectra for ice clouds"
%     In Proceedings of the Ninth Atmospheric Radiation Measurement 
%     (ARM) Science Team Meeting, U.S Department of Energy, 
%     Washington, D.C. Available URL: 
%     http://www.arm.gov/publications/proceedings/conf09/abstracts/
%     mitchell2-99.pdf
%     
% FORMAT   [x,y] = ice_psd_Mitchell_99(T,IWC,Dmin,Dmax,n)     
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
%
% History: 2004-07-19  Created by Bengt Rydberg

function [x,y]=ice_psd_Mitchell_99(T,IWC,Dmin,Dmax,n);

if T>0
   error('Only temperatures smaller or equal to zero are allowed.')
end
if Dmin<1e-6
   error('Only Dmin larger than 10^-6 m is allowed')
end
if Dmax>1e-3
   disp('Warning: This parameterization is based on ice crystals smaller than 10^-3 m')
end

Dlg=1031*exp(0.05522*T)*1e-6;
lambdalg=1/Dlg;
lambdasm=(1.49*lambdalg+583*1e2);
IWCsmn=0.025*(1-exp(-(Dlg*1e6/80)^2))+exp(-(Dlg*1e6/80)^2);
IWCsm=IWC*IWCsmn;
IWClg=IWC-IWCsm;

rhosi=0.91*1e6;
alfa1=1.21;alfa2=6.96;
betasm=2.897;betalg=2.45;

alfasm=alfa1*rhosi*1e-18*(1e6/2)^(betasm);
alfalg=alfa2*rhosi*1e-18*(1e6/2)^(betalg);

N0sm=IWCsm*lambdasm^(betasm+1)/(alfasm*gamma(betasm+1));
N0lg=IWClg*lambdalg^(betalg+1)/(alfalg*gamma(betalg+1));

x=linspace(Dmin,Dmax,n);
Nsm=N0sm*exp(-lambdasm*x);
Nlg=N0lg*exp(-lambdalg*x);
Ntot=Nsm+Nlg;
y=Ntot;
