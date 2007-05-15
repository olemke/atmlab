% A standardised set of functions for handling gridded data.
%
%   The functions provide little internal functionality. They constitute
%   instead an interface to other parts of atmlab, where data are stored
%   following a common data format. 
%
%   The gridded data format (shortened to gf) has these mandatory fields
%     name         Name of data (e.g. 'H20-161')
%     source       Source of data.
%     dim          Dimension of data.
%     data         Data (dim1,dim2,...).
%     data_name    Name on data (e.g. 'Volume mixing ratio'). 
%     data_unit    Unit of data (e.g. 'ppm').
%     grid1        Grid along dimension 1.
%     grid1_name   Name on grid 1 (e.g. 'Pressure').
%     grid1_unit   Unit of grid 1 (e.g. 'Pa').
%     grid2 ...
%
%   The fields matching grid1, grid1_name and grid1_unit must exist for all
%   used dimensions. Any grid data for higher diemsnions are just ignored.
%
%   It is further allowed to add other fields, specified by the user.