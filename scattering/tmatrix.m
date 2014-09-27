% TMATRIX   T-matrix scattering data, following ARTS
%
%    Basically a direct interface to ARTS' WSM *scat_dataFromTmatrix*.
%    For detailed information, such as options for *pshape* see: 
%       arts -d scat_dataFromTmatrix
%
%    The argument *N* is most easily set following thos pattern:
%      N = complex_refr_indexFromFunc(fg,tg,@eps_ice_liebe93,@sqrt);
%
% FORMAT   D = tmatrix( workfolder,f_grid,t_grid,za_grid,aa_grid,N, ...
%                       pshape,ptype,pdiameter,aspect_ratio)
%        
% OUT   D            ARTS single scattering data
% IN    workfolder   A folder where temporary files can be stored.
%                    If set to [], a temporary folder is created.
%                    Note that an existing cfile.arts will be overwritten.
%       f_grid       Frequency grid.
%       t_grid       Temperature grid.
%       za_grid      Zenith angle grid.
%       aa_grid      Azimuth angle grid.
%       N            Data of complex refractive index.
%       pshape       Particle shape. 
%       ptype        Particle type. 
%       pdiameter    Particle diameter.
%       aspect_ratio Particle aspect ratio.
% OPT   Precision    The T-matrx calculation precision.

% 2014-09-27   Created by Patrick Eriksson.

function D = tmatrix( workfolder,f_grid,t_grid,za_grid,aa_grid,N, ...
                          pshape,ptype,pdiameter,aspect_ratio,varargin)
%
[precision] = optargs( varargin, { 0.001 } );
  
  
%- Basic checks of input
%
rqre_datatype( f_grid, @istensor1 );
rqre_datatype( t_grid, @istensor1 );
rqre_datatype( za_grid, @istensor1 );
rqre_datatype( aa_grid, @istensor1 );
rqre_datatype( N, @isstruct );
rqre_datatype( pshape, @ischar );
rqre_datatype( ptype, @ischar );
rqre_datatype( pdiameter, @istensor1 );
rqre_datatype( aspect_ratio, @istensor1 );


%- Create workfolder
%
if isempty( workfolder )
  workfolder = create_tmpfolder;
  cu = onCleanup( @()delete_tmpfolder( workfolder ) );
end


%- Start defining cfile
S{1} = '# Code defined in Atmlab''s tmatrix.m';


%- Store grids
%
filename = fullfile( workfolder, 'scat_f_grid.xml' ); 
xmlStore( filename, f_grid, 'Vector' );
S{end+1} = 'VectorCreate(scat_f_grid)';
S{end+1} = sprintf( 'ReadXML(scat_f_grid,"%s")', filename );
%
filename = fullfile( workfolder, 'scat_t_grid.xml' ); 
xmlStore( filename, t_grid, 'Vector' );
S{end+1} = 'VectorCreate(scat_t_grid)';
S{end+1} = sprintf( 'ReadXML(scat_t_grid,"%s")', filename );
%
filename = fullfile( workfolder, 'scat_za_grid.xml' ); 
xmlStore( filename, za_grid, 'Vector' );
S{end+1} = sprintf( 'ReadXML(scat_za_grid,"%s")', filename );
%
filename = fullfile( workfolder, 'scat_aa_grid.xml' ); 
xmlStore( filename, aa_grid, 'Vector' );
S{end+1} = sprintf( 'ReadXML(scat_aa_grid,"%s")', filename );


%- Store complex_refr_index
filename = fullfile( workfolder, 'complex_refr_index.xml' ); 
xmlStore( filename, N, 'GriddedField3' );
S{end+1} = sprintf( 'ReadXML(complex_refr_index,"%s")', filename );


%- Add T-matrix call and saving
%
S{end+1} = 'scat_dataFromTmatrix(';
S{end+1} = sprintf('  shape = "%s",', pshape );
S{end+1} = sprintf('  de = %.6e,', pdiameter );
S{end+1} = sprintf('  aratio = %.6f,', aspect_ratio );
S{end+1} = sprintf('  orientation = "%s",', ptype );
S{end+1} = '  scat_f_grid    = scat_f_grid,';
S{end+1} = '  scat_t_grid    = scat_t_grid,';
S{end+1} = '  scat_za_grid   = scat_za_grid,';
S{end+1} = '  scat_aa_grid   = scat_aa_grid,';
S{end+1} = sprintf('  precision = %.6e', precision );
S{end+1} = ')';
S{end+1} = 'WriteXML( "ascii", scat_data )';


%- Run arts
arts_cfiletext( S, workfolder );

%- Load result
D = xmlLoad( fullfile( workfolder, 'cfile.scat_data.xml' ) );

