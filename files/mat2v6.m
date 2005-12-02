% MAT2V6   Conversion of .mat files to version 6 format
%
%    Loads all .mat files in the folder, and saves them in version 6 format
%    ('-v6' option). 
%
%   Version 7 introduces a new file format that can not be loaded by earlier
%   versions. This function re-saves the data in a format that can be handled 
%   by version 6.
%
% FORMAT   mat2v6

% 2005-12-02   Created by Patrick Eriksson.

function mat2v6

XXXXXD = dir('*.mat');

for XXXXXi = 1:length(XXXXXD)

  load( XXXXXD(XXXXXi).name );

  save( XXXXXD(XXXXXi).name, '-v6', '-regexp','^[^XXXXX]' );

end