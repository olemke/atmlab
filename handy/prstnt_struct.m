% PRSTNT_STRUCT   Handles a persistent structure.
%
%    This a help function to handle the setting and extraction of fields
%    values of a structure, defined as persistent in some function. 
%
%    A persistent structure can be used for several purposes. The application
%    in mind here is that the structure contains a number of settings of 
%    global type. How this function works is bets described by an example.
%    Let's say that we want to have a function that tells various plotting 
%    function what color map to use, without having that as input to each 
%    function. We create then a function called *cmap* with a local
%    sub-function *cmap_def*:
%
%       function value = cmap( varargin )
%         persistent A
%         [A,value] = prstnt_struct( A, @cmap_def, varargin );
%       
%       function A = cmap_def
%         A.map = 'gray';
%
%    By executing 
%       map = cmap('map'); 
%    we get the present setting for the color map. A new color map is set as 
%       cmap('map','jet');"
%    The existing fields and thier values are displayed by
%       cmap;
%    The default settings are re-created by:
%       cmap('defaults');
%
%    This is a very simple example. The technique is of course more powerful
%    if more settings variables are involved.
%
%    More fields are added to the structure by adding a definition in the 
%    function setting the default values. It is not allowed to add fields
%    not defined in the default function.
%
%    If the structure will contain large variables it could be worth the
%    effort to copy the code of this function (with some modifications) to 
%    the function where the persistent structure is defined to avoid un-
%    necassary copying of data.
%
% FORMAT   [A,value] = prstnt_struct( A, def_fun, varargin )
%        
% OUT   A          The structure.
%       value      Extracted value (if applicable, otherwise []).
% IN    A          The structure.
%       def_func   Handle to function setting default values for fields.
%       varargin   The input to the calling function.

% 2002-12-14   Created by Patrick Eriksson.


function [A,value] = prstnt_struct( A, def_fun, varargin )


min_nargin( 3, nargin );


if isempty( A )
  A = feval( def_fun );
end


%=== As this function is called witha varargin argument, we have to extract
%=== varargin as given to the calling function.
%
varg = varargin{1};


value = [];

switch length( varg )

  case 0
    %
    disp( A );

  case 1
    %
    if strcmp( varg{1}, 'defaults' )
      A = feval( def_fun );
    else

      if ~isfield( A, varg{1} )
        error( sprintf('The field %s does not exists.', varg{1} ) ); 
      end

      if nversion > 6.1
        value = A.(varg{1});
      else
        value = getfield( A, varg{1} );
      end
    end

  case 2
    %
    if ~isfield( A, varg{1} )
      error( sprintf('The field %s is not a valid option.', varg{1} ) ); 
    end
    %
    if nversion > 6.1
      A.(varg{1}) = varg{2};
    else
      A = setfield( A, varg{1}, varg{2} );
    end
    %
    value = varg{2};

  otherwise
    %
    error('To many input arguments.');
end

return


