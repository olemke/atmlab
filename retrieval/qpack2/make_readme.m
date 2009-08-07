function make_readme
  
  
fid = fileopen( 'qpack2.txt', 'w' );
qinfo( @qpack2, 'all', fid, 0 );
fileclose( fid );


!pdflatex README
!pdflatex README