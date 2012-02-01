classdef HomemadeDataset < SatDataset
    % What Associated and Collocated, but not Sat, -dataset, have.
    %
    % Work in progress!
    %
    % $Id$
    
    % read-only props (may be alterable with methods)
    %properties (SetAccess = protected)        
        %members = struct();
    %end
    
    
    properties
        cols = struct;
        %members;
    end    
    
    methods
             
        function [fn, global_atts] = store(self, date, spec, data, varargin)
            % store Write collocation data to netcdf file
            %
            % Write collocation data for date in data to a netcdf file.
            % The filename is determined from self, date, spec.
            %
            % FORMAT
            %
            %   obj.store(date, spec, data[, info])
            %
            % IN
            %
            %   date
            %   spec
            %   data        actual data (columns by self.cols)
            %   info        (optional) struct with more info to put in NetCDF
            %
            % OUT
            %
            %   fn          file data was written to
            %   atts        global attributes that were written to file
            %
            % $Id$
            
            fn = self.find_granule_by_datetime(date, spec);
            
            info = optargs(varargin, {struct()});
            
            %year = date(1);
            %month = date(2);
            %day = date(3);
            
            if strcmp(fn(end-1:end), 'gz') % take off this part
                fn(end-2:end) = '';
            end
            
            outdir = fileparts(fn);
            % temporary filename, later compressed written to final place
            temp_out = tempname(atmlab('WORK_AREA'));
            if ~exist(outdir, 'dir')
                logtext(atmlab('OUT'), 'Creating %s\n', outdir);
                mkdir(outdir);
            end
            
            %% create the file
            
            logtext(atmlab('OUT'), 'Writing %s\n', temp_out);
            ncid = netcdf.create(temp_out, 'NC_CLOBBER'); % overwrite existing
            cleanupObj = onCleanup(@() self.cleanup(temp_out, ncid));
            
            %% define the dimensions
            
            ncollocs = size(data, 1);
            dim_collocs = netcdf.defDim(ncid, 'Collocations', ncollocs);
            
            %% put global attributes
            
            global_atts = struct();
            global_atts.Conventions = 'CF-1.4';
            global_atts.title = 'Collocations';
            global_atts.date = iso_timestamp();
            global_atts.institution = ['Department of Computer Science, Electrical and Space Engineering, Division of Space Technology, Lule' char(unicode2native('å')) ' University of Technology, Kiruna, Sweden'];
            global_atts.source = 'Collocation codes, part of atmlab';
            global_atts.references = 'Holl et al.  (2010); John et al. (2012)';
            global_atts.software_version = atmlab_version;
            global_atts.id = [atmlab_version() ' -- ' iso_timestamp() ' -- ' fn];

            % add caller-contributed ones
            warning('off', 'catstruct:DuplicatesFound');
            global_atts = catstruct(global_atts, info);
            warning('on', 'catstruct:DuplicatesFound');
            % convert to cell-array
            global_atts = mat2cell([fieldnames(global_atts) struct2cell(global_atts)], ...
                ones(1, length(fieldnames(global_atts))), 2).';
            addncattributes(ncid, global_atts);
            
            %% define variables, variable attributes, additional dimensions
            
            vars = fieldnames(self.cols);
            
            varids = zeros(size(vars));
            dims = struct();
            for j = 1:length(vars)
                varname = vars{j};
                type = self.members.(varname).type;
                atts = self.members.(varname).atts;
                
                % check if we have other dimensions besides the length
                if isfield(self.members.(varname), 'dims')
                    dimname = self.members.(varname).dims{1};
                    dimsize = self.members.(varname).dims{2};
                    try
                        if ~isfield(dims, dimname)
                            dims.(dimname) = netcdf.defDim(ncid, dimname, dimsize);
                        end
                    catch ME
                        switch ME.identifier
                            case 'MATLAB:netcdf:defDim:nameIsAlreadyInUse'
                                % no problem
                            otherwise
                                ME.rethrow();
                        end
                    end
                    thisdim = [dim_collocs dims.(dimname)];
                else
                    thisdim = dim_collocs;
                end
                % define variable and put attributes
                varid = netcdf.defVar(ncid, varname, type, thisdim);
                varids(j) = varid;
                for k = fieldnames(atts)'
                    netcdf.putAtt(ncid, varid, k{1}, atts.(k{1}));
                end
            end
            
            %% write data
            
            % end define mode
            
            netcdf.endDef(ncid);
            
            % put vars
            logtext(atmlab('OUT'), 'Writing: ');
            
            for j = 1:length(vars(:).')
                varname = vars{j};
                fprintf(atmlab('OUT'), '%s ', varname);
                
                varid = varids(j);
                netcdf.putVar(ncid, varid, data(:, self.cols.(varname)));
                fprintf(atmlab('OUT'), '\n');
            end
            logtext(atmlab('OUT'), 'Finalising\n');
            logtext(atmlab('OUT'), 'Gzipping to %s and removing uncompressed\n', [fn '.gz']);
            netcdf.close(ncid);
            gzipped_filename = gzip(temp_out, outdir);
            movefile(gzipped_filename{1}, [fn '.gz']);
            logtext(atmlab('OUT'), 'Done\n');
            
        end

        function add_field(self, name, type, atts)
            % Adds a single (stored) data field; mainly used for collocated
            %
            % cd.add_field(name, type, atts)
            %
            % See also: add_fields
            
            if isfield(self.members, name)
                error(['atmlab:' mfilename ':alreadyexists'], ...
                    'field with name %s already exists', name);
            end
            
            self.members.(name) = struct(...
                'type', type, ...
                'atts', atts);
            
        end
    end
    
    % static/private are used like subfunctions
    methods (Static, Access = private)
        function cleanup(temp_out, ncid)
            logtext(atmlab('OUT'), 'Cleaning up\n');
            try
                netcdf.close(ncid);
            catch ME
                switch ME.identifier
                    case {'MATLAB:netcdf:inq:notNetcdfID', 'MATLAB:netcdf:close:notNetcdfID', ...
                            'MATLAB:netcdf:close:ebadid:notNetcdfID', 'MATLAB:imagesci:netcdf:libraryFailure'} % already closed
                    otherwise
                        ME.rethrow();
                end
            end
            delete(temp_out);
        end
    end
    
end
