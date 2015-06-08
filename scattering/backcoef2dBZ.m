% BACKCOEF2DBZ   Radar dBZ reflectivity.
%
%    Converts backscattering coefficient to decibels of Z, where Z is the
%    equivalent reflectivity.
%    
%    N.B. Radar equivalent reflectivity includes a factor 
%    (dielectric factor of water)   
%    which is a function of temperature and frequency.
%    It seems to be no standard value for this factor
%    for Radar equivalent reflectivity products.   
%
%    Note also that *b* equals 4pi*Z(Omega=180), following the standard
%    practice in the radar community.
%
% FORMAT  Ze = backcoef2dBZ(lambda,b [,t0,Kwater2])
%
% OUT     Ze         10*log10 of radar equivalent reflectivity 
%                    (defined w.r.t. liquid water) [mm6/m3] 
%
% IN      lambda     wavelength  [m] (scalar)
%         b          backscattering coefficient [1/m] (any numeric)
% OPT     t0         temperature (scalar), used for calculating
%                    dielectric factor of water. Default is 273.15 K.
%         Kwater2    Dielectric factor of water (scalar), Default is empty,
%                    and that Kwater2 is calculated from lambda and t0.
%                    When this input is used, t0 is not used.
%                    (CloudSat official product uses 0.75)       
%
% Example usage: 
%
% % use default temperature
% Ze = backcoef2dBZ(lambda,b)
% 
% % use a different temperature
% Ze = backcoef2dBZ(lambda,b,t0) 
% 
% % use a specified Dielectric factor 
% Ze = backcoef2dBZ(lambda,b,[],0.75)
%       
% History: 2010-02-02 Created by Bengt Rydberg

function Ze = backcoef2dBZ( lambda, b , varargin)

strictAssert = atmlab('STRICT_ASSERT');
 
if strictAssert      
  rqre_datatype( lambda, @istensor0 );
  rqre_in_range( lambda, 0.3e-3, 1 );
  rqre_datatype( b, {@isnumeric} ); 
end

[t0,Kwater2] = optargs( varargin, { 273.15, [] } );

%calculate dielectric factor of water
if isempty(Kwater2);
  c       = constants('SPEED_OF_LIGHT');
  nwater  = sqrt( eps_water_liebe93(c/lambda,t0) );
  Kwater2 = ( abs( (nwater.^2-1)./ (nwater.^2+2) ) ).^2;
end

Ze = 10*log10( (1e18*lambda^4/Kwater2/pi^5) * b );

