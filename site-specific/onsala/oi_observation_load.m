% Loads a mat file with observation data
%
% FORMAT O = oi_observation_load(fname)
%
% OUT  O       Observation data structure
% IN   fname   File name

% 2021-02-06 Patrick Eriksson


function O = oi_observation_load(fname)

O = load( fname );