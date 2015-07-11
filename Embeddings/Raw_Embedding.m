classdef Raw_Embedding < Text_Embedding
    properties
        vocab
        filename
        dim
    end
    properties (Hidden)
        cutoff % Defines a cuttoff point
    end
    methods % (Access=private)
        function self = Raw_Embedding(varargin)
            if isempty(varargin)
                aux = load('vocab.mat','vocab');
                self.filename = 'vocab.mat';
                self.vocab = aux.vocab; 
            else
                self.filename = varargin{1};
                self.vocab = read_cell(varargin{1})';
            end
            self.dim = length(self.vocab);
            self.mapping = Index_Map(self.vocab);
            if isempty(self.cutoff)
                self.cutoff = length(self.vocab); % Not cutoff
            end
        end
    end
    methods (Static)
        function obj = instance(varargin)
            persistent self
            if  isempty(self)
                self = Raw_Embedding(varargin{:}); 
            else
                if ~isempty(varargin)
                    if ~strcmp(self.filename,varargin)
                        self = Raw_Embedding(varargin{:});
                    end
                end
            end
            obj = self;           
        end
    end
    methods
        
        function sparse_vector=word_embedding(self,word)
            % If the word.lowercase belongs to vocab then it returns 1 at its
            % position otherwise returns 1 at the first position
            sparse_vector = sparse(1,self.word2id(word),1,1,self.dim);
        end
        
        function sparse_matrix=words_embedding(self,words)
            %ids = cellfun(@(word) word2id(self,word),words,'uniform',false);
            ids = self.words2id(words);
            ind = 1:length(words);
            sparse_matrix = sparse(ind(ids>0),ids(ids>0),1,length(words),self.dim);
        end
        
        function sparse_vector=sentence_embedding(self,sentence)
            ids = self.sentence2ids(sentence);
            sparse_vector = sparse(ones(length(ids),1),ids,ones(length(ids),1),1,self.dim);     
        end
        function sparse_matrix=sentences_embedding(self,sentences)
            %matrix = zeros(length(sentences),self.dim);
            matrix = [];
            for i=1:length(sentences)
                if isempty(sentences{i})
                    continue
                end
                ids = self.sentence2ids(sentences{i});%self.sentence_embedding(sentences{i});
                matrix = [matrix ; repmat(i,size(ids')) ids'];
            end
            sparse_matrix=sparse(matrix(matrix(:,2)>0,1),matrix(matrix(:,2)>0,2),1,length(sentences),self.dim);
        end
    end
end