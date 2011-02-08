% GF2GRIDDEDFIELD   CONVERTS A GFORMAT STRUCTURE INTO A GRIDDED FIELD
%
%    Converts data having the G format into data having the arts xml 
%    GriddedField.
%
% FORMAT   GF = gf2griddedfield( G )
%        
% OUT   GF      GriddedField
% IN    file    GFormat struckt

% 2011-02-08   Created by Ole Martin Christensen.

function GF = gf2griddedfield(G)
                                                                   %&%
rqre_nargin( 1, nargin );                                          %&%
%                                                                  %&%
if ~isgformat(G)
  error('Input data must be a GFormat struckture');
end

GF.name  = G.NAME;
GF.data  = G.DATA;
GF.dataname = G.DATA_NAME;
for i = 1:G.DIM
    n= num2str(i);
    GF.grids{i} = eval(['G.GRID' n]);
    GF.gridnames{i} = eval(['G.GRID' n '_NAME']);
end

return