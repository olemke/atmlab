% ICE_PSHAPE_HOGAN12   Hogan et al 2012 particle shape model
%
%   Hogan et al combines the Brown and Francis (1997) size-mass relationship
%   with assumptions on shape to obtain a complete particle shape model.
%   Particles up to 66 um are spherical, while particle having a Dmax above
%   97 um are oblate spheroids with an aspect ratio of 1.67. Between 66 and
%   97 um there is a gradual change of the aspect ratio. Note that an
%   "Tmatrix aspect ratio" equals an axis ratio of 0.6.
%
%   The aspect ratio of 1.67 can be changed with *aratio0*. This does not
%   change the transition from spheres to spheroid, as a function of Dmax.
%
%   In the region 66 to 100 um the expressions can lead to densities above the
%   one of solid ice. The solid ice value is then used.
%
% FORMAT [dmax,aratio,airfrac,mass,rho] = ice_pshape_Hogan2012(deq,[aratio0])
%
% OUT dmax      Maximum diameter.
%     aratio    Aspect ratio.
%     airfrac   Air fraction.
%     mass      Mass of the particle.
%     rho       Density of the particle
% IN  deq       Mass equivalent sphere diameter. Can be a vector. The output
%               arguments have then the same size.
% OPT aratio0   The aspect ration for particles above 97 um. Defualt is 1.67,
%               the value suggest by Hogan et al 2012. A scalar, must be z<=1.

% 2014 Maryam Jamali and Patrick Eriksson

function [dmax,aratio,airfrac,mass,rho] = ice_particleshape_Hogan2012( ...
                                                                 deq,varargin)
%
[aratio0] = optargs( varargin, { 1.67 } );

rqre_datatype( deq, @isvector );
rqre_datatype( aratio0, @istensor0 );
rqre_in_range( aratio0, 1e-2 );


[dmax,aratio,airfrac,mass,rho] = deal( zeros( size( deq ) ) );


% Density of solid ice assumed in ther paper
rho0 = 480 * 6 / pi;


for i = 1 : length(deq)

  mass(i) = rho0 * pi * power(deq(i),3) / 6;

  % Dmax, assuming above dmax > 66 um
  dmax(i) = power( mass(i)/0.0121, 1/1.9 );

  % Solid sphere regime
  if dmax(i) < 66e-6
    dmax(i)    = deq(i);
    aratio(i)  = 1;
    airfrac(i) = 0;
    rho(i)     = rho0;
  else
    % Regime of linearly varying aspect ratio
    if dmax(i) < 97e-6
      x         = (dmax(i)-66e-6)/32e-6;
      dmean     = dmax(i) / (1+0.25*x);
      aratio(i) = 2*dmean/dmax(i) - 1;    
    else
      aratio(i) = aratio0;
    end

    volume = pi * power(dmax(i),3) / 6;
    if aratio <= 1
      volume = aratio * volume;
    else
      volume = volume / aratio;
    end
    
    % Make sure that rho don't exceeeds rho0
    rho(i)     = min([ rho0, mass(i) / volume  ] );
    airfrac(i) = (rho0-rho(i))/(rho0-1);   % 1 kg/m3 for air
    
    % Make sure that mass is consistent with rho
    mass(i) = rho(i) * volume;
  end
end




% Old version by Maryam

% ice_particleshape_Hogan2012   Dimension parameters(long and short diameters)
%                               and density of a non-spherical and non-solid 
%                               ice particle that composes ice matrix with air inclusion.
%                         
%
%   The equivalent mass of a spherical solid ice is calculated upon the 
%   distribution of mass equivalent spheres m=(power(d,3)*pi*rhoice)/6;  
%   then according to Brown and Francis(1995)relationship between
%   particle mass and size, the mean and max(long) diameters, 
%   and inclusion media fraction of a non-spherical(spheroidal) 
%   particle which has the *same mass*, are computed.
%   
%   Note that all of the outputs are as a function of mass-equivalent 
%   diameter (d).
%   
%   The parameterization is taken from R. Hogan et al(2012).
%   "Radar Scattering from Ice Aggregates Using the Horizontally 
%   Aligned Oblate Spheroid Approximation".
%             
%                        
% 
% FORMAT [diameter_max diameter_short aspect_ratio mixfrac rho]= ice_particleshape_Hogan2012(d)
%        
% OUT  diameter_max   longest diameter of an aligned oblate spheroid particle  [m]      
%      diameter_short shortest diameter of an aligned oblate spheroid particle [m]  
%      aspect_ratio   d_short / d_long
%      mixfrac        Fraction of inclusion media (air) in ice matrix.
%      rho            Density of a sheroid of non-solid ice particle      [kg/m^3]
%                     (mixture of ice and air)               
%
% IN   d              mass equivalent diameter       [m]     
       
% 2013-08-09    Created by Maryam Jamali


function  [diameter_max diameter_short aspect_ratio mixfrac rho]= ice_particleshape_Hogan2012_old(d)


rhoice=0.917*1e3;     % kg/m^3

%To calculate diameter_max and diameter_short :
for i=1:length(d)
    m=(power(d(i),3)*pi*rhoice)/6;   %kg 
    D_0=power((m./(pi*rhoice/6)),(1/3));
    
    if D_0 < 97e-6
    diameter_mean(i)=D_0;
    else
    diameter_mean(i)=power((m./0.0185), (1/1.9));
    end

    if  D_0 < 66e-6
    diameter_max(i)=D_0;
    else
    diameter_max(i)=power((m./0.0121), (1/1.9));
    end
    
    diameter_long(i) =diameter_max(i);
    diameter_short(i)=(2*diameter_mean(i))-diameter_max(i);
    aspect_ratio(i)=diameter_short(i)./diameter_long(i);
    
    volume_ice(i)= (pi/6).* power(d(i),3);
    
    if diameter_short(i)==diameter_long(i)
    rho(i)=rhoice;
    volume_spheroid(i)=volume_ice(i);
    else
    volume_spheroid(i)=(pi/6).*power(diameter_long(i),2).*diameter_short(i);
    rho(i)=m./volume_spheroid(i); % kg/m^3
    end
end

mixfrac=(volume_spheroid - volume_ice)./ volume_spheroid;
