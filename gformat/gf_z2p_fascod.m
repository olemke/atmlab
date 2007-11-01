%GF_Z2P_FASCOD   Converts pressure to altitude
%
%                Converts pressure to altitude assuming
%                fascod relationship
%
% FORMAT   [Z] = gf_p2z_fascod(P, [ S ])
%        
% IN    P   pressure in pascal
%       S   Sceanrio,
%           Default is tropical 
%           Options are:
%           midlatitude-summer
%           midlatitude-winter
%           subarctic-summer
%           subarctic-winter
%           tropical
%
% OUT
%       Z   altitude in meters
%
% 2007-11-01   Created by Bengt Rydberg

function [z]=gf_p2z_fascod(p,s)

if nargin==1
   s_DEFAULT='tropical';
   set_defaults;
end

fascod     = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'atmosphere',...
                      'fascod',[s,'.z.xml']);

data=xmlLoad(fascod);

z=interp1(log(data.p_grid),data.data,log(p));

if ~isempty(isnan(z))
   warning(['input data is nan or p values are out of range.',...
             ' allowed values are ', num2str(max(data.p_grid)),...
             '-', num2str(min(data.p_grid)),' Pa'])
end
