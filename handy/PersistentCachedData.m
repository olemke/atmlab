classdef PersistentCachedData < CachedData
    % like CachedData but stores data on disk
    %
    % Useful to store large results of big 'read'-commands and so.
    % Default disk-stored cache-size is 10 GiB.
    %
    % !!!WARNING!!!
    %
    % DO NOT SET A CACHE-DIRECTORY THAT YOU ARE OTHERWISE USING!
    % METHODS IN THIS CLASS MIGHT DELETE FILES FROM CACHE-DIRECTORY!
    %
    % !!!WARNING!!!
    
    % $Id$
    
    properties
        % maximum size of what's stored on disk. Default 10 GB.
        storedsize = 10*2^30;
        
        % directory to store cache-files
        %
        % !!!WARNING!!!
        %
        % DO NOT SET A CACHE-DIRECTORY THAT YOU ARE OTHERWISE USING!
        % METHODS IN THIS CLASS MIGHT DELETE FILES FROM CACHE-DIRECTORY!
        %
        % !!!WARNING!!!

        cachedir;
    end
    
    methods
        function self = PersistentCachedData(cachedir)
            self = self@CachedData();
            self.cachedir = cachedir;
        end
        
        function data = get_entry(self, s)
            % get entry
            
            % first try to get it from memory
            try
                data = get_entry@CachedData(self, s);
                return
            catch ME
                switch ME.identifier
                    case 'MATLAB:nonExistentField'
                        % get from disk instead
                    otherwise
                        ME.rethrow();
                end
            end
            data = loadvar(fullfile(self.cachedir, [s '.mat']), 'data');
        end
        
        function v = has_entry(self, s)
            if has_entry@CachedData(self, s)
                v = 1;
            elseif exist(fullfile(self.cachedir, [s '.mat']), 'file')
                v = 2;
            else
                v = 0;
            end
        end
        
        function set_entry(self, s, data)
            set_entry@CachedData(self, s, data);
            save(fullfile(self.cachedir, [s '.mat']), 'data');
            logtext(atmlab('OUT'), 'New size: %d bytes\n', self.disk_cachesize());
            if self.disk_toolarge()
                self.del_old_disk_entry()
            end
        end
        
        function sz = disk_cachesize(self)
            d = dir(self.cachedir);
            sz = sum(arrayfun(@(x) x.bytes, d));
        end
        
        function b = disk_toolarge(self)
            b = self.disk_cachesize() > self.storedsize;
        end
        
        function del_old_disk_entry(self)
            % remove oldest cache-entry on disk. Should contain only
            % MAT-files!
            d = dir(self.cachedir);
            % all but 2 should end in .mat
            for i = 1:length(d)
                assert(any(strcmp(d.name, {'.', '..'})) || ...
                      ((length(d.name) >= 4) && strcmp(d.name(end-3:end), '.mat')), ...
                      ['atmlab:' mfilename ':NotACacheDir']);
            end
            while self.disk_toolarge()
                d = dir(self.cachedir);
                [~, i] = min(arrayfun(@(x) x.datenum, d));
                delete(d(i).name);
            end
        end
    end
end
