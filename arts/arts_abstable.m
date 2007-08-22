% ARTS_ABSTABLE_FROM_ARTS1   Creates an ARTS absorption lookup table
%
%    ARTS1 is used to generate the absorption lookup table. Spectrocopic
%    settings follows Qarts1. See needed fields below.
%
%    Gas species, grids and atmospheric state are specified following Qarts.
%    Needed fields are listed below. The frequency and pressure grid in the
%    absorption table will be Q.F_GRID and Q.P_GRID. If the atmospheric
%    dimension, the VMR reference state is taken as a mean over all latitude
%    and longitude profiles.
%
%    Needed Qarts fields:
%       ABS_SPECIES
%       P_GRID
%       F_GRID
%       ATMOSPHERE_DIM
%       USE_RAW_ATMOSPHERE 
%       atmospheric fields following value of USE_RAW_ATMOSPHERE  
%
%    Needed Qarts1 fields:
%       LINEFORMAT
%       LINEDATA  
%       LINESHAPE  
%       LINESHAPE_FACTOR 
%       LINESHAPE_CUTOFF 
%       ABSMODELS 
%
% FORMAT   A = arts_abstable_from_arts1( Q, Q1, dt [, workfolder ] )
%        
% OUT   A    Absorption table structure.
% IN    Q    ARTS settings.
% IN    Q1   ARTS1 settings.
%       dt   Vector with temperature perturbations. Default is 0.
% OPT   workfolder   If not defined or empty, a temporary folder is created.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored. These files
%                    will be left in the folder. The files are not read if
%                    corresponding output argument not is considered.
%                    Default is [].

% 2004-09-08   Created by Patrick Eriksson.


function A = arts_abstable( Q, workfolder, do_load )


%- Default values
%
workfolder_DEFAULT = [];
do_load_DEFAULT    = false;
%
set_defaults;


%- Check input
%
rqre_datatype( 'struct', Q );
rqre_datatype( {'empty','char'}, workfolder );



folder_created = 0;
%
if isempty( workfolder )
  workfolder     = create_tmpfolder;
  folder_created = 1;
end


try
  %
  parts = qarts2cfile( 'GetAbsTable' );
  S     = qarts2cfile( Q, parts, workfolder );
  cfile = fullfile( workfolder, 'cfile.arts' );
  qtool( S, cfile, [] );
  arts( cfile );

catch
  if folder_created
    delete_tmpfolder( workfolder );
  end
  rethrow(lasterror);
end


if folder_created  |  do_load
  A = xmlLoad( fullfile( workfolder, 'abs_lookup.xml' ) );
else
  A = fullfile( workfolder, 'abs_lookup.xml' );  
end


if folder_created 
  delete_tmpfolder( workfolder );
end




