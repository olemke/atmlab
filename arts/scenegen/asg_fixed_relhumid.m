% ASG_FIXED_RELHUMID   Sets a fixed relative humidity
%
%    Water VMR profiles are set to the selected relative humidity (*rh*) inside
%    selected altitude range. This is done for all items of Gcs where the field
%    *name* starts with 'Water'.
%
%    The profiles are set to *rh* up to the altitude corresponding to
%    *brakep*. A linear transition to the original profile is performed
%    between *brakep* and *topp*. 
%
%    The relative humidity with respect to water is considered for temperatures
%    above 0C, and the humidity with respect to ice for lower temperatures.
%
% FORMAT   Gcs = asg_fixed_relhumid( Gcs, rh, brakep, topp )
%        
% OUT   Gcs     As input *Gcs*, but with modified water profiles 
% IN    Gcs     Clear sky profiles in gformat. 
%       rh      Selected relative humidity.
%       brakep  Brake point between fixed relative humidity and linear
%               transition to original profile.
%       topp    Original grid is unaffected above the point.

% 2007-10-12   Created by Patrick Eriksson.


function Gcs = asg_fixed_relhumid( Gcs, rh, brakep, topp )
  
  
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
      ind = find( Gcs(ig).grid1 >= topp );
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
      vmr = rh*( ww.*ew + (1-ww).*ei ) ./ Gcs(ig).grid1(ind);
        
      %- Determine weight for vmr
      %
      ww             = ( log10(Gcs(ig).grid1(ind)) - log10(topp) ) / ...
                       ( -log10(topp) + log10(brakep)  );
      ww(find(ww>1)) = 1;
      
      %- Create new profile
      %
      Gcs(ig).data(ind,ilat,ilon) = ww.*vmr + ...
                                          (1-ww).*Gcs(ig).data(ind,ilat,ilon);
    end
  end
end