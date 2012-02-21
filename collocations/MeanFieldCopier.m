classdef MeanFieldCopier < MeanDataset & FieldCopier
    % copy fields and average them over the larger footprint
    %
    % the secondary will be averaged over the primary
    %
    % for the secondary, any struct with additional field 'processors',
    % contains a struct with names and handles how to treat the data;
    % processors may be empty. If there is no processors it is copied as-is
    % (fine if data (almost) doesn't change), if there is it is processed
    % with the indicated handle (averaged, standard deviation, etc.).
    % for the secondary, for any copied field, 'members' may (probably
    % should or must, TBC) contain an additional field 'processors'
    % describing what else is done with the data, e.g.
    % secondary.processors.MEAN = @mean;
    % secondary.processors.STD = @std;
    % etc., these will be used to process all secondary footprints fitting
    % in the primary one, then all stored seperately with the name and an
    % underscore prepended, e.g. MEAN_Ice_Water_PATH
    % note: this implies all processor results have the same type, so
    % choose one that fits all
    %
    % FIXME DOC
    
    % $Id$
    methods
        function self = MeanFieldCopier(cd, fieldstruct1, fieldstruct2, varargin)
            % Call signature: see FieldCopier
            %
            % FIXME DOC
            
            % sort out which ones are just copied, which one processed
            % smartly
            error([mfilename ':NotImplemented'], 'Not implemented yet');
            
            secfields = fieldnames(fieldstruct2);
            for i = 1:length(secfields)
                if isfield(secfield{i}, 'processors')
                    fs2_proc.(secfield{i}) = fieldstruct2.secfield{i};
                else
                    fs2_copy.(secfield{i}) = fieldstruct2.secfield{i};
                end
            end
            copier = FieldCopier(cd, fieldstruct1, fs2_copy, varargin{:}); % call parent constructor
            
            % add some members
            self.members.FIRST.type = 'int';
            self.members.FIRST.atts.long_name = 'First corresponding row in overlap';
            
            self.members.LAST.type = 'int';
            self.members.LAST.atts.long_name = 'Last corresponding row in overlap';
        end
    end
end
