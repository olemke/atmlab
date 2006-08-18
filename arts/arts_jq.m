% ARTS_JQ   Obtains auxiliary data for the Jacobian
%
%    Basically as *arts_y*, but exits before any RT calculations are started.
%
% FORMAT   [jq,ji] = arts_y( Q )
%        
% OUT   jq  Jacobian quantities. NaN returned if Q.JACOBIAN_DO=0.
%       ji  Jacobian indices. NaN returned if Q.JACOBIAN_DO=0.
%           Indices are 1-based (that is, ARTS indices + 1);
% IN    Q   Qarts structure.

% 2006-08-18   Created by Patrick Eriksson.


function [jq,ji] = arts_jq( Q )

tmpfolder   = create_tmpfolder;

parts = qarts2cfile( 'jq' );

S = qarts2cfile( Q, parts, tmpfolder );

cfile = fullfile( tmpfolder, 'cfile.arts' );

qtool( S, cfile, [] );


arts( cfile );

jq = xmlLoad( fullfile( tmpfolder, 'jacobian_quantities.xml' ) );
ji = xmlLoad( fullfile( tmpfolder, 'jacobian_indices.xml' ) );

%- Fix different indexing
%
for i = 1 : length(ji)
  for j = 1 : length(ji{i})
    ji{i}{j} = ji{i}{j} + 1;
  end
end

delete_tmpfolder( tmpfolder );
