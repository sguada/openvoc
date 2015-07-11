classdef Index_Map < Default_Map
% Given a cell it will create a mapping between the cell and their position
% in the cell Ex: index_mapping({'cat','dog}) = [{'cat':1},{'dog':2}]
    methods
        function self = Index_Map(vocab)
            vocab = unique(vocab,'stable');
            self = self@Default_Map(0,vocab,num2cell(1:length(vocab)),'uniformValues',true);
        end
    end
end
        