classdef Multi_Map 
% Given a cell it will create a mapping between the cell and their position
% in the cell Ex: Multi_Map({'cat','dog','cat'}) = [{'cat':[1,3]},{'dog':2}]
    properties
        map
    end
    methods
        function self = Multi_Map(keys,values)
            if nargin < 2
                values = num2cell(1:length(keys));
            end
            new_map = containers.Map('uniformValues',false);
            for i=1:length(keys)
                if ~isempty(keys{i})
                    if new_map.isKey(keys{i})
                        new_map(keys{i}) = unique([new_map(keys{i}) values{i}]);
                    else
                        new_map(keys{i}) = [values{i}];
                    end
                end
            end
            self.map = new_map;
        end
        function res = values(self,keys)
            if nargin < 2
                res = self.map.values;
            else
                if iscell(keys)
                    res = cell(size(keys));
                    present = self.map.isKey(keys);
                    res(present) = self.map.values(keys(present));
                else
                    if self.map.isKey(keys)
                        res = self.map(keys);
                    else
                        res = [];
                    end
                end
            end
        end
        function res = keys(self)
            res = self.map.keys;
        end
        function res = isKey(self,keys)
            res = self.map.isKey(keys);
        end
        function self=append(self,multi_map)
            my_map = self.map;
            mapping = multi_map.map;
            keys = mapping.keys;
            values = mapping.values;
            for i=1:length(keys)
                if ~isempty(keys{i})
                    if my_map.isKey(keys{i})
                        my_map(keys{i}) = unique([my_map(keys{i}) values{i}]);
                    else
                        my_map(keys{i}) = [values{i}];
                    end
                end
            end
            self.map = my_map;
        end
    end
end