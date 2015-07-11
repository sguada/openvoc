classdef Text_Embedding
    properties
        distance = 'nrmcorr'
        mapping % It should contains a mapping from words to id
    end 
    methods(Abstract = true)
        vector=word_embedding(self,word)
        matrix=words_embedding(self,words)
        vector=sentence_embedding(self,sentence)
        matrix=sentences_embedding(self,sentences)
    end
    methods (Static)
        function obj = instance(type)
            if nargin < 1
                type = 'Raw_Embedding';
            end
            switch type
                case 'Raw_Embedding'
                    obj = Raw_Embedding.instance();
                case 'Raw_Synsets'
                    obj = Raw_Embedding.instance('spelling/synsets_gloss_vocab.txt');
                case 'Raw_Brown'
                    obj = Raw_Embedding.instance('spelling/brown_vocab.txt');
                case 'RNN_Embedding'
                    obj = RNN_Embedding.instance();
                case 'Sparse_Embedding'
                    obj = Sparse_Embedding.instance();
                case 'Synset_Embedding'
                    obj = Synset_Embedding.instance();
                otherwise
                    error(['Embedding ' type ' is not defined yet']);
            end          
        end
    end
    methods
        function matrix = text_embedding(self,text)
            fileLines = textscan(text,'%s', 'delimiter', '\n', 'bufsize', 100000);
            fileLines = fileLines{1};
            matrix = self.sentences_embedding(fileLines);
        end
        function matrix = file_embedding(self,filename)
            fileLines = textscan(fopen(filename),'%s', 'delimiter', '\n', 'bufsize', 100000);
            fileLines = fileLines{1};
            matrix = self.sentences_embedding(fileLines);
        end
        function sim=words_similarity(self,word1,word2)
            sim = full(slmetric_pw(self.word_embedding(word1)',self.word_embedding(word2)',self.distance));
        end
        function sim=sentences_similarity(self,sentence1,sentence2)
            sim = full(slmetric_pw(self.sentence_embedding(sentence1)',self.sentence_embedding(sentence2)',self.distance));
        end
        function sim=word_sentence_similarity(self,word,sentence)
            sim = full(slmetric_pw(self.word_embedding(word)',self.sentence_embedding(sentence)',self.distance));
        end
        function sims=cross_word_similarity(self,word_list)
            sims = zeros(length(word_list));
            for i=1:length(word_list)
                for j=i:length(word_list)
                    sims(i,j) = self.words_similarity(word_list{i},word_list{j});
                end
            end
        end
        function sims=cross_sentences_similarity(self,sentence_list)
            sims = zeros(length(sentence_list));
            for i=1:length(sentence_list)
                for j=i:length(sentence_list)
                    sims(i,j) = self.sentences_similarity(sentence_list{i},sentence_list{j});
                end
            end
        end
    end
    methods %(Access=private)
        function ids = word2id(self,word)
            % Get the id number of a word from the vocab list
            word = lower(word);
            ids = self.mapping.values({word});
            ids = cell2mat(ids);
            if ids ==0                
                % Try as a sentence
                wordsid = self.sentence2ids(word);
                ids = wordsid(end);
            end
        end
        function ids=words2id(self,words)
            words = lower(words);
            iskey = self.mapping.isKey(words);
            ids = zeros(size(words));
            vals = self.mapping.values(words(iskey));
            if iscell(vals)
                ids(iskey) = cell2mat(vals);
            else
                ids(iskey) = vals;
            end
        end
        
        function sentence_ids = sentence2ids(self,sentence,display)
            if nargin < 3, display = false; end
            words = tokenize(sentence);
            sentence_ids = words2id(self,words);%cellfun(@(word) word2id(self,word),words);
            if display
                cellfun(@(word,id) fprintf('%s -> %d\n',word,id),words,(num2cell(sentence_ids)))
            end
        end
        
        
    end
end