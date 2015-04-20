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

% 2015-04-19   Created by Patrick Eriksson.

function [iy,iy_aux,ppath] = arts_iy( Q, workfolder )
%
if nargin < 2, workfolder = []; end
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


%- Run ARTS
%
parts = qarts2cfile( 'iy' );    
S     = qarts2cfile( Q, parts, workfolder );
cfile = fullfile( workfolder, 'cfile.arts' );
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
