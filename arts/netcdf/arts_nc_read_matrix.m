% ARTS_NC_READ_MATRIX   Read Matrix from ARTS NetCDF file.
%
%    Reads a Matrix from a NetCDF file saved with Arts.
%
% FORMAT   ret = arts_nc_read_matrix(filename)
%        
% OUT   ret      Matrix
% OUT   gattr    Global attributes
%       
% IN    filename Name of NetCDF input file.

% 2010-02-02   Created by Oliver Lemke.

function [ret, gattr] = arts_nc_read_matrix (filename)

[v, gattr] =loadncvar (filename, 'Matrix', true);
ret = v';
