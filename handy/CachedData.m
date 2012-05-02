classdef CachedData < handle
    % Cache data rather than re-generate every time
    %
    % Sometimes, it can be somewhat tricky to implement code in a way that
    % prevents re-reading or re-calculating the exact some thing with only
    % a short time in between. Don't despair! Here is the class you'll
    % love. Just use its methods to store and retrieve data.
    %
    % Entries are stored by string. Internally, it uses a structure, so you
    % may use <a href="matlab:help genvarname">genvarname</a> to generate valid names to use for caching.
    % 
    %
    % CachedData Properties:
    %
    %   maxsize -       Maximum permitted cache size in bytes
    %
    % CachedData Methods:
    %
    %   get_entry -     Retrieve entry
    %   has_entry -     Check whether entry exists
    %   set_entry -     Set new entry and, if needed, remove old
    %   clear -         Completely clear the cache
    
    % $Id$
    properties
        % maximum permitted cache size in bytes
        %
        % default 100 MiB
        maxsize = 100*2^20;
    end
    
    properties (GetAccess = private, SetAccess = private)
        cache = struct();
    end
    
    methods
        function data = get_entry(self, s)
            % Retrieve entry from cache
            %
            % FORMAT
            %
            %   data = c.get_entry(s)
            
            data = self.cache.(s);
        end
        
        function b = has_entry(self, s)
            % check whether entry exists in cache
            %
            % FORMAT
            %
            %   b = c.has_entry(s)
            
            b = isfield(self.cache, s);
        end
        
        function set_entry(self, s, d)
            % sets cache entry and removes old entry if needed
            %
            % Set a cache entry and, if the size is exceeded, remove the
            % oldest entry.
            %
            % FORMAT
            %
            %   c.set_entry(s, d)
            %
            % IN
            %
            %   s   string      string by which it is stored
            %   d   any         data to be stored
            
            logtext(atmlab('OUT'), 'Setting cache entry: %s (new size: ', s);
            self.cache.(s) = d;
            fprintf(atmlab('OUT'), '%d bytes)\n', self.cachesize());
            if self.toolarge()
                self.del_old_entry();
            end
        end        
        
        function clear(self)
            % clear the cache completely
            self.cache = struct();
        end
    end
    
    methods (Access = private)
        function del_old_entry(self)
            % Remove oldest entry in cache.
            %
            % FORMAT
            %
            %   c.del_old_entry()
            flds = fieldnames(self.cache);
            logtext(atmlab('OUT'), 'Pruning cache entry %s\n', flds{1});
            self.cache = rmfield(self.cache, flds{1});
            logtext(atmlab('OUT'), 'New size: %d bytes\n', self.cachesize());
        end
        

        function b = toolarge(self)
            % whether or not to remove old entry
            %
            % Check whether the current size exceeds the total size.
            b = self.cachesize() > self.maxsize;
        end
        
        function c = cachesize(self)
            % get size in bytes
            dummy = self.cache;
            X = whos('dummy');
            c = X.bytes;
        end
    end
end
