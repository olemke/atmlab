% SNOW_PSD_FIELD07   Midlat and tropical snow/ice PSD by Field et al 2007
%
%    For details about this PSD, read 'Snow size distribution parameterization
%    for midlatitude and tropical ice clouds' by Field et al JAS2007
%
%    There are two versions of the PSD, one tropical and one mid-latitude
%    one. The version is selected by the argument *lats*, where 't' or 'T'
%    triggers the tropical PSD nad 'm' or 'M* the mid-latitude one.
%
%    The PSD is based on particle maximum dimensions, *dmax*. The relationship
%    between maximum dimension and particle mass must be specified, and then
%    in the form m = a * dmax^b. The constants *a* and *b* are input
%    arguments, and should be in SI units. For example, solid ice has 
%    a = 480 and b = 3.
%
%    This function is based directly on the Fortran code provided by Field.
%
% FORMAT dNdD = snow_psd_field07(dmax,iwc,t,a,b,lats)
% 
% OUT   dNdD    The PSD, at sizes speciefied by *max*, [m^-4].
% IN    dmax    Vector with maximum dimensions, must be sorted.
%       iwc     Ice/snow water content, [kg/m3].
%       t       Temperature, [K].
%       a       Constant in Dmax-mass relationship, see above.
%       b       Constant in Dmax-mass relationship, see above.
%       lats    Latitude range, 't' or 'm'. 

% 2014-11-08 Patrick Eriksson

function dNdD = snow_psd_field07(dmax,iwc,t,a,b,lats)

% Check input, and that values are not completly wrong
if not( isvector( dmax) & issorted( dmax ) )
  error( '*dmax must be a sorted vector' );
end
rqre_in_range( iwc, 0, 100e-3 );
rqre_in_range( t, 150, 280 );
rqre_in_range( a, 0.001, 1e3 );
rqre_in_range( b, 1, 3 );
rqre_datatype( lats, @ischar ); 

% If temperature outside range allowed in Field's code, use values for end
% point (note temperature restriction above)
if t > 273.15 
  t = 273.15;
elseif t < 203.15
  t = 203.15;
end

% Get data for prescribed dmax
%
[dmax0,dNdD0] = snow_psd_field07_core( iwc, t, a, b, lats );

% Interpolate to user dmax, using log(dNdD)
dNdD = exp( interp1( dmax0, log(dNdD0), dmax, 'linear', 'extrap' ) ); 

return



function [dmax,dNdD] = snow_psd_field07_core(iwc,t,a,b,lats)

% Calculate 2nd moment
my = iwc / a;  % yth moment


% use moment relations to get 2nd moment required for predicting psd
m2 = my;       % default for UM y=2 

% if y ne 2 then need to find second moment before proceeding
if not( b == 2 )
  m2 = -9999;
  [m2,my] = predict_mom07( m2, t, b, my );
end

% !!M2 range check (1e-5 3e-2 m^-1)!!!!!!!!!!!!!!!!!!!!!
if m2 < 0.0
  error( 'Negative M2' );
end
if m2 < 1e-5  |  m2 > 0.1
  warning( 'M2 outside of range in original data' );
end


% Use 2nd and 3rd moment to predict psd;;;;;;;;;;;;;;;;;;;;
n = 3;
[m2,m3] = predict_mom07( m2, t, n, NaN );

%L32 = 1e6*m3/m2  % um

% !!!define universal psd!!!!
%
xx = [1:10 12:2:30 35:5:100 150:50:500 600:100:2e3]/40;  % dimensionless size
if strcmp( upper(lats), 'T' )
  phi = 152.0 * exp(-12.4*xx) + 3.28 * power(xx,-0.78) .* exp(-1.94*xx);
elseif strcmp( upper(lats), 'M' )
  phi = 141.0 * exp(-16.8*xx) + 102.0 * power(xx,2.07) .* exp(-4.82*xx);
else
  error( '*lats* must be ''t'' or ''m''.' );
end
dmax = xx * (m3/m2);
dNdD = phi * power(m2,4)/power(m3,3);



% subroutine to predict nth moment m given m2, tc, n
% if m2=-9999 then the routine will predict m2 given m,n,tc
function [m2,m] = predict_mom07( m2, t, n, m )
  %
  tc = t - 273.15;
  %
  a1 =    13.6078;
  a2 =   -7.76062;
  a3 =   0.478694;
  b1 = -0.0360722;
  b2 =  0.0150830;
  b3 = 0.00149453;
  c1 =   0.806856;
  c2 = 0.00581022;
  c3 =  0.0456723;
  %
  ai = a1 + a2*n + a3*power(n,2);
  bi = b1 + b2*n + b3*power(n,2);
  ci = c1 + c2*n + c3*power(n,2);
  %
  A = exp( ai );
  B = bi;
  C = ci;
  %     
  if m2 == -9999
    % get m2 if mass-dimension relationship not proportional to D**2
    m2 = power( m/(A*exp(B*tc)), 1/C );    
  else
    % predict m from m2 and tc
    m = A*exp(B*tc) * power(m2,C);
  end
return        


