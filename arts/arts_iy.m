% ARTS_IY   Calculates a pencil beam spectrum using ARTS
%
%    Takes a qarts structure and calculates corresponding pencil beam
%    spectrum.
%
%    The field Q.YCALC_WSMS is basically treated as iy would be
%    "IYCALC_WSMS". That is, the call of iyCalc should be placed in 
%    Q.YCALC_WSMS.
%
% FORMAT   [iy,iy_aux,ppath] = arts_iy( Q [, workfolder] )
%        
% OUT   iy           Spectrum vector.
%       iy_aux       As the WSV with the same name.
%       ppath        As the WSV with the same name.
% IN    Q            Qarts structure.
% OPT   workfolder   If not defined or empty, a temporary folder is created.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored. These files
%                    will be left in the folder. The files are not read if
%                    corresponding output argument is not considered.
%                    Default is [].
%        full_ppath  Extract full ppath structures. Default is to use the
%                    *ppathWriteXMLPartial* WSM.

% 2015-04-19   Created by Patrick Eriksson.

function [iy,iy_aux,ppath] = arts_iy( Q, workfolder, full_ppath )
%
if nargin < 2, workfolder = [];    end
if nargin < 3, full_ppath = false; end

%
if atmlab( 'STRICT_ASSERT' )
  rqre_datatype( Q, @isstruct );
  rqre_datatype( workfolder, {@isempty,@ischar} );
end


%- Create workfolder?
%
if isempty( workfolder )
  workfolder = create_tmpfolder;
  cu = onCleanup( @()delete_tmpfolder( workfolder ) );
end


%- Create cfile
%
parts = qarts2cfile( 'iy' );    
S     = qarts2cfile( Q, parts, workfolder );
cfile = fullfile( workfolder, 'cfile.arts' );


% Shall saving of ppath be added?
if nargout >= 3
  filename = fullfile( workfolder, 'ppath.xml' );
  if full_ppath
    s = sprintf('WriteXML(output_file_format,ppath,"%s")', filename );    
  else
    s = sprintf('ppathWriteXMLPartial(output_file_format,ppath,"%s")', ...
                     filename );
  end
  S{end+1} = S{end};
  S{end-1} = s;
end

%- Run ARTS
%
strs2file( cfile, S );
arts( cfile );


%- Load data
% 
iy = xmlLoad( fullfile( workfolder, 'iy.xml' ) );
%
if nargout >= 2
  iy_aux = xmlLoad( fullfile( workfolder, 'iy_aux.xml' ) );
end
%
if nargout >= 3
  ppath = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );
end
