% ICE_PSD_H11   Unpublished PSD of Heymsfield 2011
%    
%     This is an interface to the ARTS WSM dNdD_H11. See that WSM for 
%     further information. 
%
% FORMAT   n = ice_psd_h11(dmax_grid,t)
%
% OUT      n          Unnormalised particle size distribution [#/m^3/m].
%                     That is, you need to scale it to match your IWC.
% IN       dmax_grid  The grid of *n*, a number of Dmax values [m].
%          t          Temperature [K].

% 2014-09-24   Patrick Eriksson 

function n = ice_psd_h11(dmax_grid,t)


% Create workfolder
%
workfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( workfolder ) );


% Set up cfile
S{1}     = 'VectorCreate(dNdD)';
%
filename = fullfile( workfolder, 'Dmax.xml' ); 
xmlStore( filename, dmax_grid, 'Vector' );
S{end+1} = 'VectorCreate(Dmax)';
S{end+1} = sprintf( 'ReadXML(Dmax,"%s")', filename );
%
S{end+1} = sprintf('dNdD_H11(dNdD,Dmax,%.3f)', t );
S{end+1} = 'WriteXML( "ascii", dNdD )';

% Run arts
arts_cfiletext( S, workfolder );

% Load result
n = xmlLoad( fullfile( workfolder, 'cfile.dNdD.xml' ) );
