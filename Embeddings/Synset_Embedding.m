classdef Synset_Embedding < Text_Embedding
    properties
        vocab        
        dim
    end
    properties (Hidden)
        cutoff % Defines a cuttoff point
    end
    methods % (Access=private)
        function self = Synset_Embedding()
            if ~exist('synset_mapping.mat','file')
                mapping = self.create_mapping();
                save('Embeddings/synset_mapping','mapping');
            else
                load('Embeddings/synset_mapping','mapping');                
            end
            self.mapping = mapping;            
            self.dim = max(cell2mat(mapping.values));
        end
    end    
    methods (Static)
        function obj = instance()
            persistent self
            if  isempty(self), self = Synset_Embedding(); end
            obj = self;
        end
        function mapping = create_mapping(filename)
            if nargin < 1
                filename = 'meta10K.mat';
            end
            synsets = load(filename,'synsets');
            synsets = synsets.synsets;
            all_synsets = lower({synsets.words}');
            cell_synsets = regexp(all_synsets,'\, ','split');
            mat_synsets = cell2matcell(cell_synsets);
            mapping = Multi_Map(mat_synsets(:,1));
            for col=2:size(mat_synsets,2)
                mapping = mapping.append(Multi_Map(mat_synsets(:,col)));
            end            
        end
    end
    
    methods
        
        function sparse_vector=word_embedding(self,word)
            % If the word.lowercase belongs to vocab then it returns 1 at its
            % position otherwise returns 1 at the first position
            word = lower(word);
            sparse_vector = sparse(1,self.word2id(word),1,1,self.dim);
        end
        
        function sparse_matrix=words_embedding(self,words)
            ids = self.words2id(words);
            matrix = zeros(length(ids),self.dim);
            for i=1:length(ids)
                matrix(i,ids{i}) = 1;
            end
            sparse_matrix = sparse(matrix);
        end
        
        function sparse_vector=sentence_embedding(self,sentence)
            sentence = lower(sentence);
            ids = self.sentence2ids(sentence);
            sparse_vector = sparse(ones(length(ids),1),ids,ones(length(ids),1),1,self.dim);
        end
        function sparse_matrix=sentences_embedding(self,sentences)            
            matrix = zeros(length(sentences),self.dim);
            parfor i=1:length(sentences)
                matrix(i,:) = self.sentence_embedding(sentences{i});      
            end
            sparse_matrix = sparse(matrix);
        end
    end
    methods         
        function ids = word2id(self,word)
            ids = self.mapping.values({word});
            ids = cell2mat(ids);
        end
        function ids=words2id(self,words)
            ids = self.mapping.values(words);
        end
        function sentence_ids = sentence2ids(self,sentence,display)
            if isempty(sentence)
                sentence_ids = [];
                return
            end
            if nargin < 3, display = false; end
            % Lower case of sentence
            sentence = lower(sentence);
            % Separate ,.";()[]?! from words
            sentence = regexprep(sentence,'[\.,;:@#$%&"\(\)\[\]?!{}<>]',' ');
            % Remove extra spaces
            sentence = regexprep(sentence,'\s+',' ');
            % Remove spaces at the begining or end
            sentence = strtrim(sentence);
            % Split it words
            words = regexp(sentence,'\s+','split');
            ids = self.words2id(words);
            if display
                cellfun(@(word,id) fprintf('%s -> %d\n',word,id),words,ids)
            end
            pairs =  cellfun(@(word1,word2) [word1 ' ' word2],...
                words(1:end-1),words(2:end),'uniform',false);            
            pairs_ids = self.words2id(pairs);
            sentence_ids = [cell2mat(ids) cell2mat(pairs_ids)];
        end
    end
end