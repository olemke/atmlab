% ASG_RANDOMIZE_STD   Adds random disturbances of ASG variables
%
%    Disturbes the following atmospheric fields:
%       ABS_SPECIES     0 
%       T             100 K
%    The second column above gives lowest allowed values. Lower values are
%    set to the threshold value.
%
%    The disturbances are based on the D field of the variables listed
%    above. See *covmat3d* for description of D.
%
% FORMAT   Gcs = asg_randomize_std( A, Gcs )
%        
% OUT   Gcs   Modified clear sky profiles. 
% IN    A     Settings for arts scene generator.
%       Gcs   Clear sky profiles in gformat. 

% 2007-10-12   Created by Patrick Eriksson.


function Gcs = asg_randomize_std( A, Gcs )
  

%- Get data dimensions
%
n = [ length( A.P_GRID ) 1 1 ];
%
if A.ATMOSPHERE_DIM >= 2
  n(2) = length( A.LAT_GRID );
end
%
if A.ATMOSPHERE_DIM >= 3
  n(2) = length( A.LON_GRID );
end

  

for ig = 1 : length(Gcs)

  if strcmp( Gcs(ig).data_name, 'Temperature' )
    D    = A.T.D;
    name = 'Temperature';
    minv = 100;
  elseif strcmp( Gcs(ig).data_name, 'Volume mixing ratio' )
    name = Gcs(ig).name;
    ias  = strcmp( name, {A.ABS_SPECIES.NAME} );
    minv = 0;
    if isempty( ias )
      continue;   % Nothing to do
    end
    D    = A.ABS_SPECIES(ias).D;
  else
    continue;   % Nothing to do
  end
  
  if ~isstruct(D)
    continue;   % Nothing to do
  end
  
 
  %- Create covariance matrix for disturbance
  %
  S = covmat3d( A.ATMOSPHERE_DIM, D , A.P_GRID, A.LAT_GRID, ...
                                                          A.LON_GRID, 'atm' );

  %- Create disturbance
  %
  if strcmp( D.TYPE, 'rel' )
    Gcs(ig).data = Gcs(ig).data .* reshape( randmvar_normal2( 1, S, 1 ), n );
    
  elseif strcmp( D.TYPE, 'abs' )
    Gcs(ig).data = Gcs(ig).data + reshape( randmvar_normal2( 0, S, 1 ), n );
  else
    error( sprintf( 'Unknown selection of D.TYPE for %s (Gcs item %d).', ...
                                                                 name, ig ) );
  end
  
  %- Remove too low values
  %
  ind               = find( Gcs(ig).data < minv );
  Gcs(ig).data(ind) = minv;
  
end
