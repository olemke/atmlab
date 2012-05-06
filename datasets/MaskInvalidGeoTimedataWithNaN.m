function S = MaskInvalidGeoTimedataWithNaN(S)
% MaskInvalidGeoTimedataWithNaN Mask invalid geodata and time data with NaN
% Purpose: To remove invalid data that can't be used by the collocation
% codes anyway.
%
% NOTE: This is an interal function to many of the common_read_<dataset>.m
%       This means that the input data is assumed to follow the
%       conventions set up in the collocatio toolbox (fields must be called
%       'lat','lon','time'), i.e. -180<=lon<=180,  -90<=lat<=90,
%       0<=time.
%
% NOTE: If any data is removed the output data will be unavoidedly
% flattened along the geo dimension
%
%
% IN
%     S         struct                  output structure from
%                                       common_read_<datasets>
%
% OUT
%     S         struct                  Same structure, but filtered
%
% USAGE: S = removeInvalidGeoTimedata(S)

% $Id$
% Salomon Eliasson

ltindex = S.lat >= -90 & S.lat <= 90;
lnindex = S.lon >= -180 & S.lon <= 180;
tindex  = S.time >= 0;

index = ltindex & lnindex & tindex;

if any(~(index))
    logtext(atmlab('OUT'),...
        'Removing %d data values (%.2f%%) due to invalid (lat, lon, or time) \n',sum(~index),100*sum(~index)/length(index))
    for F = fieldnames(S)'
        if isequal(size(S.(F{1}),1),size(index,1))
            S.(F{1})(~index,:) = NaN;
        end
    end
    
end


end