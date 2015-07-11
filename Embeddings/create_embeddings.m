function [all_embeddings,all_text]=create_embeddings(method,recompute)
%% Creates the emedings for all wordnet synsets in imagenet
% if recompute is true, it will recompute all the embeddings and save them
% to disk
if ~exist('method','var') || isempty(method)
    method = 'Raw_Embedding';
end
if ~exist('recompute','var') || isempty(recompute)
    recompute = false;
end

if ~exist([method '_all_embeddings.mat'],'file') || recompute
    embedder = Text_Embedding.instance(method);   
    %% Extract words, definitions and examples from synsets
    load('meta10K.mat')
    WNID = {synsets.WNID}';    
    all_synsets = lower({synsets.words}');    
    cell_synsets = regexp(all_synsets,'\, ','split');
    first_synset = cellfun(@(x) x{1},cell_synsets,'UniformOutput',false);
    label = cellfun(@(x) x{end},regexp(first_synset,' ','split'),'uniform',false);
    syn_gloss = lower({synsets.gloss}');
    syntext =  cellfun(@(a,b,c) [a ': (' b ') -> ' c],WNID,all_synsets,syn_gloss,'uni',false);
    sentences = regexp(syn_gloss,'(\; \"|\"\; \"|\")','split');
    definitions = cellfun(@(x) x{1},sentences,'UniformOutput',false);
    words_def = cellfun(@(a,b) [a ': ' b],all_synsets,definitions,'uni',false);
    words_gloss = cellfun(@(a,b) [a ': ' b],all_synsets,syn_gloss,'uni',false);
    
    examples = cellfun(@(x) extract_examples(x),sentences,'UniformOutput',false);
    has_examples = cellfun(@(x) ~isempty(x),examples);
    first_example = cell(size(has_examples));
    first_example(has_examples) = cellfun(@(x) x{1},examples(has_examples),'UniformOutput',false);
    %% Compute the text_embedding of the words, definitions    
    
    % Embedding of the label (last word of the first synset) without context
    disp('Embedding of the first word without context')
    matrix_label=cached_embedding(embedder,'words_embedding',[method '_label'],label);
     
    % Embedding of the first synset without context
    disp('Embedding of the first synset without context')
    matrix_first_synset=cached_embedding(embedder,'sentences_embedding',[method 'first_synset'],first_synset);
    
    % Embedding using all the words in synset as context
    disp('Embedding using all the words in synset as context')
    matrix_all_synsets=cached_embedding(embedder,'sentences_embedding',[method 'all_synsets'],all_synsets);
    
    % Embedding of the definitions of the synset
    disp('Embedding of the definitions of the synset')
    matrix_definitions=cached_embedding(embedder,'sentences_embedding',[method 'definitions'],definitions);
    
    % Embedding all the words of the synset and the definition
    disp('Embedding all the words of the synset and the definition')
    matrix_words_def=cached_embedding(embedder,'sentences_embedding',[method 'matrix_words_def'],words_def);
    
    % Embedding of the first example of the synsets, only for synsets with
    % examples
    disp('Embedding of the first example of the synsets')
    matrix_first_example=cached_embedding(embedder,'sentences_embedding',[method 'first_example'],first_example);
    
    % Embedding of all examples of the synsets
    % disp('Embedding of all examples of the synsets')
    % matrix_examples=cached_embedding(embedder,'text_embedding',[method 'examples'],print_cell(examples));
    
    disp('Embedding the synset + gloss')
    matrix_words_gloss=cached_embedding(embedder,'sentences_embedding',[method 'words_gloss'],words_gloss);
    
    %% Group all the embeddings in one variable
    all_text.syntext = syntext;
    all_text.wnid = WNID;
    all_text.words = all_synsets;
    all_text.label = first_synset;
    all_text.defn = definitions;
    all_text.exam = cellfun(@(x) print_cell(x,[],'; '),examples,'uni',false);
    all_text.words_gloss = words_gloss;
    all_embeddings.label = matrix_label;
    all_embeddings.first_word = matrix_first_synset;
    all_embeddings.all_words = matrix_all_synsets;
    all_embeddings.definitions = matrix_definitions;
    all_embeddings.words_definitions = matrix_words_def;
    all_embeddings.first_example  = matrix_first_example;
    % all_embeddings.examples = matrix_examples;
    all_embeddings.words_gloss = matrix_words_gloss;
    disp('Saving all_embeddings')
    save(['Embeddings/' method '_all_embeddings.mat'],'all_embeddings','all_text','-v7.3')
else
    disp('Loading all_embeddings')
    load(['Embeddings/' method '_all_embeddings.mat'],'all_embeddings','all_text')
end
