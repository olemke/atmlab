% I2PLANCKTB   Planck brightness temperature
%
%          Convert intensities to brigthness temperatures by "inverting" the
%          Planck function.
%
% FORMAT   tb = i2planckTb(i,f)
%
% OUT      tb   brightness temperatures [K]
% IN       i    intensities [W/(m^2*Hz*sr)]
%          f    frequencies [Hz]
%
% See also: planck, di2planckTb

% 2002-12-12   Created by Claudia Emde.
% 2017-01-05   Added feature to deal with reshape of singular dim f
%              Get not annoyed all the time because f is transposed
%              compared to i


function tb = i2planckTb(i,f)

planck = constants('PLANCK_CONST');
boltzmann = constants('BOLTZMANN_CONST');
speed_light = constants('SPEED_OF_LIGHT');

a = planck/boltzmann;
b = 2*planck/speed_light^2;

% change from here
i_dims = size(i); 
f_dims = size(f);

if f_dims ==[1,1]
    f = f * ones(i_dims);
    f_dims = size(f);
end

common_dims = ismember(i_dims, f_dims);

assert(any(common_dims), 'no common matrix dimension')

if any(f_dims ==1) && (length(i_dims(common_dims)) == 1)
    f_r = reshape(f, i_dims(common_dims),[]);
    f = repmat(f_r, 1, i_dims(~common_dims));
elseif ( all(common_dims) && (length(i_dims) == length(f_dims)) && ...
        any(i_dims ~= f_dims) ) % NOT efficient
    warning('dimension mismatch. I try to fix this, but that is not efficient.')
    for j = 1:length(i_dims)
        f = shiftdim(f, 1);
        if all(size(f) == i_dims)
            break
        end
    end  
end
% to here

tb = a * f ./ log((b*f.^3)./i + 1 );

end
