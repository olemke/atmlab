% GF_SET_GRID   Sets gformat grid data
%
%    The fields GRIDx, GRIDx_NAME and GRIDx_UNIT can be set with the function,
%    where x is *dim*.
%
% FORMAT   G = gf_set_grid( G, dim, grid [, name, unit ] )
%
% OUT   G     Modified gformat structure (array).
% IN    G     Original gformat structure (array).
%       dim   Dimension.
%       grid  Grid to be copied.
% OPT   name  Grid name.
%       unit  Grid unit (a string).

% 2010-01-06   Created by Patrick Eriksson.

function G = gf_set_grid( G, dim, grid, name, unit )

errid = ['atmlab:' mfilename ':input'];

%rqre_nargin( 3, nargin );                                      %&%
assert(nargin>3,errid,'Needs atleast 3 input arguments')


%rqre_datatype( G, @isstruct );                                  %&%
assert(isstruct(G),errid,'G must be a structure')


%rqre_alltypes( dim, {@istensor0,@iswhole} );                    %&%
%rqre_in_range( dim, 1 );                                        %&%
assert(isnumeric(dim) && isscalar(dim)...   istensor0
    &&  all( dim - round(dim) == 0 )...     iswhole (-isnumeric whis is already called and for n and not n(:))
    && dim>0 ...                            rqre_in_range( dim, 1 );
    ,errid,'*dim* did not pass the test: @istensor0 && @iswhole')


%rqre_datatype( grid, {@isempty,@istensor1} );                   %&%
assert( isempty(grid) || ...
    (isempty(grid) || (isnumeric(grid) && size(grid,1) >=1 && size(grid,2) == 1 && ndims(grid)==2)),... istensor1
    errid, '*grid* must pass the test @isempty || @istensor1') %#ok<ISMAT>

bname = sprintf( 'GRID%d', dim );

for i = 1 : length(G)
    
    G(i).(bname) = grid;
    
    if nargin >= 4
        %rqre_datatype( name, {@isempty,@ischar} );                  %&%
        assert( isempty(name) || ischar(name),...
            errid, '*name* must pass the test: @isempty || @ischar')
        
        G(i).([bname,'_NAME']) = name;
        if nargin >= 5
            %rqre_datatype( unit, {@isempty,@ischar} );                %&%
            assert( isempty(unit) || ischar(unit),...
                errid, '*name* must pass the test: @isempty || @ischar')
            G(i).([bname,'_UNIT']) = unit;
        end
    end
end
