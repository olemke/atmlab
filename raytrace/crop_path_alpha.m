% CROP_PATH_ALPHA   Crops a propagation path at given alpha angle
%
% FORMAT   P = crop_path_length(P, alpha)
%
% OUT   P       Cropped array of path points
% IN    P       Original array of path points
%       alpha   Crop angle

% 2023-04-11 Patrick Eriksson

function P = crop_path_alpha(P, alpha)

l_crop = interp1([P.alpha], [P.length], alpha);

P = crop_path_length(P, l_crop);

