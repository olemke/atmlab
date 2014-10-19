% TMATRIX   T-matrix scattering data, following ARTS
%
%    Basically a direct interface to ARTS' WSM *scat_dataFromTmatrix*.
%    For detailed information, such as options for *pshape* see: 
%       arts -d scat_dataFromTmatrix
%
%    The argument *N* is most easily set following this pattern:
%      N = complex_refr_indexFromFunc(fg,tg,@eps_ice_liebe93,@sqrt);
%
%    Note that size (*pdiameter*) can be given in two ways, as the
%    equivalent volume diameter (default or d_is_max=false), or as the
%    maximum dimension (requires that d_is_max=true).
%
%    The default is to load the calculated data into Matlab. If *outfile*
%    is not empty, that data will to stored into that file and *SC* is set to
%    be equal to *outfile*.
%
% FORMAT   [SC,de] = tmatrix( workfolder,f_grid,t_grid,za_grid,aa_grid,N, ...
%                             pshape,ptype,pdiameter,aspect_ratio
%                             [,d_is_max,precision] )
%        
% OUT   SC           ARTS single scattering data, either as imported data or
%                    set to a path (then equal to *outfile*).
%       de           Equivalent diameter. If *d_is_max* is false, *de*
%                    equals *pdiameter*, otherwise it is the equivalent
%                    diameter calculated by ARTS.
% IN    workfolder   A folder where temporary files can be stored.
%                    If set to [], a temporary folder is created.
%                    Note that e.g. an existing cfile.arts will be overwritten.
%       f_grid       Frequency grid.
%       t_grid       Temperature grid.
%       za_grid      Zenith angle grid.
%       aa_grid      Azimuth angle grid.
%       N            Data of complex refractive index.
%       pshape       Particle shape. 
%       ptype        Particle type. 
%       aspect_ratio Particle aspect ratio.
%       pdiameter    Particle diameter.
% OPT   d_is_max     Default is that *pdiameter* is equivalent volume diameter
%                    (De). Set this flag to true if *pdiameter* is instead
%                    the maximum dimension (Dmax).
%       outfile      Name of file if data shall be kept as a file. Default 
%                    is [], that flags that data shall be imported into Matlab.
%       precision    The T-matrix calculation precision.

% 2014-09-27   Created by Patrick Eriksson.

function [SC,de] = tmatrix(workfolder,f_grid,t_grid,za_grid,aa_grid,N, ...
                           pshape,ptype,pdiameter,aspect_ratio,varargin)
%
[d_is_max,outfile,precision] = optargs( varargin, { false, [], 0.001 } );
  
  
%- Basic checks of input
%
rqre_datatype( f_grid, @istensor1 );
rqre_datatype( t_grid, @istensor1 );
rqre_datatype( za_grid, @istensor1 );
rqre_datatype( aa_grid, @istensor1 );
rqre_datatype( N, @isstruct );
rqre_datatype( pshape, @ischar );
rqre_datatype( ptype, @ischar );
rqre_datatype( pdiameter, @istensor0 );
rqre_datatype( aspect_ratio, @istensor0 );


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


%- De/Dmax
S{end+1} = 'NumericCreate(de)';
%
if d_is_max
  S{end+1} = 'NumericCreate(dmax)';
  S{end+1} = 'NumericCreate(volume)';
  S{end+1} = sprintf( 'NumericSet(dmax,%.6e)', pdiameter );
  S{end+1} = sprintf( 'ParticleDeFromDmax(de,volume,"%s",dmax,%.6f)', ...
                                                         pshape, aspect_ratio );
  S{end+1} = 'WriteXML( "ascii", de )';
else
  S{end+1} = sprintf( 'NumericSet(de,%.6e)', pdiameter );
end


%- Add T-matrix call and saving
%
S{end+1} = 'scat_data_singleTmatrix(';
S{end+1} = sprintf('  shape        = "%s",', pshape );
S{end+1} = '  de           = de,';
S{end+1} = sprintf('  aratio       = %.6f,', aspect_ratio );
S{end+1} = sprintf('  ptype        = "%s",', ptype );
S{end+1} = '  scat_f_grid  = scat_f_grid,';
S{end+1} = '  scat_t_grid  = scat_t_grid,';
S{end+1} = '  scat_za_grid = scat_za_grid,';
S{end+1} = '  scat_aa_grid = scat_aa_grid,';
S{end+1} = sprintf('  precision    = %.6e', precision );
S{end+1} = ')';
if isempty(outfile)
  S{end+1} = 'WriteXML( "ascii", scat_data_single )';
else
  S{end+1} = sprintf( 'WriteXML( "ascii", scat_data_single, "%s" )', outfile );
end

%- Run arts
arts_cfiletext( S, workfolder );


%- Load result
if isempty(outfile)
  SC = xmlLoad( fullfile( workfolder, 'cfile.scat_data_single.xml' ) );
else
  SC = outfile;
end


%- De
if nargout
  if d_is_max
    de = xmlLoad( fullfile( workfolder, 'cfile.de.xml' ) );
  else
    de = pdiameter;
  end
end  
