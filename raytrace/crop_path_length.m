% CROP_PATH_LENGTH   Crops a propagation path at given distance
%
% FORMAT   P = crop_path_length(P, l_crop)
%
% OUT   P        Cropped array of path points
% IN    P        Original array of path points
%       l_crop   Crop distance

% 2023-04-11 Patrick Eriksson


function P = crop_path_length(P, l_crop)

data = interp1([P.length], ...
               [[P.alpha];
                [P.n],
                [P.r],
                [P.theta],
                [P.x],
                [P.y]]', ...
               l_crop);

i = min(find([P.length] >= l_crop));

P = P(1:i);

P(i).alpha  = data(1);
P(i).length = l_crop;
P(i).n      = data(2);
P(i).r      = data(3);
P(i).theta  = data(4);
P(i).x      = data(5);
P(i).y      = data(6);
