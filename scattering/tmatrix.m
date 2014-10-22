% TMATRIX   T-matrix scattering data, following ARTS
%
%    Basically a direct interface to ARTS' WSM *scat_dataFromTmatrix*.
%    For detailed information, such as options for *shape* see: 
%       arts -d scat_data_singleTmatrix
%
%    The argument *N* is most easily set following this pattern:
%      N = complex_refr_indexFromFunc(fg,tg,@eps_ice_liebe93,@sqrt);
%
%    Note that size (*diameter*) can be given in two ways, as the
%    equivalent volume diameter (default or d_is_max=false), or as the
%    maximum dimension (requires that d_is_max=true).
%
%    The default is to load the calculated data into Matlab. If *outfile*
%    is not empty, that single scattering and meta data will to stored as
%    outfile.xml and outfile.meta.xml, respectively, and SC and M will be 
%    set to those filenames.
%
% FORMAT   [S,M,dveq] = tmatrix(workfolder,f_grid,t_grid,za_grid,aa_grid,N, ...
%                               shape,ptype,diameter,axial_ratio
%                               [,d_is_max,precision,mass,cri_source] )
%        
% OUT   S            ARTS single scattering data, either as imported data or
%                    set to a path (then equal to *outfile*).
%       M            Associated meta data. 
%       dveq         Equivalent volume diameter. If *d_is_max* is false, *dveq*
%                    equals *diameter*, otherwise it is the equivalent
%                    diameter calculated by ARTS.
% IN    workfolder   A folder where temporary files can be stored.
%                    If set to [], a temporary folder is created.
%                    Note that e.g. an existing cfile.arts will be overwritten.
%       f_grid       Frequency grid.
%       t_grid       Temperature grid.
%       za_grid      Zenith angle grid.
%       aa_grid      Azimuth angle grid.
%       N            Data of complex refractive index.
%       shape        Particle shape. 
%       ptype        Particle type. 
%       diameter     Particle diameter.
%       axial_ratio  Particle axial ratio.
% OPT   d_is_max     Default is that *diameter* is equivalent volume diameter
%                    (Dveq). Set this flag to true if *diameter* is instead
%                    the maximum dimension (Dmax).
%       outfile      Name of files if data shall be kept as files. The xml
%                    extension shall not be included. Default is [], that 
%                    flags that data shall be imported into Matlab.
%       precision    The T-matrix calculation precision. Deafult is 0.001.
%       mass         Particle mass. Only used to set meta data. Default is NaN.
%       cri_source   Source to complex refractive index. A string. Default
%                    is to use the default string in arts.

% 2014-09-27   Created by Patrick Eriksson.

function [S,M,dveq] = tmatrix(workfolder,f_grid,t_grid,za_grid,aa_grid,N, ...
                              shape,ptype,diameter,axial_ratio,varargin)
%
[d_is_max,outfile,precision,mass,cri_source] = ...
                          optargs( varargin, { false, [], 0.001, NaN, [] } );
  
  
%- Basic checks of input
%
rqre_datatype( f_grid, @istensor1 );
rqre_datatype( t_grid, @istensor1 );
rqre_datatype( za_grid, @istensor1 );
rqre_datatype( aa_grid, @istensor1 );
rqre_datatype( N, @isstruct );
rqre_datatype( shape, @ischar );
rqre_datatype( ptype, @ischar );
rqre_datatype( diameter, @istensor0 );
rqre_datatype( axial_ratio, @istensor0 );


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
filename = fullfile( workfolder, 'data_f_grid.xml' ); 
xmlStore( filename, f_grid, 'Vector' );
S{end+1} = 'VectorCreate(data_f_grid)';
S{end+1} = sprintf( 'ReadXML(data_f_grid,"%s")', filename );
%
filename = fullfile( workfolder, 'data_t_grid.xml' ); 
xmlStore( filename, t_grid, 'Vector' );
S{end+1} = 'VectorCreate(data_t_grid)';
S{end+1} = sprintf( 'ReadXML(data_t_grid,"%s")', filename );
%
filename = fullfile( workfolder, 'data_za_grid.xml' ); 
xmlStore( filename, za_grid, 'Vector' );
S{end+1} = 'VectorCreate(data_za_grid)';
S{end+1} = sprintf( 'ReadXML(data_za_grid,"%s")', filename );
%
filename = fullfile( workfolder, 'data_aa_grid.xml' ); 
xmlStore( filename, aa_grid, 'Vector' );
S{end+1} = 'VectorCreate(data_aa_grid)';
S{end+1} = sprintf( 'ReadXML(data_aa_grid,"%s")', filename );


%- Store complex_refr_index
filename = fullfile( workfolder, 'complex_refr_index.xml' ); 
xmlStore( filename, N, 'GriddedField3' );
S{end+1} = sprintf( 'ReadXML(complex_refr_index,"%s")', filename );


%- De/Dmax
S{end+1} = 'NumericCreate(dveq)';
%
if d_is_max
  S{end+1} = 'NumericCreate(dmax)';
  S{end+1} = 'NumericCreate(volume)';
  S{end+1} = sprintf( 'NumericSet(dmax,%.6e)', diameter );
  S{end+1} = sprintf( ...
      'diameter_volume_equFromDiameter_max(dveq,volume,"%s",dmax,%.6f)', ...
                                                          shape, axial_ratio );
  S{end+1} = 'WriteXML( "ascii", dveq )';
else
  S{end+1} = sprintf( 'NumericSet(dveq,%.6e)', diameter );
end


%- Add T-matrix call and saving
%
S{end+1} = 'scat_data_singleTmatrix(';
S{end+1} = sprintf('  shape               = "%s",', shape );
S{end+1} = '  diameter_volume_equ = dveq,';
S{end+1} = sprintf('  axial_ratio         = %.6f,', axial_ratio );
S{end+1} = sprintf('  ptype        = "%s",', ptype );
S{end+1} = '  data_f_grid  = data_f_grid,';
S{end+1} = '  data_t_grid  = data_t_grid,';
S{end+1} = '  data_za_grid = data_za_grid,';
S{end+1} = '  data_aa_grid = data_aa_grid,';
if ~isnan(mass)
  S{end+1} = sprintf('  mass         = %.6e,', mass );
end
if ~isempty(cri_source)
  S{end+1} = sprintf('  cri_source   = "%s",', cri_source );
end
S{end+1} = sprintf('  precision    = %.6e', precision );
S{end+1} = ')';
if isempty(outfile)
  S{end+1} = 'WriteXML( "ascii", scat_data_single )';
  S{end+1} = 'WriteXML( "ascii", scat_meta_single )';
else
  ssdfile  = [ outfile, '.xml' ];
  metafile = [ outfile, '.meta.xml' ];
  S{end+1} = sprintf( 'WriteXML( "ascii", scat_data_single, "%s" )', ssdfile );
  S{end+1} = sprintf( 'WriteXML( "ascii", scat_meta_single, "%s" )', metafile );
end

%- Run arts
arts_cfiletext( S, workfolder );


%- Load result
if isempty( outfile )
  S = xmlLoad( fullfile( workfolder, 'cfile.scat_data_single.xml' ) );
  M = xmlLoad( fullfile( workfolder, 'cfile.scat_meta_single.xml' ) );
else
  S = ssdfile;
  M = metafile;
end


%- De
if nargout > 2
  if d_is_max
    dveq = xmlLoad( fullfile( workfolder, 'cfile.dveq.xml' ) );
  else
    dveq = diameter;
  end
end  
