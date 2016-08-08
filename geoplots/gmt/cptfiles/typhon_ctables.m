% TYPHON_CTABLES   Returns path to typhon color palette table.
%
%    This function returns the full path to a cptfile defining a color palette.
%    Currently all colormaps distributed with the typhon package [1] are
%    available.
%
%    The original colormaps were developed by Kristen M. Thyng of Texas A&M
%    University's Department of Oceanography for commonly-used oceanographic
%    variables. [2]
%
%    The return argument can be used with atmlab's GMT wrapper as
%       in.ctable = typhon_ctables('density')
%
%   [1] http://radiativetransfer.org/misc/typhon/doc/cm.html
%   [2] http://matplotlib.org/cmocean/
%
% FORMAT   cmap = typhon_ctables(name)
%
% OUT   cptfile    Path to cpt file.
% IN    name       Colormap name.
%                  Valid names are:
%                      density
%                      phase
%                      speed
%                      temperature
%                      velocity
%                      vorticity

% 2016-08-08   Lukas Kluft: Created.

function cptfile = typhon_ctables(name)
    data_file = [name '.cpt'];

    if ~exist(data_file, 'file')
        error(['atmlab:' mfilename ':invalid ', ...
            'Invalid color palette name: "%s". See help.'], name);
    end

    cptfile = fullfile(fileparts(mfilename('fullpath')), data_file);

end
