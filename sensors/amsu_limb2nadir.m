% AMSU_LIMB2NADIR  Estimates AMSU nadir Tb.
%
%    The function estimates the nadir brightness temperature for all 
%    channels of sensor part (a or b), by weighting the "limb" Tb
%    for all channels (of sensor part).
%
%    Coefficeints are taken from:
%       poes.nesdis.noaa.gov      Land, AMSU-B, satellite 15 and 16.
%
% FORMAT   tb_nadir = amsu_limb2nadir( sensor, fov, tb_limb, surftype )
%        
% OUT   tb_nadir   Nadir brightness temperatures
% IN    sensor     String giving satellite number and part, e.g. '15a'.
%                  Handled satellites are 15 and 16.
%       fov        Field of view index.
%       tb_limb    "Limb" tb values for all channels of sensor part.
%       surftype   Surface type. Possible choices are 'land'.

% 2004-04-07   Patrick Eriksson: Converted IDL function by Mashrab.


function tb_nadir = amsu_limb2nadir( sensor, fov, tb_limb, surftype )


%=== Check input
%
if ~isstr(sensor)  &  length(sensor) ~= 3
  error('Argument *sensor* must be a string of length three (e.g. ''15a'').');
end
%
satellite = str2num( sensor(1:2) );
part      = sensor(3);
%
if satellite < 15  |  satellite > 16
  error('Only satellite numbers handled at all are 15 and 16');
end
%
if part == 'a'
  error('AMSU-A is not yet handled');
  if any( fov < 0  |  fov > 14 )
    error('For AMSU-A, FOV is 0 - 14.');
  end
elseif part == 'b'
  if any( fov < 0  |  fov > 44 )
    error('For AMSU-B, FOV is 0 - 44.');
  end
  if length(tb_limb) ~= 5
    error('For AMSU-B, 5 Tb values must be given.');
  end
else
  error('Position 3 of *sensor* must be ''a'' or ''b''.');
end



if strcmp(lower(surftype),'land')
  %
  if part == 'b'
    if satellite == 15
      C = load( 'n15_limb_amsub_land.coeff' );
    elseif satellite == 16
      C = load( 'n16_limb_amsub_land.coeff' );
    end
   
    ind      = (0:4)*90 + fov + 1;
    tb_nadir = C(ind,1) + C(ind,2:6)*vec2col(tb_limb);
  end

else
   error('Allowed choices for *surftype* are ''land'' (yet nothing else).');
end
