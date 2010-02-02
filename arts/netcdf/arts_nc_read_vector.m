% ARTS_NC_READ_VECTOR   Read Vector from ARTS NetCDF file.
%
%    Reads a Vector from a NetCDF file saved with Arts.
%
% FORMAT   ret = arts_nc_read_vector(filename)
%        
% OUT   ret      Vector
%       
% IN    filename Name of NetCDF input file.

% 2010-02-02   Created by Oliver Lemke.

function ret = arts_nc_read_vector (filename)

ret = loadncvar (filename, 'Vector');
