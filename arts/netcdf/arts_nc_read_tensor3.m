% ARTS_NC_READ_TENSOR3   Read Tensor3 from ARTS NetCDF file.
%
%    Reads a Tensor3 from a NetCDF file saved with Arts.
%
% FORMAT   ret = arts_nc_read_tensor3(filename)
%        
% OUT   ret      Tensor3
%       
% IN    filename Name of NetCDF input file.

% 2010-02-02   Created by Oliver Lemke.

function ret = arts_nc_read_tensor3 (filename)

ret = permute (loadncvar (filename, 'Tensor3'), [3 2 1]);
