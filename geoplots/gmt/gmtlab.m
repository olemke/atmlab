% GMTLAB   Handling of GMTLAB settings.
%
%   This function is based on *prstnt_struct* and for general help see 
%   the on-line help for that function. 
%
%   Existing fields, and possible settings, are listed below. 
%
%   For adding personal settings at startup, see the file CONFIGURE. To 
%   add or change settings after startup, follow the example below. 
%
%   To check all present settings
%      gmtlab;
%
%   A specific setting is obtained as
%      value = GMTLAB( 'PDFVIEWER' );
%
%   To set a field to a specic value
%      GMTLAB( 'PDFVIEWER', 'xpdf' );
%
%   To set all fields to default
%      GMTLAB( 'defaults' );
%
% FORMAT   value = gmtlab( [varargin] )
%        
% OUT   value      Setting, if a field is selected. See further 
%                  *prstnt_struct*.
% OPT   varargin   Field, field and setting or any option supported by
%                  *prstnt_struct*.
%
%----------------------------------------------------------------------------
% OPEN_COMMAND  
%
% General command to open files with. e.g. gmtlab('OPEN_COMMAND','gnome-open') 
% ---------------------------------------------------------------------------
%
% PDFVIEWER
%
% Command to view PDF files.
%----------------------------------------------------------------------------
%
% $Date:$   Created by Salomon Eliasson based on ATMLAB by Patrick Eriksson.


function value = gmtlab( varargin )
            
persistent B

if iscell(varargin{1})
    [B,value] = prstnt_struct( B, @gmtlab_defs, varargin{:} );
else
    [B,value] = prstnt_struct( B, @gmtlab_defs, varargin );
end

function B = gmtlab_defs

B.OPEN_COMMAND      = NaN;
B.OUTDIR            = '.';
B.PDFVIEWER         = NaN;