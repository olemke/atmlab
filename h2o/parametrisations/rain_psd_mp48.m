% RAIN_PSD_MP98   Size distribution for rain according to Marshall&Palmer 1948
%    
%     This is an interface to the ARTS WSM dNdD_MP98. See that WSM for 
%     further information. 
%
% FORMAT   n = ice_psd_h11(de_grid,rain_rate)
%
% OUT      n          Normalised particle size distribution [#/m^3/m].
% IN       de_grid    The grid of *n*, a number of De values [m].
%          rain_rate  Rain rate [kg/s/m2]

% 2015-06-11  Patrick Eriksson 

function n = rain_psd_mp48(de_grid,rain_rate)


% Create workfolder
%
workfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( workfolder ) );


% Set up cfile
S{1}     = 'VectorCreate(dNdD)';
%
filename = fullfile( workfolder, 'De.xml' ); 
xmlStore( filename, de_grid, 'Vector' );
S{end+1} = 'VectorCreate(De)';
S{end+1} = sprintf( 'ReadXML(De,"%s")', filename );
%
S{end+1} = sprintf('dNdD_MP48(dNdD,De,%.3e)', rain_rate );
S{end+1} = 'WriteXML( "ascii", dNdD )';

% Run arts
arts_cfiletext( S, workfolder );

% Load result
n = xmlLoad( fullfile( workfolder, 'cfile.dNdD.xml' ) );
