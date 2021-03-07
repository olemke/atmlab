% Loads one of the Fascode atmospheric scenarios
%
%   A has fields: p, z, t, n2, o2, h2o, o3, and co
%
% FORMAT A = oi_atm_fascode(scenario)
%
% OUT  A        Atmosphere data structure
% IN   scenario Scenario, 'tro', 'mls', 'mlw', 'sas' or 'saw'

% 2021-02-06 Patrick Eriksson


function A = oi_atm_fascode(scenario)

short = {'tro', 'mls', 'mlw', 'sas', 'saw' };
long  = {'tropical', ...
         'midlatitude-summer', ...
         'midlatitude-winter', ...
         'subarctic-summer', ...
         'subarctic-winter' };
    
i = find( strcmp( lower(scenario), short ) );

if isempty(i)
  error( 'Scenario %s not recognised', lower(scenario) );
end


folder = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'planets', 'Earth', ...
                   'Fascod', long{i} );

% Pressure and altitudes
%
F   = xmlLoad( fullfile( folder, [long{i},'.z.xml'] ) );
A.p = F.grids{1};
A.z = F.data;

% Temperature
%
F   = xmlLoad( fullfile( folder, [long{i},'.t.xml'] ) );
A.t = F.data;

% Gases
%
F    = xmlLoad( fullfile( folder, [long{i},'.N2.xml'] ) );
A.n2 = F.data;
%
F    = xmlLoad( fullfile( folder, [long{i},'.O2.xml'] ) );
A.o2 = F.data;
%
F     = xmlLoad( fullfile( folder, [long{i},'.H2O.xml'] ) );
A.h2o = F.data;
%
F     = xmlLoad( fullfile( folder, [long{i},'.O3.xml'] ) );
A.o3  = F.data;
%
F     = xmlLoad( fullfile( folder, [long{i},'.CO.xml'] ) );
A.co  = F.data;


%- Fixes

% H2O too low above tropopause. Simple fix
%
ind  = find( A.h2o < 8e-6 );
A.h2o(ind) = 1.25 * A.h2o(ind); 