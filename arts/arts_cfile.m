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
%       stop
%
%    Sorry, the Q fields needed for each part is not listed here.
%    See the code.
%
%    Output is stored in files placed in *tmpdir*, with names identical
%    the WSV name and extension '.xml' (e.g. y.xml).
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
  T{3} = 'SensorOff{}';

case 'stokes'
  %
  rqre_scalar( 'Qarts field STOKES_DIM', Q.STOKES_DIM, 1, 4 );
  %
  T{1} = sprintf( 'IndexSet(stokes_dim){%d}', Q.STOKES_DIM );

case 'load_atm'
  %
  rqre_scalar( 'Qarts field ATMOSPHERE_DIM', Q.ATMOSPHERE_DIM, 1, 3 );
  rqre_bool( 'Qarts field USE_RAW_ATMOSPHERE', Q.USE_RAW_ATMOSPHERE );
  %
  T{1} = sprintf( 'gas_speciesSet{[%s]}', arts_tgs_cnvrt(Q.GAS_SPECIES) );
  T{2} = sprintf( 'AtmosphereSet%dD{}', Q.ATMOSPHERE_DIM );
  T{3} = file_or_data( 'p_grid', 'Vector', Q.P_GRID, tmpdir );
  if Q.ATMOSPHERE_DIM >= 2
    T{4} = file_or_data( 'lat_grid', 'Vector', Q.LAT_GRID, tmpdir );
  else
    T{4} = '# No latitude grid loaded';
  end
  if Q.ATMOSPHERE_DIM == 3
    T{5} = file_or_data( 'lon_grid', 'Vector', Q.LON_GRID, tmpdir );
  else
    T{5} = '# No longitude grid loaded';
  end
  %
  if Q.USE_RAW_ATMOSPHERE
    rqre_char( 'Qarts field RAW_ATMOSPHERE', Q.RAW_ATMOSPHERE );
    T{6} = sprintf('AtmRawRead{"%s"}', Q.RAW_ATMOSPHERE );
    T{7} = 'AtmFieldsCalc{}';
  else
    T{6} = file_or_data( 't_field', 'Tensor3', Q.T_FIELD, tmpdir );
    T{7} = file_or_data( 'z_field', 'Tensor3', Q.Z_FIELD, tmpdir );
    T{8} = file_or_data( 'vmr_field', 'Tensor4', Q.VMR_FIELD, tmpdir );
  end

case 'save_atm'
  %
  T{1} = add_savefile( 't_field', tmpdir );
  T{2} = add_savefile( 'z_field', tmpdir );
  T{3} = add_savefile( 'vmr_field', tmpdir );

case 'load_abs'
  %
  T{1} = file_or_data( 'f_grid', 'Vector', Q.F_GRID, tmpdir );
  T{2} = file_or_data( 'gas_abs_lookup', 'GasAbsLookup', Q.GAS_ABS_LOOKUP, ...
                                                                      tmpdir );
  T{3} = 'gas_abs_lookupAdapt{}';

case 'calc_abs'
  T{1} = [ 'AgendaSet(scalar_gas_absorption_agenda)', ...
                                       '{abs_scalar_gasExtractFromLookup{}}' ];
  T{2} = 'AgendaSet(opt_prop_gas_agenda){';
  T{3} = '   ext_matInit{}';
  T{4} = '   abs_vecInit{}';
  nwsm = length( Q.OPT_PROP_GAS_AGENDA );
  for i = 1 : nwsm
    T{4+i} = sprintf( '   %s', Q.OPT_PROP_GAS_AGENDA{i} )
  end
  T{4+nwsm+1} = '}';

case 'rte'
  %


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

function s = file_or_data( artsvar, datatype, qvalue, tmpdir )
  if ischar( qvalue )
    s = add_readfile( artsvar, qvalue );
  else
    if ~isstruct( qvalue )  &  isnan( qvalue )
      fprintf('\nNaN found for %s.\n\n', artsvar );
      error('See above');
    end
    filename = fullfile( tmpdir, [artsvar,'.xml'] );
    xmlStore( filename, qvalue, datatype );
    s = add_readfile( artsvar, filename );
  end
return

function s = add_readfile( artsvar, filename )
  s = sprintf('ReadXML(%s){"%s"}', artsvar, filename );
return


function s = add_savefile( artsvar, tmpdir )
  filename = fullfile( tmpdir, [ artsvar, '.xml' ] ); 
  s = sprintf('WriteXML(%s){"%s"}', artsvar, filename );
return


