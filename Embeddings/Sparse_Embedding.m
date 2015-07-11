classdef Sparse_Embedding < Text_Embedding
    properties
        We
        vocab
        pooling = 'max'
        k = 100 % Number of similar words
    end
    properties (Hidden)
        dim
        n_vocab
        filename
        join_dim
    end
    methods (Access=private)
        function self = Sparse_Embedding(varargin)
            if isempty(varargin)
                aux = load('rnn_wordreps.mat');
                self.filename = 'rnn_wordreps.mat';
            else
                aux = load(varargin{1});
                self.filename = varargin{1};
            end
            self.We = aux.We;
            self.dim = size(self.We,1);
            self.vocab = aux.vocab;
            self.n_vocab = length(self.vocab);
            self.mapping = Index_Map(self.vocab);
            self.join_dim = size(self.sentence_embedding('this is a test'),2);
        end
    end
    methods (Static)
        function obj = instance(varargin)
            persistent self
            if  isempty(self)
                self = Sparse_Embedding(varargin{:});
            else
                if ~isempty(varargin)
                    if ~strcmp(self.filename,varargin)
                        self = Sparse_Embedding(varargin{:});
                    end
                end
            end
            obj = self;
        end
    end
    methods %(Hidden)
        
        function [res,dist] = similarwords(self,word,metric,k)
            if nargin < 3, metric = 'corrdist'; end
            if nargin < 4, k = 8; end
            id_word = self.word2id(word);
            if id_word > 0
                vector = self.We(:,id_word);
            else
                vector = zeros(self.dim,1);
            end
            dist = slmetric_pw(vector,self.We,metric);
            [~,ord] = sort(dist,2,'ascend');
            res = self.vocab(ord(:,1:k));
            dist = dist(ord(:,1:k));
        end
        
        function sparse_vector=expand_query(self,sentence,metric,k)
            if nargin < 3, metric = 'nrmcorr'; end
            if nargin < 4, k = self.k; end
            words = self.split_sentence(sentence);
            ids = words2id(self,words);
            ind = ids> 0;
            if any(ind)
                dist = slmetric_pw(self.We(:,ids(ind)),self.We,metric);
                [sims,ord] = sort(dist,2,'descend');
                exp_ids = ord(:,1:k);
                exp_sim = [sims(:,1) sims(:,2:k)/2];
                rows = repmat((1:sum(ind))',1,k);
                sparse_vector = max(sparse(rows(:),exp_ids(:),exp_sim(:),sum(ind),self.n_vocab),[],1);
            else
                sparse_vector = sparse([],[],[],sum(ind),self.n_vocab);
            end
        end
        
        function sim=sentences_similarity(self,word1,word2)
            sim = slmetric_pw(self.expand_query(word1)',self.expand_query(word2)','nrmcorr');
        end
        
    end
    methods
        function sparse_vector = word_embedding(self,word)
            sparse_vector = self.expand_query(word);
        end
        
        function sparse_matrix = words_embedding(self,words)
            assert(iscell(words),'Words should be cell of words');
            matrix = zeros(length(words),self.join_dim);
            ppm = ParforProgressStarter2('test', length(words), 0.1);
            parfor l=1:length(words)
                ppm.increment(l);
                vector = self.word_embedding(words{l});
                if ~isempty(vector)
                    matrix(l,:) = vector;
                end
            end
            sparse_matrix = sparse(matrix);
        end
        
        function sparse_vector = sentence_embedding(self,sentence)
            sparse_vector = self.expand_query(sentence);
        end
        
        function  sparse_matrix = sentences_embedding(self,sentences)
            join_matrix = zeros(length(sentences),self.join_dim);
            parfor l = 1:length(sentences)  
                vector = self.sentence_embedding(sentences{l});
                if ~isempty(vector)
                    join_matrix(l,:) = vector;
                end
            end
            sparse_matrix =  sparse(join_matrix);
        end
        
    end
end
