function Q = qarts_add_mars_planettbox( A, Q, workfolder )
%
rqre_datatype( A, { @isstruct } );
rqre_datatype( Q, { @isstruct, @ischar } );
rqre_datatype( workfolder, { @ischar,@isempty } );


arts_xmldata_path       = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to set ARTS_XMLDATA_PATH to use this function.');
end


% Create the variables used by getatmo_mars.arts
%
Q.WSMS_AT_START{end+1} = 'IndexCreate( Ls )';
Q.WSMS_AT_START{end+1} = 'IndexCreate( daytime )';
Q.WSMS_AT_START{end+1} = 'IndexCreate( dust )';
Q.WSMS_AT_START{end+1} = 'IndexCreate( solar )';
Q.WSMS_AT_START{end+1} = 'ArrayOfIndexCreate( basespecies )';
Q.WSMS_AT_START{end+1} = 'ArrayOfIndexCreate( h2ospecies )';
Q.WSMS_AT_START{end+1} = 'ArrayOfIndexCreate( ch4species )';
Q.WSMS_AT_START{end+1} = 'ArrayOfIndexCreate( Necase )';
Q.WSMS_AT_START{end+1} = 'ArrayOfIndexCreate( vertwind )';
Q.WSMS_AT_START{end+1} = 'ArrayOfIndexCreate( NSwind )';
Q.WSMS_AT_START{end+1} = 'ArrayOfIndexCreate( EWwind )';
Q.WSMS_AT_START{end+1} = 'IndexCreate( zeropad )';
Q.WSMS_AT_START{end+1} = 'IndexCreate( vmr_zeropad )';
Q.WSMS_AT_START{end+1} = 'IndexCreate( interp_order )';


% Set the variables above
%
Q.WSMS_AT_START{end+1} = sprintf( 'IndexSet( Ls, %d )',      A.Ls      );
Q.WSMS_AT_START{end+1} = sprintf( 'IndexSet( daytime, %d )', A.daytime );
Q.WSMS_AT_START{end+1} = sprintf( 'IndexSet( dust, %d )',    A.dust    );
Q.WSMS_AT_START{end+1} = sprintf( 'IndexSet( solar, %d )',   A.solar   );
%
Q.WSMS_AT_START{end+1} = sprintf( 'ArrayOfIndexSet( basespecies, [%s] )', ...
                                vector2commalist( A.basespecies ) );
Q.WSMS_AT_START{end+1} = sprintf( 'ArrayOfIndexSet( ch4species, [%s] )', ...
                                vector2commalist( A.h2ospecies ) );
Q.WSMS_AT_START{end+1} = sprintf( 'ArrayOfIndexSet( ch4species, [%s] )', ...
                                vector2commalist( A.h2ospecies ) );
Q.WSMS_AT_START{end+1} = sprintf( 'ArrayOfIndexSet( Necase, [%s] )', ...
                                vector2commalist( A.Necase ) );


Q.WSMS_BEFORE_RTE{end+1} = ...
               'INCLUDE "planetary_toolbox/includes/mars/getatmo_mars.arts"';
Q.WSMS_BEFORE_RTE{end+1} = ...
               'INCLUDE "planetary_toolbox/includes/common/makeatmo1D.arts"';



% Check limits and number of points needed:
Q.P_GRID = logspace( log10(7e2), log10(7e-7), 100 )';

Q.HSE.ON = false;




