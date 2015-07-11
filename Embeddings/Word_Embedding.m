classdef Word_Embedding < Text_Embedding
    properties
        We
        vocab
        pooling = 'max'
    end
    properties (Hidden)
        dim
        n_vocab
        filename
        join_dim
    end
    methods (Access=private)
        function self = Word_Embedding(varargin)
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
            self.join_dim = size(self.sentence_embedding('this is a test',true),2);
        end
    end
    methods (Static)
        function obj = instance(varargin)
            persistent self
            if  isempty(self)
                self = Word_Embedding(varargin{:});
            else
                if ~isempty(varargin)
                    if ~strcmp(self.filename,varargin)
                        self = Word_Embedding(varargin{:});
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
            if nargin < 4, k = 1000; end
            words = self.split_sentence(sentence);
            ids = words2id(self,words);   
            ind = ids> 0;
            dist = slmetric_pw(self.We(:,ids(ind)),self.We,metric);
            [sims,ord] = sort(dist,2,'descend');
            exp_ids = ord(:,1:k);
            exp_sim = [sims(:,1) sims(:,2:k)/2];        
            rows = repmat((1:sum(ind))',1,k);
            sparse_vector = max(sparse(rows(:),exp_ids(:),exp_sim(:),sum(ind),self.n_vocab),[],1);            
        end
        
        function sim=sentences_similarity(self,word1,word2)
           sim = slmetric_pw(self.expand_query(word1)',self.expand_query(word2)','nrmcorr');
        end

    end
    methods
        function vector = word_embedding(self,word)
            assert(ischar(word),'Word should be a string');
            if ~isempty(regexp(word,'\s+','once')) || ~isempty(regexp(word,'\w-\w','once'))
                % Multi-word with spaces or - separated words
                wordsid = self.sentence2ids(word);
                vector = self.We(:,wordsid(end))';
            else
                vector = self.We(:,self.word2id(word))';
            end
        end
        
        function matrix = words_embedding(self,words,display)
            if nargin < 3, display = false; end
            assert(iscell(words),'Words should be cell of words');
            matrix = zeros(length(words),self.dim);
            for l=1:length(words)
                if display, disp(words{l}); end
                matrix(l,:) = self.word_embedding(words{l});
            end
        end
        
        function join_vector = sentence_embedding(self,sentence,display)
            if nargin < 3, display = false; end
            if isempty(sentence)
                join_vector = zeros(1,self.join_dim);
            else
                assert(ischar(sentence),'sentence should be a string');
                sentence_ids = self.sentence2ids(sentence,display);
                vectors = self.We(:,sentence_ids)';
                join_vector = self.join_pool(vectors);
            end
        end
        
        function  join_matrix = sentences_embedding(self,sentences,display)
            if nargin < 3, display = false; end
            join_matrix = zeros(length(sentences),self.join_dim);
            parfor l = 1:length(sentences)
                if display, disp(sentences{l}); end
                join_matrix(l,:) = self.sentence_embedding(sentences{l});
            end
        end
        
    end
    methods %(Hidden)
        function join_vector = join_pool(self,vector)
            switch self.pooling
                case 'all'
                    join_vector = [mean(vector,1) max(vector,[],1) min(vector,[],1)];
                case 'max'
                    join_vector = max(vector,[],1);
                case 'mean'
                    join_vector = mean(vector,1);
            end
        end
                      
    end
end
