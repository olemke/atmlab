function atmplot_scanseries(h,Ss)


%=== Some sizes
%
%- Number of scans
ns = length( Ss );


%=== Loop the scans, pick out some data and make some checks of input
%
orbit = zeros( ns, 1 );
scan  = zeros( ns, 1 );
np    = zeros( ns, 1 );
%
for is = 1 : ns
  %
  orbit(is) = Ss{is}.orbit;
  scan(is)  = Ss{is}.scan;
  np(is)    = length( Ss{is}.z );
  %
  if length( Ss{is}.p ) ~= np
    serr = sprintf( ['The lengths of altitude and profile vector for ',...
        'orbit %d and scan %d are not identical.'], orbit(is), scan(is) );
    error( serr );
  end
  %
end


%=== Create a fractional orbit number for each scan
%
orbits = unique( orbit );
no     = length( orbits );
nscans = zeros( no, 1 );
%
for io = 1 : no
  nscans(io) = max( scan( find( orbit == orbits(io) ) ) );
end
%
forbit = zeros( ns, 1 );
%
for is = 1 : ns
  forbit(is) = orbit(is) + nscans(
end

