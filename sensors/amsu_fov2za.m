% AMSU_FOV2ZA  Converts AMSU FOVs to zenith angles.
%
%    Channel number can be 1 to 20.
%    FOVs can be 0-14 for AMSU-A, and 0-44 for AMSU-B.
%
% FORMAT   za = amsu_fov2za( channel, fov )
%        
% OUT   za        Zenith angle(s).
% IN    channel   Channel number (only one). 
%       fov       Vector or matrix with FOV values.

% 2004-04-07   Patrick Eriksson: Converted IDL function by Viju.


function za = amsu_fov2za( channel, fov )


if ~isscalar( channel )
  error('Input *channel* must be a scalar.');
end


if channel < 1  |  channel > 20
  %
  error('Allowed values for *channel* are 1 to 20.');

elseif channel <= 15
  %
  if any( fov < 0  |  fov > 14 )
    error('For AMSU-A, FOV is 0 - 14.');
  end
  %
  za = 180 - ( 1.65 + (14-fov) * 3.3 );

else
  %
  if any( fov < 0  |  fov > 44 )
    error('For AMSU-B, FOV is 0 - 44.');
  end
  %
  za = 180 - ( 0.55 + (44-fov) * 1.1 );

end