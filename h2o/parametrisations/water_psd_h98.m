% WATER_PSD_H98   The PSD of Hess et al 1998
%    
%     This is an interface to the ARTS WSM dN_H98. See that WSM for 
%     further information. 
%
% FORMAT   n = water_psd_h98(d_grid,lwc)  
%
% OUT      n          The particle size distribution [#/m^3/m].
% IN       d_grid     The grid of *n*, a number of diameter values [m].
%          lwc        Liquid water content [kg/m^3].

% 2014-09-24   Patrick Eriksson 

function n = water_psd_h98(d_grid,lwc)


% Create workfolder
%
workfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( workfolder ) );


% Create vector with densities
density = repmat( constants('DENSITY_OF_WATER'), length(d_grid), 1 );

% Set up cfile
S{1}     = 'VectorCreate(dN)';
%
filename = fullfile( workfolder, 'R.xml' ); 
xmlStore( filename, d_grid/2, 'Vector' );
S{end+1} = 'VectorCreate(R)';
S{end+1} = sprintf( 'ReadXML(R,"%s")', filename );
%
filename = fullfile( workfolder, 'density.xml' ); 
xmlStore( filename, density, 'Vector' );
S{end+1} = 'VectorCreate(density)';
S{end+1} = sprintf( 'ReadXML(density,"%s")', filename );
%
S{end+1} = sprintf('dN_H98(dN,R,%.6e,density)', lwc );
S{end+1} = 'WriteXML( "ascii", dN )';

% Run arts
arts_cfiletext( S, workfolder );

% Load result
n = xmlLoad( fullfile( workfolder, 'cfile.dN.xml' ) );
