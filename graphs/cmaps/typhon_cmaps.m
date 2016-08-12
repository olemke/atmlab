% TYPHON_CMAPS   Returns a typhon colormap.
%
%    This function returns a colormap from the set of typhon colormaps [1].
%
%    To reverse a colormap append '_r' to its name.
%
%    The return arguments of this function are used as
%       colormap(typhon_cmaps('density'))
%
%   [1] http://radiativetransfer.org/misc/typhon/doc/cm.html
%
% FORMAT   cmap = typhon_cmaps(name)
%
% OUT   cmap    Colormap.
% IN    name    Colormap name.
%               Valid names are:
%                   density
%                   phase
%                   qualitative1
%                   qualitative2
%                   seismic
%                   speed
%                   temperature
%                   velocity
%                   vorticity
% OPT   N       Number of color levels.

% 2016-07-14   Lukas Kluft: Created.

function cmap = typhon_cmaps(name, N)
    % If the colormap name ends with '_r' revert the colormap.
    revert = any(regexp(name,'_r$'));

    if revert
        data_file = [name(1:end-2) '.txt'];
    else
        data_file = [name '.txt'];
    end

    if exist(data_file, 'file')
        cmap = load(data_file);
    else
        error(['atmlab:' mfilename ':invalid ', ...
            'Invalid colormap name: "%s". See help.'], name);
    end

    if revert
        cmap = flipud(cmap);
    end

    if nargin > 1
        cmap = cmap(ceil(linspace(1, length(cmap), N)), :);
end
