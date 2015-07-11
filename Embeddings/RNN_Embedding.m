classdef RNN_Embedding < Text_Embedding
    properties
        oWe
        We
        centers
        orig2cent
        vocab
        tfidf
    end
    properties (Hidden)
        padding = 5
        dim = 50
        cutoff = 5000
        join_dim
        sPad
        ePad
    end
    methods (Access=private)
        function self = RNN_Embedding()
            aux = load('wordreps.mat','We');
            self.We = aux.We;
            aux = load('vocab.mat','vocab','tfidf','numEmbeddings');
            self.vocab = aux.vocab;
            self.tfidf = aux.tfidf;
            aux = load('wordreps_orig.mat','oWe');
            self.oWe = aux.oWe;
            aux = load('centers.mat','centers','orig2cent');
            self.centers = aux.centers;
            self.orig2cent = aux.orig2cent;
            self.sPad = find(strcmp('<s>',self.vocab));
            self.ePad = find(strcmp('</s>',self.vocab));
            self.mapping = Index_Map(self.vocab);
            if isempty(self.cutoff)
                self.cutoff = length(self.vocab); % Not cutoff
            end
            self.join_dim = size(self.sentence_embedding('this is a test'),2);
        end
    end
    methods (Static)
        function obj = instance()
            persistent self
            if  isempty(self), self = RNN_Embedding(); end
            obj = self;           
        end
    end
    methods %(Hidden)
        function sim = similarity_oWe(self,word1,word2)
            %  similarity_oWe(word1,word2)
            vect1 = self.oWe(:,self.word2id(word1));
            vect2 = self.oWe(:,self.word2id(word2));
            sim = slmetric_pw(vect1,vect2,'nrmcorr');
        end
        function sim = similarity_We1(self,word1,word2)
            vect1 = self.We(:,self.word2id(word1),1);
            vect2 = self.We(:,self.word2id(word2),1);
            sim = slmetric_pw(vect1,vect2,'nrmcorr');
        end
        function sim = similarity_We_all(self,word1,word2,agg,distance)
            if nargin < 4, agg = 'mean'; end
            if nargin < 5, distance = 'corrdist'; end
            if ischar('min')
                switch agg
                    case 'min', agg = @(x,dim) min(x,[],dim);
                    case 'mean', agg = @(x,dim) mean(x,dim);
                    otherwise, error('agg should be: min or mean')
                end
            end
            id_word = self.word2id(word1);
            if self.orig2cent(id_word) > 0
                %Word with multiple meanings compute similar words to all
                %of them
                vectors1 = squeeze(self.We(:,id_word,:));
            else
                vectors1 = self.We(:,id_word,1);
            end
            id_word = self.word2id(word2);
            if self.orig2cent(id_word) > 0
                %Word with multiple meanings compute similar words to all
                %of them
                vectors2 = squeeze(self.We(:,id_word,:));
            else
                vectors2 = self.We(:,id_word,1);
            end
            % First compute similarity for every prototype
            sim = 1-slmetric_pw(vectors1,vectors2,distance);
            sim = mean(agg(sim,2));            
        end
               
        function [res,sim] = similarwords_oWe(self,word,k)
            if nargin < 3, k = 8; end
            id_word = self.word2id(word);
            vector = self.oWe(:,id_word);
            sim = slmetric_pw(vector,self.oWe(:,1:self.cutoff),'corrdist');
            [~,ord] = sort(sim,2,'ascend');
            res = self.vocab(ord(:,1:k));
            sim = 1-sim(ord(:,1:k));
        end
        function [res, sim] = similarwords_We1(self,word,prototype,k)
            if nargin < 3, prototype = 1; end
            if nargin < 4, k = 8; end
            id_word = self.word2id(word);
            vector = self.We(:,id_word,prototype);
            sim = slmetric_pw(vector,squeeze(self.We(:,1:self.cutoff,1)),'corrdist');
            [~,ord] = sort(sim,2,'ascend');
            res = self.vocab(ord(:,1:k));
            sim = 1-sim(:,ord(:,1:k));
        end
        function [res,all_sim] = similarwords_We_all(self,word,agg,prototypes,k)
            if nargin < 3, agg = 'min'; end
            if nargin < 4, prototypes = 1:10; end
            if nargin < 5, k = 8; end
            switch agg
                case 'min', agg = @(x,dim) min(x,[],dim);
                case 'mean', agg = @(x,dim) mean(x,dim);
                otherwise, error('agg should be: min or mean')
            end
            id_word = self.word2id(word);
            if self.orig2cent(id_word) > 0
                %Word with multiple meanings compute similar words to all
                %of them
                vectors = squeeze(self.We(:,id_word,prototypes));
            else
                vectors = self.We(:,id_word,1);
            end
            % First compute the average similarity to the first meaning
            sim1 = slmetric_pw(vectors,reshape(self.We(:,1:self.cutoff,1),self.dim,[]),'corrdist');
            % Now compute the similarity to words with multiple meanings
            multmeaning = self.orig2cent(1:self.cutoff)>0;
            sim2 = slmetric_pw(vectors,reshape(self.We(:,multmeaning,:),self.dim,[]),'corrdist');
            sim2 = reshape(sim2,size(vectors,2),sum(multmeaning),[]);
            sim2 = agg(sim2,3);
            sim = sim1;
            sim(:,multmeaning) = sim2;
            [best_sim,ord] = sort(sim,2,'ascend');
            res = self.vocab(ord(:,1:k));
            best_sim = 1 - best_sim(:,1:k);
            global_sim = mean(sim,1);
            [best_global,ord] = sort(global_sim,2,'ascend');
            best_global = 1-best_global(1:k);
            res = [self.vocab(ord(1:k)); res];
            all_sim = [best_global; best_sim];
        end
    end
    methods
        function vector = word_embedding(self,word)
            assert(ischar(word),'Word should be a string');
            if ~isempty(regexp(word,'\s+','once')) || ~isempty(regexp(word,'\w-\w','once'))
                % Multi-word with spaces or - separated words
                wordsid = self.sentence2ids(word); 
                vector = self.oWe(:,wordsid(end),1);
            else
                vector = self.oWe(:,self.word2id(word),1)';
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
                vectors = self.sentence_ids_embedding(sentence_ids);
                %disp(vectors)
                %join_vector = self.tf_pool(aux,sentence_ids);
                join_vector = self.join_pool(vectors,sentence_ids);
                %join_vector = [self.tf_pool(aux,ids),self.join_pool(aux)];
            end
        end
        
        function  join_matrix = sentences_embedding(self,sentences,display)
            if nargin < 3, display = false; end
            join_matrix = zeros(length(sentences),self.join_dim);
            for l = 1:length(sentences)
                if display, disp(sentences{l}); end
                join_matrix(l,:) = self.sentence_embedding(sentences{l});
            end
        end
        
    end
    methods (Hidden)
        function join_vector = join_pool(self,vector,ids)
            join_vector = [mean(vector,1) max(vector,[],1) min(vector,[],1) self.tf_pool(vector,ids)];
        end
        function join_vector = tf_pool(self,vector,ids)
            tf = self.tfidf(ids);
            tf = bsxfun(@rdivide,tf,sum(tf));
            join_vector = sum(bsxfun(@times,vector,tf'),1);
        end
        
        function id = word2id(self,word)
            % Get the id number of a word from the vocab list
            word = lower(word);
            id = find(strcmp(word,self.vocab));
            if isempty(id)
                if  ~isempty(regexp(word,'^[-+]?[0-9]*\.?[0-9]+', 'once'))
                    id = find(strcmp(regexprep(word,'[0-9]','DG'),self.vocab));
                    if isempty(id)
                        id = find(strcmp('NNNUMMM',self.vocab));
                    end
                end
                if isempty(id)
                    id = 1;
                end
            end
        end
        function sentence_ids = sentence2ids(self,sentence,display)
            if nargin < 3, display = false; end
            % Lower case of sentence
            sentence = lower(sentence);
            % Separate ,.";()[]?! from words
            sentence = regexprep(sentence,'[\.,;:@#$%&"\(\)\[\]?!{}<>-]',' $0 ');
            % Separate cannot to can not
            sentence = regexprep(sentence,'cannot', 'can not');
            % Fix can't to can not
            sentence = regexprep(sentence,'can''t', 'can not');
            % Separate 'somthing from word'something
            sentence = regexprep(sentence,'''\w+', ' $0');
            % Join fix don 't to do n't
            sentence = regexprep(sentence,'n ''t', ' n''t');
            % Remove extra spaces
            sentence = regexprep(sentence,'\s+',' ');
            % Remove spaces at the begining or end
            sentence = strtrim(sentence);
            % Lower sentence and split it words
            words = regexp(sentence,'\s+','split');
            ids = cellfun(@(word) word2id(self,word),words);
            if display
                cellfun(@(word,id) fprintf('%s -> %d\n',word,id),words,(num2cell(ids)))
            end
            %ids
            ids(ids>self.cutoff) = 1;
            sentence_ids = ids;
        end
        
        function [vector,pros] = sentence_ids_embedding(self,sentence_ids)
            % Padding the sentence with start and end sentence marks
            sentence_ids = [repmat(self.sPad,1,self.padding) sentence_ids repmat(self.ePad,1,self.padding)];
            pros = ones(1,length(sentence_ids)); % prototype numbers
            vector = zeros(length(sentence_ids)-self.padding*2,self.dim);
            dsz = length(self.vocab);
            for i = self.padding+1:length(sentence_ids)-self.padding
                if self.orig2cent(sentence_ids(i)) == 0
                    pros(i) = 1;
                else
                    c = squeeze(self.centers(:,self.orig2cent(sentence_ids(i)),:));
                    % compute the context representation, which is a tf-idf weighted average
                    % of the representations of the context words within a 10-word window
                    contexts = sentence_ids([i-self.padding:i-1 i+1:i+self.padding])';
                    unigrams = contexts;
                    tf = sparse(unigrams(:),ones(size(unigrams(:))),self.tfidf(unigrams(:)),dsz,size(unigrams,2));
                    tf = bsxfun(@rdivide,tf,sum(tf));
                    
                    contexts = self.oWe * tf;
                    
                    % find cluster by choosing the cluster center rep. that's closest to the
                    % context rep. we use cosine distance here.
                    dist = slmetric_pw(contexts,c,'corrdist');
                    [~,cluster] = min(dist,[],2);
                    pros(i) = cluster;
                end
                vector(i-self.padding,:) = self.We(:,sentence_ids(i),pros(i));
            end
        end
    end
end
