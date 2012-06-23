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
        % maximum size of what's stored on disk. Default 10 GiB.
        storedsize   = 10*2^30; % maxStoredSize =  10*2^30;
        minFreeSpace = 5*2^30;  % minimun free space you want left over (5GiB)
        
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
            ldfl = fullfile(self.cachedir, [s '.mat']);
            logtext(atmlab('OUT'), 'Reading from persistent cache: %s\n', ldfl);
            data = loadvar(ldfl, 'data');
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
        
        function set_entry(self, s, data, varargin)
            set_entry@CachedData(self, s, data);
            info = optargs(varargin, {struct()});
            svfl = fullfile(self.cachedir, [s '.mat']);
            logtext(atmlab('OUT'), 'Storing cache-entry to disk: %s -> %s\n', ...
                s, svfl);
            save(svfl, '-v7.3', 'data');
            logtext(atmlab('OUT'), 'New size: %d bytes (%.3fGiB) \n', ...
                self.disk_cachesize(),self.disk_cachesize()/1024^3);
            if self.disk_free() + self.disk_cachesize() < self.minFreeSpace
                error(['atmlab:' mfilename ':noSpace'],'df + du < minFreeCache')
            end
            if self.disk_toolarge()
                self.del_old_disk_entry()
            end
            % store info. salomon: I'll make the name a bit more unique
            % here
            infofile = fullfile(self.cachedir, ['info' [datestr(now,'ddmmyy') '-' num2str(cputime)] '.mat']);
            if exist(infofile, 'file')
                all_info = loadvar(infofile, 'all_info');
            end
            all_info.(s) = info;
            save(infofile, 'all_info');
        end
        
        function df = disk_free(self)
            % get the free space using df (output in bytes)
            % stat -f ... %a ... gives no. of blocks available
            % stat -f ... %s ... gives block size
            sizes = exec_system_cmd({['stat -f --printf=''%a'' ' self.cachedir], ['stat -f --printf=''%s'' ' self.cachedir]});
            df = (str2double(sizes{1}) * str2double(sizes{2}));
            %x = exec_system_cmd(sprintf('df -k %s',self.cachedir));
            %df = structfun(@str2double,regexp(x{1}(regexp(x{1},'\n'):end),'^[^ ]+ +[0-9]+ +[0-9]+ +(?<bytes>[0-9]+)','names'));
            %df = df*1024;
        end
        
        function sz = disk_cachesize(self)
            d = dir(self.cachedir);
            sz = sum(arrayfun(@(x) x.bytes, d));
        end
        
        function b = disk_toolarge(self)
            b = self.disk_cachesize() > self.storedsize || self.disk_free() < self.minFreeSpace;
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
