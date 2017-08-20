% SMRL2_FREQUENCY   Absolute frequency of L2 data
%
%   The function returns absolute frequencies for the selected set of spectra.
%
% FORMAT   [F,i0] = smrl2_frequency( L1B, L2I [, itan] )
%
% OUT  F       Frequencies, one column per spectrum.
%      ich1    Index in L1B of channels present in L2I.
%      itan1   Index in L1B of tangent altitudes present in L2I.
% IN   L1B     L1B data. This can be original L1B data, and can hold more
%              spectra and frequencies than used in the retrieval.
%      L2I     Instrument L2 data structure
% OPT  itan    Returns frequency for these tangent altitude index. These index
%              refers to the L2I data. Default is to include all.

% 2015-12-16   Patrick Eriksson

function [F,ich1,itan1] = smrl2_frequency( L1B, L2I, itan )
%
if nargin < 3
  itan = 1 : length(L2I.LOFreq);
end
  
nf = length( L2I.ChannelsID );
nt = length( itan);

F = zeros( nt, nf );

% Find original index of kept channels
[~,ich1] = intersect( L1B(1).Frequency.ChannelsID, L2I.ChannelsID );
ich1     = sort(ich1);

for i = 1 : nt
  F(i,:) = L2I.LOFreq(itan(i)) + L1B.Frequency.IFreqGrid(ich1);
end


if nargout > 2
  [~,itan1] = intersect( L1B.STW, L2I.STW );
end