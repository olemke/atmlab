% PYARTS_TMATRIX   Single scattering properties by T-matrix method
%
%    This is an interface to the PyARTS package by Cory Davis. This 
%    function creates a file, in ARTS XML format, with single scattering 
%    properties for a single particle.
%
% FORMAT   pyarts_tmatrix(tmpfolder,outfile,shape,orient,r,aratio,f,t,...
%                                                       wphase,za_grid,aa_grid)
%        
% IN    tmpfolder   Temporary folder, where python will be launched.
%       outfile     Name of output file (including extension). If not a
%                   a complete parth is given, the file ends up in *tmpfolder*.
%       shape       Particle shape. Options are
%                      'spheriod'   and   'cylinder'
%       orient      Particle orientation. Options are
%                      'random'  Randomly oriented (=p20)
%                      'horali'  Horizontally aligned (=p30)
%       r           Equivalent volume radius [m].
%       aratio      Aspect ratio.
%       f           Frequency grid.
%       t           Temperature grid.
% OPT   wphase      Water phase. Options are
%                      'ice'   and   'liquid'
%                   Default is 'ice'
%       za_grid     Zenith angle grid. Default is 0:10:180.
%       aa_grid     Azimuth angle grid. Default is 0:10:180.

% 2005-06-08   Created by Patrick Eriksson.


function pyarts_tmatrix(tmpfolder,outfile,shape,orient,r,aratio,f,t,varargin)
%
[wphase,za_grid,aa_grid] = optargs( varargin, { 'ice', 0:10:180, 0:10:180 } );


Q.OUTFILE = outfile;
Q.R       = r*1e6;
Q.ARATIO  = aratio;
Q.F       = vector2commalist(f,'%.4e');
Q.T       = vector2commalist(t);
Q.WPHASE  = wphase;
Q.ZA      = vector2commalist(za_grid);
Q.AA      = vector2commalist(aa_grid);


switch lower(shape)
  %
  case 'spheriod'
    Q.SHAPE   = -1;
  case 'cylinder'
    Q.SHAPE   = -2;
  otherwise
    error( ...
          'Unknown selection of shape (can be ''spheriod'' or ''cylinder'').');
end


switch lower(orient)
  %
  case 'random'
    Q.PTYPE   = 20;
  case 'horali'
    Q.PTYPE   = 30;
  otherwise
    error( ...
        'Unknown selection of orientation (can be ''random'' or ''horali'').');
end


switch lower(wphase)
  %
  case {'ice','liquid'}
    ;
  otherwise
    error('Unknown selection of orientation (can be ''ice'' or ''liquid'').');
end


tmplt = fullfile( fileparts(which('pyarts_tmatrix')), 'tmatrix.py.tmplt' );

S = file2strs( tmplt );

cfile = fullfile( tmpfolder, 'tmatrix.py' );

qtool( S, cfile, Q );

python( tmpfolder, cfile )
