% QP2_MAKE_PDF   Compiles the Qpack2 manual
%
%   The function extracts on-line documentation to be included on the PDF.
%   And runs pdflatex (twice) on qpack2.tex
%
% FORMAT   qp2_make_pdf( [clean_files] )
%
% OPT   clean_files   Flag to delete unnecessary files

% 2009-08-10   Created by Patrick Eriksson.


function qp2_make_pdf(clean_files)

wd = pwd;
%
if ~strcmp( wd(end+(-5:0)), 'qpack2' )
  error( 'This function must be exucuted from the qpack2 sub-folder.' );
end
  
  
fid = fileopen( 'qpack2.txt', 'w' );
qinfo( @qpack2, 'all', fid, 0 );
fileclose( fid );

fid = fileopen( 'qp2_y.txt', 'w' );
qinfo( @qp2_y, 'all', fid, 0 );
fileclose( fid );


!pdflatex qpack2
!pdflatex qpack2


if nargin  &  clean_files
  delete('qpack2.txt');
  delete('qp2_y.txt');
  delete('qpack2.log');
  delete('qpack2.aux');
end
