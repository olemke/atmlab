% LAND_SEA_MASK   A 1 degree land-sea mask
%
%    Example:
%      [lat,lon,M] = land_sea_mask;
%      pcolor(lon,lat,double(M));shading flat
%
% FORMAT   [lat,lon,M] = land_sea_mask
%        
% OUT   lat   Latitude grid for M.
%       lon   Longitude grid for M.
%       M     Mask matrix, with 1 for land and 0 for sea.
%             Is of type logical.

% 2005-03-16   Created by Patrick Eriksson.

function [lat,lon,M] = land_sea_mask

atmlab( 'require', {'ARTS1_DATA_PATH'} );

addpath_ami;

lat = -90:90;
lon = 0:359;

M = read_datafile( fullfile(atmlab('ARTS1_DATA_PATH'), 'earth', ...
                    'land_sea_mask', 'land_sea_mask_360x181.aa' ), 'MATRIX' );

M = logical( M' );