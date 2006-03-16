function L = alter_linedata( L, pert, species, freq, param )
% Alter ARTSCAT linedata
%
% Output
%   L       - Structure array with line data.
% Input
%   L       - Structure array with line data.
%   pert    - Perturbation, e.g. 1.1 for 10% increase
%   species - Species tag, e.g. 'H2O-161', 'H2O'
%   freq    - Line frequency
%   param   - Parameter to perturb, e.g. 'i0'
%
% NOTE: This function needs read_linefile from AMI.
% 
% 2005-09-23  M Ekstrom

% Load line data if given as string
if ischar(L)
  L = read_linefile( L );
end

% Convert cell to single matrix, for convenient search of index
l = cell2mat(L);
species_list = strvcat(l.name);
freq_list = cat(1,l.f);

sp_idx = strmatch(species,species_list);
[df, f_idx] = min(abs(freq_list(sp_idx)-freq));
idx = sp_idx(f_idx);

% Output found frequency
if atmlab('VERBOSITY')==2
  fprintf('Linedata perturbation:\n   Found frequency %g (difference %g)\n', ...
           freq_list(idx), df);
end

% Apply perturbation
ref = getfield(L{idx},param);
L{idx} = setfield(L{idx},param,ref*pert);

