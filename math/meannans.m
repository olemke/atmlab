% MEANNANS   Take the mean removing first NaNs
%
%    As matlab MEAN but removing first the NaNs. If a column is
%    all NaNs the mean of that column and the number of values
%    used for the average will be flagged as NaN
%
% FORMAT   [ m, s ] = meannans( n )
%        
% OUT   m      mean of the vector or vector with a mean of the columns 
%              of the matrix
%       s      number of values used for each mean after NaNs are
%              removed
% IN    n      Vector or matrix

% 2002-12-10  Created by Patrick Eriksson. 


function [ m, s ] = meannans( n )


% making sure is a column vector
if isvector( n ) & ( size(n,1) < size(n,2) )
  n   =  n';
end

% doing mean per column after removing NaNs
m  = zeros( 1, size( n, 2 ) );
s  = zeros( size(m) );
for j = 1:size( n, 2 )
   a      = n( :, j );
   a      = a( find ( ~isnan( a ) ) );
   if isempty( a ) 
     m( j ) = NaN;
     s(j)   = NaN;
   else
     m(j)   = mean( a );
     s(j)   = length( a );
   end
end




