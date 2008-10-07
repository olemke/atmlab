%GF_P2Z_FASCOD   Converts altitude to pressure
%
%                Converts altitude to pressure assuming
%                fascod relationship
%
% FORMAT   [P] = gf_p2z_fascod(Z, [ S ])
%        
% IN    Z   altitude in meters.
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
%       P   Pressure in Pascal
%
% 2007-11-01   Created by Bengt Rydberg

function [p]=gf_p2z_fascod(z,s)

if nargin==1
   s_DEFAULT='tropical';
   set_defaults;
end

fascod = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'atmosphere',...
                      'fascod',[s,'.z.xml']);

data   = xmlLoad(fascod);

p      = exp(interp1(data.data,log(data.p_grid),z));

if ~isempty(isnan(p))
   warning(['input data is nan or p values are out of range.',...
             ' allowed values are ', num2str(min(data.data)),...
             '-', num2str(max(data.data)),' m'])
end
