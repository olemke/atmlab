% CLMTLGY_DEFINE   Define data structure for "climatology data"
%
%    The gformat is used for clmtlgy function set. The purpose of these
%    functions is to provide a general handling of climatology data.
%
%    Four data dimensions are defined
%       1 : Pressure
%       2 : Latitude
%       3 : Longitude
%       4 : Time. The time format is not locked and grid4 is left unspecified.
%           See *clmtlgy_interp* for accpeted time formats.
%
% FORMAT   D = clmtlgy_define
%        
% IN    D   Gformat definition structure.

% 2008-10-08   Created by Patrick Eriksson.

function D = clmtlgy_define

D.DIM        = 4;
  
D.GRID1_NAME = 'Pressure';
D.GRID1_UNIT = 'Pa';

D.GRID2_NAME = 'Latitude';
D.GRID2_UNIT = 'deg';

D.GRID3_NAME = 'Longitude';
D.GRID3_UNIT = 'deg';

D.GRID4_NAME = [];   
D.GRID4_UNIT = '';   

