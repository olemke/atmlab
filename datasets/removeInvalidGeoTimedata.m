function S = removeInvalidGeoTimedata(S)
%% remove INVALID geodata and time
% Purpose: To remove invalid data that can't be used by the collocation
% codes anyway. 
%
% NOTE: This is an interal function to many of the common_read_<dataset>.m
%       This means that the input data is assumed to follow the
%       conventions set up in the collocatio toolbox (fields must be called
%       'lat','lon','time'), i.e. -180<=lon<=180,  -90<=lat<=90,
%       0<=time<=24*3600
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
%
% $Id$
% Salomon Eliasson

ltindex = S.lat >= -90 & S.lat <= 90;
lnindex = S.lon >= -180 & S.lon <= 180;
%tindex = S.time >= 0 & S.time <= 3600*24;
if any(~(ltindex & lnindex))% & tindex))
    logtext(atmlab('OUT'),'Removing invalid lat, lon data\n')
    for F = fieldnames(S)'
        if isequal(size(S.(F{1}),1),size(ltindex,1))
            S.(F{1}) = S.(F{1})(ltindex & lnindex & tindex,:);
        end
    end
end

end