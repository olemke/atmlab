% GF_SAVE   Saves gformat data
%
%    Use *gf_load* to load the data.
%
% FORMAT   gf_save( G, file )
%        
% IN   G       Gformat data to save.
%      file    Name of file to create.

% 2010-01-07   Created by Patrick Eriksson.

function gf_save( G, file )
                                                                   %&%
rqre_nargin( 2, nargin );                                          %&%
rqre_datatype( G, @isgformat );                                    %&%
rqre_datatype( file, @ischar );                                    %&%


save( file, 'G' );
