% ICE_PSD_MH97   The PSD of McFarquhar&Heymsfield 1997
%    
%     This is an interface to the ARTS WSM dNdD_MH97. See that WSM for 
%     further information. 
%
%     There exists also a pure atmlab version of the PSD: ice_psd_Mcfar_97
%
% FORMAT   n = ice_psd_mh97(dme_grid,iwc,t,varargin)  
%
% OUT      n          The particle size distribution [#/m^3/m].
% IN       dme_grid   The grid of *n*, a number of Dme values [m].
%          iwc        Ice water content [kg/m^3].
%          t          Temperature [K].
% OPT      noisy      Distribution parameter perturbance flag. Default is 0.

% 2014-09-23   Patrick Eriksson 

function n = ice_psd_mh97(dme_grid,iwc,t,varargin)
%
[noisy] = optargs( varargin, { false } );

% ARTS version requires t < 273.15. We add some margin
%
if t > 280
  error( 'Temperatures above 280 K are not allowed.' );
elseif t > 273.15
  t = 273.15;
end


% Create workfolder
%
workfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( workfolder ) );


% Set up cfile
S{1}     = 'VectorCreate(dNdD)';
%
filename = fullfile( workfolder, 'Dme.xml' ); 
xmlStore( filename, dme_grid, 'Vector' );
S{end+1} = 'VectorCreate(Dme)';
S{end+1} = sprintf( 'ReadXML(Dme,"%s")', filename );
%
S{end+1} = sprintf('dNdD_MH97(dNdD,Dme,%.6e,%.3f,%d)', iwc, t, noisy );
S{end+1} = 'WriteXML( "ascii", dNdD )';

% Run arts
arts_cfiletext( S, workfolder );

% Load result
n = xmlLoad( fullfile( workfolder, 'cfile.dNdD.xml' ) );
