% ARTS_CFILE   Builds a control file for ARTS
%
%    Creates a control file matching the settings in a Qarts structure.
%    The control file is provided as cell array of strings. This means
%    that the output can be combined with other control file pieces
%    by combining their string arrays. The final control file is
%    created by *qtool*.
%    
%    The control file structure is determined by putting different 'parts'
%    together, following the format: parts = {'tgs','load_atm','save_atm'}
%
%    Defined parts are:
%       start
%       stokes
%
% FORMAT   S = arts_cfile( Q, parts, tmpdir )
%        
% OUT   S       String cell array that can be passed to qtool.
% IN    parts   Control file parts to include. See further above.
%       tmpdir  Temporary folder where calculations will be performed.

% 2004-09-08   Created by Patrick Eriksson.


function S = arts_cfile( Q, parts, tmpdir )


qcheck( @qarts, Q );

S = {};

for i = 1 : length(parts)

T = [];

switch parts{i}

case 'start'
  %
  T{1} = [ '# Control file created (at least partly) by Atmlab function ', ...
           'arts_cfile' ];
  T{2} = 'Main{';
  T{3} = 'output_file_formatSetAscii{}';

case 'stokes'
  %
  rqre_scalar( 'Qarts field STOKES_DIM', Q.STOKES_DIM, 1, 4 );
  T{1} = sprintf( 'IndexSet(stokes_dim){%d}', Q.STOKES_DIM );

case 'atmosphere'
  %
  T{1} = sprintf( 'gas_speciesSet{[%s]}', arts_tgs_cnvrt(Q.GAS_SPECIES) );
  rqre_scalar( 'Qarts field ATMOSPHERE_DIM', Q.ATMOSPHERE_DIM, 1, 3 );
  T{2} = sprintf( 'AtmosphereSet%dD{}', Q.ATMOSPHERE_DIM );
  T{3} = file_or_data( 'p_grid', 'Vector', Q.P_GRID, tmpdir );
  if Q.ATMOSPHERE_DIM >= 2
    T{4} = file_or_data( 'lat_grid', 'Vector', Q.LAT_GRID, tmpdir );
  else
    T{4} = ' ';
  end
  if Q.ATMOSPHERE_DIM == 3
    T{5} = file_or_data( 'lon_grid', 'Vector', Q.LON_GRID, tmpdir );
  else
    T{5} = ' ';
  end

case 'absorption'
  %
  T{1} = file_or_data( 'f_grid', 'Vector', Q.F_GRID, tmpdir );

case 'stop'
  %
  T{1} = '} # Main';
  T{2} = ' ';

otherwise
  error(sprintf('Unknown action (%s) was requested.',parts{i}));
end

S = [ S T ];

end


%------------------------------------------------------------------------------

function s = file_or_data( artsvar, datatype, qvalue, tmpfolder )
  if ischar( qvalue )
    s = add_readfile( artsvar, qvalue );
  else
    if isnan( qvalue )
       error( sprintf('NaN found for %s.',artsvar) );
    end
    filename = fullfile( tmpfolder, [artsvar,'.xml'] );
    xmlStore( filename, qvalue, datatype );
    s = add_readfile( artsvar, filename );
  end
return

function s = add_readfile( artsvar, filename )
  s = sprintf('ReadXML(%s){"%s"}', artsvar, filename );
return


function s = add_savefile( artsvar, tmpfolder )
  filename = fullfile( tmpfolder, [ artsvar, '.xml' ] ); 
  s = sprintf('WriteXML(%s){"%s"}', artsvar, filename );
return

