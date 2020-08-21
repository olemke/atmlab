% QARTS3_RUN   Runs ARTS for given Q 
%
%    This is the function for ther Qarts3 system to run ARTS. 
%
% FORMAT U = qarts3_run( Q [, wfolder, option, check_fields ] )
%
% OUT  U        ARTS output, as a structure with fields matching WSV names.
% IN   Q        Qarts3 definition structure
% OPT  wfolder  Work folder. A folder where temporary files can be created.
%               Default is [], that triggers the creation of a temporary
%               folder.
%      option   Calculation optione. Default is 'All'. See *qarts3cfile* for
%               more options.
%      check_fields Flag to control if all fields are recognised. Default is
%                   true.

% 2020-08-19   Patrick Eriksson

function U = qarts3_run(Q,wfolder,option,check_fields)
%
if nargin < 2, wfolder = []; end
if nargin < 3 | isempty(option), option = 'All'; end
if nargin < 4 | isempty(check_fields), check_fields = true; end

%- Create wfolder?
%
if isempty( wfolder )
  wfolder = create_tmpfolder;
  cu = onCleanup( @()delete_tmpfolder( wfolder ) );
end
   

%- Run ARTS
%
S     = qarts3cfile( Q, wfolder, option, check_fields );
cfile = fullfile( wfolder, 'cfile.arts' );
strs2file( cfile, S );
arts( cfile );

    
%- Identify and read output
%
fnames = fieldnames( Q );
U = [];
%
for f = 1 : length(fnames)
  % Only WSMS and agenda fields can contain an output definition
  if strfind( fnames{f}, 'WSMS' ) | strfind( upper(fnames{f}), 'AGENDA' )
    for m = 1 : length(Q.(fnames{f}))
      if strncmp( Q.(fnames{f}){m}, '<OUTPUT>', 8 )
        artsvar = strtrim( Q.(fnames{f}){m}(9:end) );
        % Make read inside try, as all <OUTPUT> don't necessarily end up in
        % cfile (could be inside IF or in part not used)
        try
          U.(artsvar) = xmlLoad( fullfile( wfolder, [artsvar,'.xml'] ) );
        end
      end
    end
  end
end