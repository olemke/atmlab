function L2 = run22(P,infile)
%
if nargin < 2, infile = 'H2O2018week_noTropcorr_q1_q3'; end


R = r22;
O = oi_observation_load( fullfile(P.indatafolder, infile) );


for i = 1 : size(O.tb,2)
  
  A = oi_atm_era5( P, O.mjd(i) );  
    
  if i == 1
    L2 = oi22_invert( P, R, A, O, i );
  else
    L2(i) = oi22_invert( P, R, A, O, i );
  end
end