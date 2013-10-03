% QARTS_ADD_MARS_PLANETTBOX   Includes planet toolbox study data for Mars
%
%  Work in progress !!!  So far, see getatmo_mars.arts for definition of
%  control variables.
%
%   Winds are not yet treated.
%
%  Mandatory fields are
%    A.Ls
%    A.daytime
%    A.dust
%    A.solar
%    A.interp_order
%    A.zeropad
%    A.vmr_zeropad
%    A.basespecies
%    A.ch4species
%    A.h2ospecies
%    A.Necase
%
% FORMAT Q = qarts_add_mars_planettbox( A, Q, workfolder )
%
% OUT   Q          Modified Q
% IN    A          Atmosphere structure, see above.
%       Q          Original Q
%       workfolder Path to workfolder (not used, but an input is demanded)

% 2013-10-03   Created by Patrick Eriksson.

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
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( Ls )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( daytime )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( dust )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( solar )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( basespecies )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( h2ospecies )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( ch4species )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( Necase )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( vertwind )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( NSwind )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'ArrayOfIndexCreate( EWwind )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( zeropad )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( vmr_zeropad )';
Q.WSMS_BEFORE_ATMSURF{end+1} = 'IndexCreate( interp_order )';


% Set the variables above
%
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( Ls, %d )',      A.Ls      );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( daytime, %d )', A.daytime );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( dust, %d )',    A.dust    );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( solar, %d )',   A.solar   );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( interp_order, %d )',  ...
                                                              A.interp_order );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( zeropad, %d )', A.zeropad );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( 'IndexSet( vmr_zeropad, %d )', ...
                                                               A.vmr_zeropad );
%
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
   'ArrayOfIndexSet( basespecies, [%s] )', vector2commalist( A.basespecies ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
     'ArrayOfIndexSet( ch4species, [%s] )', vector2commalist( A.ch4species ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
     'ArrayOfIndexSet( h2ospecies, [%s] )', vector2commalist( A.h2ospecies ) );
Q.WSMS_BEFORE_ATMSURF{end+1} = sprintf( ...
             'ArrayOfIndexSet( Necase, [%s] )', vector2commalist( A.Necase ) );


Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                    'INCLUDE "planetary_toolbox/includes/mars/atmo_mars.arts"';
Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                 'INCLUDE "planetary_toolbox/includes/common/createvars.arts"';
Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                 'INCLUDE "planetary_toolbox/includes/mars/getatmo_mars.arts"';


if Q.ATMOSPHERE_DIM == 1
  Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                 'INCLUDE "planetary_toolbox/includes/common/makeatmo1D.arts"';
elseif Q.ATMOSPHERE_DIM == 3
  Q.WSMS_BEFORE_ATMSURF{end+1} = ...
                 'INCLUDE "planetary_toolbox/includes/common/makeatmo3D.arts"';
else
  error( 'Only 1D and 3D atmosphere can be generated.' );
end






