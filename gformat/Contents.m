% A standardised format for handling gridded data.
%
%   The gformat is defined as a struct array, having the following mandatory 
%   fields:
%   ------------------------------------------------------------------------
%     name         Name of data (e.g. 'H20-161')
%     source       Source of data (such as the name og a file).
%     dim          Dimension of data.
%     data         Data (dim1,dim2,...).
%     data_name    Name on data (e.g. 'Volume mixing ratio'). 
%     data_unit    Unit of data (e.g. 'ppm').
%     grid1        Grid along dimension 1.
%     grid1_name   Name on grid 1 (e.g. 'Pressure').
%     grid1_unit   Unit of grid 1 (e.g. 'Pa').
%     grid2 ...
%   ------------------------------------------------------------------------
%
%   The fields matching grid1, grid1_name and grid1_unit must exist for all
%   used dimensions. Any grid data for higher dimensions are just ignored.
%   Data with different dimension can be mixed in the array.
%
%   It is further allowed to add other fields, that can e.g. be used for
%   input to specific functions using gformat arrays as input.
%
%   Functions in this folder are "vectorised" (as far as possible?). That 
%   is, the functions can operate on complete (or parts of) the array. For
%   example, conversion of all dimension 1 grids of an array is done as:
%       G = gf_grid_convert( G, 1, 0, @log10 );
%