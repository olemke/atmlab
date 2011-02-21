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
% OUTDIR
%
% Directory to output files from created by gmtlab
% ---------------------------------------------------------------------------
% PDFVIEWER
%
% Command to view PDF files.
%----------------------------------------------------------------------------
% VERBOSITY
% 
% The verbosity of Atmlab (gmtlab) functions.  
% Functions writing to the screen set a report level for each output. If the
% the set report level is higher than VERBOSITY, the output is ignored.
% Output obeying this setting is most easily produced with the function *out*.
% Functions can also use VERBOSITY to decide if figures shall be produced
% (which is most easily checked by using *out*).
%----------------------------------------------------------------------------
%
% $Date:$   Created by Salomon Eliasson based on ATMLAB by Patrick Eriksson.

function value = gmtlab( varargin )
            
persistent B

if iscell(varargin{1})
    [B,value] = gmt_prstnt_struct( B, @gmtlab_defs, varargin{:} );
else
    [B,value] = gmt_prstnt_struct( B, @gmtlab_defs, varargin );
end

%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%
function B = gmtlab_defs
%% gmtlab_defs
B.OPEN_COMMAND      = NaN;
B.OUTDIR            = '.';
B.PDFVIEWER         = NaN;
B.VERBOSITY         = 0;