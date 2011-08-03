function [data] = modlev2presslev(iarray,P,pgrid)
% MODELEV2PRESSLEV converts model levels to pressure levels using linear interpolation
%
% IN
%     iarrray  [%f,...]            input matrix 2D or greater
%     P        [%f,...]            pressure values on model level. Must be same
%                                  size as iarray. [Pa]
%     pgrid                        vector containing new presure vertical
%                                  coordintate. Should be within the model's 
%                                  own domain [Pa]
%     nlev                         scalar number of model levels
%
% OUT
%     out = data                   Interpolated data to the new pressure grid
%
% NOTE
%     * Assumes input dimensions data(lev,....) 
%
% USAGE: out = modlev2presslev(data,P,pgrid)
%
% $Id$ 
% Created Marston Johnston


assert(nargin == 3,'modlev2presslev:badInput',...
    'incorrect number of arguments')
assert(isequal(size(iarray),size(P)),'modlev2presslev:badInput',...
    '''iarray'' and ''P'' must be the same size')
assert(isvector(pgrid),'modlev2presslev:badInput',...
    'pgrid must be a vector')
assert(all(pgrid >= min(P(:)))&&all(pgrid <= max(P(:))),'modlev2presslev:badInput',...
    'pgrid is out side the domain if the pressure matrix')
nlev = size(P,1);
assert(isequal(size(iarray,1),nlev),'modlev2presslev:dimError',...
    'Dimension 1 must equal nlev!');

% Get the size of the input array
sz = size(iarray);
% Change the pressure level dimension to the new grid. 
sz(1) = length(pgrid);
% compress the array to 2D
iarray = iarray(:,:); 
P = P(:,:);
pAr = NaN(sz);
pAr = pAr(:,:);
for a = 1:size(iarray,2)
    ivalues = iarray(:,a);
    igrid   = P(:,a);
    ovalues = interp1(log10(igrid),ivalues,log10(pgrid));
    pAr(:,a) = ovalues;
end
data = reshape(pAr,sz);
