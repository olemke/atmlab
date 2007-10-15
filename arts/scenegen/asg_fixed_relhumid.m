% ASG_FIXED_RELHUMID   Sets a fixed relative humidity
%
%    Water VMR profiles are set to the selected relative humidity inside
%    selected altitude range. This is done for all items of Gcs where the field
%    *name* starts with 'Water'.
%
%    The function uses the following fields of A:
%       H2O.FIXED_RH       Boolean
%       H2O.RH             Relative humidity [-] (  not %, a value around 0-1.6)
%       H2O.RH_BRAKEP      Brake point [Pa or m]
%       H2O.RH_TOPP        Top altitude [Pa or m]
%
%    Nothing is done if H2O.FIXED_RH is false. Otherwise:
%
%    The profiles are set to H2O.RH up to the altitude corresponding to
%    H2O.RH_BRAKEP. A linear transition to the original profile is performed
%    between H2O.RH_BRAKEP and H2O.RH_TOPP.
%
%    Two options exist for H2O.RH_BRAKEP and H2O.RH_TOPP:
%       1. Given as pressure levels.
%       2. Distance to local tropopause (not yet implemented).
%
%    The relative humidity with respect to water is considered for temperatures
%    above 0C, and the humidity with respect to ice for lower temperatures.
%
% FORMAT   Gcs = asg_fixed_relhumid( A, Gcs )
%        
% OUT   Gcs     As input *Gcs*, but with modified water profiles 
% IN    A           Settings for arts scene generator.
%       Gcs     Clear sky profiles in gformat. 

% 2007-10-12   Created by Patrick Eriksson.


function Gcs = asg_fixed_relhumid( A, Gcs )

  
%- Basic check of input
%
qcheck( @asg, A );
%
rqre_field( A.H2O, 'FIXED_RH', 0 );


if ~A.H2O.FIXED_RH
  return        % ---->
else
  rqre_field( A.H2O, 'RH', 0 );
  rqre_scalar( 'A.H2O.RH', A.H2O.RH, 0, 2 );
  rqre_field( A.H2O, 'RH_BRAKEP', 0 );
  rqre_field( A.H2O, 'RH_TOPP', 0 );
end



%- Find temperature 
%
it = min( find( strcmp( {Gcs.name}, 'Temperature' ) ) );
%
if isempty( it )
  error( 'Could not locate any temperature data in Gcs.' );
end


%- Find water species
%
ih2o = find( strncmp( {Gcs.name}, 'Water', 5 ) );
%
if isempty( it )
  error( 'Could not locate any water vapour data in Gcs.' );
end


for ig = ih2o
  
  for ilon = 1:size(Gcs(ig).data,3)
    for ilat = 1:size(Gcs(ig).data,2)
        
      %- Find range of interest and obtain relavant data
      %
      ind = find( Gcs(ig).grid1 >= A.H2O.RH_TOPP );
      %
      t = interpp( Gcs(it).grid1, Gcs(it).data(:,ilat,ilon), ...
                                                      Gcs(ig).grid1(ind) );
      ei = e_eq_ice( t );
      ew = e_eq_water( t );
      
      %- Determine relative weight for ew
      %
      ww = t >= 273.15;
      
      %- VMR for selected relative humidity
      %
      vmr = A.H2O.RH * ( ww.*ew + (1-ww).*ei ) ./ Gcs(ig).grid1(ind);
        
      %- Determine weight for vmr
      %
      ww = ( log10(Gcs(ig).grid1(ind)) - log10(A.H2O.RH_TOPP) ) /...
                       ( -log10(A.H2O.RH_TOPP) + log10(A.H2O.RH_BRAKEP)  );
      ww(find(ww>1)) = 1;
      
      %- Create new profile
      %
      Gcs(ig).data(ind,ilat,ilon) = ww.*vmr + ...
                                          (1-ww).*Gcs(ig).data(ind,ilat,ilon);
    end
  end
end