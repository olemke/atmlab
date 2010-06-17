function sensor = amsub_or_mhs(sat)

% amsub_or_mhs Which sensor is on this satellite?
%
% For a POES satellite, returns what sensor (amsub or mhs) is on this
% satellite.
%
% Needs appropiate settings to be set in colloc_config (are set by
% default). TODO: should this really be in colloc_config or is it better
% somewhere else?
%
% FORMAT
%
%   sensor = amsub_or_mhs(sat)
%
% IN
%
%   sat     string      satellite name
%
% OUT
%
%   sensor  string      sensor name
%
% $Id$

switch sat
    case colloc_config('POES_satellites_amsub')
        sensor = 'amsub';
    case colloc_config('POES_satellites_mhs')
        sensor = 'mhs';
    otherwise
        error('atmlab:amsub_or_mhs', 'I don''t know what sensor is on %s', sat);
end
