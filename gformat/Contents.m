% A standardised format for handling gridded data.
%
%   The gformat consists of structures, here denoted as D and G.
%
%   The data format for your particular application is described by the
%   structure D. This structure has the following mandatory fields:
%   ------------------------------------------------------------------------
%    DIM        : Maximum dimension of data. A positive integer. 
%    GRID1_NAME : Description of data dimension 1, such as 'Pressure'.
%    GRID1_UNIT : Unit for data dimension 1, such as 'Pa'.
%    GRID2_NAME : Description of data dimension 1, such as 'Latitude'.
%    GRID2_UNIT : Unit for data dimension 1, such as 'deg'.
%    ...        : And so on up to the dimension specified by *DIM*.
%   ------------------------------------------------------------------------
%
%   The actual data are put into the structure G, having the following 
%   mandatory fields:
%   ------------------------------------------------------------------------
%     NAME      : Name of data, such as 'Water vapour'.
%     DIMS      : Dimensions actually hold by the data. A vector with
%                 integer values, such as [1 2]. Dimensions must by
%                 sorted in ascending order, with no dimensions repeated
%                 or > *DIM*.
%     SOURCE    : Source of data, such as the name of a file.
%     DATA      : The data (dim1,dim2,...).
%     DATA_NAME : Type of data, such as 'Volume mixing ratio'.
%     DATA_UNIT : Unit of data, such as 'ppm'.
%     GRID1     : Grid along dimension 1.
%     GRID2     : Grid along dimension 1.
%     ...       : And so on up to the dimension specified by *DIM*.
%   ------------------------------------------------------------------------
%
%   That is, the overall format is specified by D. This is a single structure,
%   while G can be an array. Data having different dimensions can be mixed in
%   G, which is handled by the *DIMS* field. Let us assume that D is set up to
%   handle atmospheric fields where dimension 1, 2 and 3 correspond to
%   pressure, latitude and longitude, respectively. D.DIM is then 3, and 3D
%   items in G have DIMS=[1 2 3]. A single vertical profile (1D) can be
%   included, and has then DIMS=1. If e.g. the surface altitude is stored as
%   part of G, this item should have DIMS=[2 3].
%
%   It is further allowed to add other fields, to both D and G. These fields
%   can be used for input to specific functions using gformat arrays as input.
%
%   Functions in this folder are "vectorised" (as far as possible?). That is,
%   the functions can operate on complete (or parts of) the array. The two
%   first input arguments to the functions are D and G. For example, to set
%   item of 2 and 3 of a G array to hold the scalar (0D) value of 1e3: 
%      G(2:3) = gf_set( D, G(2:3), [], 1e3 );
%
%   Note that all items in G must have exactly the same fields. As the
%   functions do not set all fields (they are anyhow unaware of your
%   specific fields), it is useful to make a function creating an empty
%   G structure (with some default values?). Creating a new item in G is
%   then done as
%      G(end+1) = gf_set( D, g_empty, [], 1e3 );

% The grid for "empty" dimensions can be empty or a scalar.