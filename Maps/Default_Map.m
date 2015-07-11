classdef Default_Map < containers.Map
    properties
        default_value
    end
    methods
        function self=Default_Map(default_value,varargin)
            self = self@containers.Map(varargin{:});
            self.default_value = default_value;
            
        end
        function res = values(self,keys)
            if nargin < 2
                res = values@containers.Map(self);
            else
                if iscell(keys)
                    res = cell(size(keys));
                    present = self.isKey(keys);
                    res(present) = values@containers.Map(self,keys(present));
                    res(~present) = {self.default_value};
                else
                    if self.isKey(keys)
                        res = values@containers.Map(self,{keys});
                        res = res{1};
                    else
                        res = self.default_value;
                    end
                end
            end
        end
%         end
%             if nargin == 1
%                 response = cell2mat(values@containers.Map(self));
%                 return
%             end
%             if iscell(keys)
%                 iskey = self.isKey(keys);
%                 response = repmat(self.default_value,size(keys,1),size(keys,2));
%                 response(iskey) = cell2mat(values@containers.Map(self,keys(iskey)));
%             else
%                 if self.isKey(keys)
%                     response = values@containers.Map(self,{keys});
%                     response = response{1};
%                 else
%                     response = self.default_value;
%                 end
%             end                          
%         end
%         function value=subsref(self,key)
%             if self.isKey(key)
%                 value = subsref@containers.Map(self,key);
%             else
%                 value = self.default_value;
%             end                                  
%         end
    end
end