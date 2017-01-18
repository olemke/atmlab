% returns PSD according to kneifel et.al 2011 
%
% FORMAT dNdD = snow_psd_kneifel11(dmax,lambda,N0)
% 
% OUT   dNdD      The PSD, in a given particle size range speciefied by *Dmax*, [m^-4].
% IN    dmax      Vector with maximum dimensions, must be sorted, [m].
%       N0        Intercept parameter, [m^-4].
%       lambda    Slope term, [m^-1].

% 2017-01-09 Maryam Jamali

function dNdD = snow_psd_kneifel11(dmax,lambda,N0)
%

for i= 1:length(dmax)
    dNdD(i,1) = N0 .* exp(-lambda .* dmax(i));
end