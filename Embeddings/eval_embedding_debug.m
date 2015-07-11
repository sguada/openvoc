function [results,results2]=eval_embedding_debug(embedding,eval_file)
if nargin < 1
    embedding = 'Raw_Embedding';
end
if nargin < 2
    eval_file = 'evaluation_10.txt';
end
disp('Loading Embedder')
switch embedding
    case 'Raw_Embedding'
        embedder = Raw_Embedding.instance();
    case {'Raw_Synsets'}
        embedder = Raw_Embedding.instance('spelling/synsets_gloss_vocab.txt');
    case 'RNN_Embedding'
        embedder = RNN_Embedding.instance();
    case 'Sparse_Embedding'
        embedder = Sparse_Embedding.instance();
end

all_embeddings = load(['Embeddings/' embedding '_all_embeddings.mat']);
all_embeddings = all_embeddings.all_embeddings;

eval_set = read_cell(eval_file);
eval_set = regexp(strtrim(eval_set),' ','split');

results = struct();
results2 = struct();
types = fieldnames(all_embeddings);
types = types(1:3);

disp('Loading Class_probs')
class_probs = get_eval_set_class_probs(eval_file);
disp('Loading Queries')
map_target_answers = get_query_answers('data/spe');
text_embedding = get_text_embedding(eval_set,embedder,map_target_answers);
disp('Expanding queries')
map_target_answers = get_query_answers('data/freebase');
text_embedding_ext = get_text_embedding(eval_set,embedder,map_target_answers);
disp('Computing results')
ppm = ParforProgressStarter2('test', length(types), 0.1);
for t =1:length(types)
    type = types{t};
    current_embedding = all_embeddings.(type);
    result1 = struct();
    result2 = struct();
    n_test = length(text_embedding);
    
    for i=1:n_test
        kernel1 = slmetric_pw(text_embedding{i}',current_embedding','nrmcorr')*class_probs{i}';
        kernel2 = slmetric_pw(text_embedding{i}',current_embedding'*class_probs{i}','nrmcorr');
        [rank,random_choice]= eval_kernel(kernel1);
        result1(i).rank = rank;
        result1(i).random_choice = random_choice;
        result1(i).embedded = full(any(text_embedding{i},2));
        [rank,random_choice]= eval_kernel(kernel2);
        result2(i).rank = rank;
        result2(i).random_choice = random_choice;
        result2(i).embedded = full(any(text_embedding{i},2));
    end
    results.(type) = result1;
    results2.(type) = result2;
    ppm.increment(t);
end


end

function [result1,result2] = eval_type_embedding(text_embedding,all_embeddings,class_probs)
result1 = struct();
result2 = struct();
n_test = length(text_embedding);

for i=1:n_test
    kernel1 = slmetric_pw(text_embedding{i}',all_embeddings','nrmcorr')*class_probs{i}';
    kernel2 = slmetric_pw(text_embedding{i}',all_embeddings'*class_probs{i}','nrmcorr');
    [rank,random_choice]= eval_kernel(kernel1);    
    result1(i).rank = rank;
    result1(i).random_choice = random_choice;
    result1(i).embedded = full(any(text_embedding{i},2));
    [rank,random_choice]= eval_kernel(kernel2);    
    result2(i).rank = rank;
    result2(i).random_choice = random_choice;
    result2(i).embedded = full(any(text_embedding{i},2));    
end
end

function text_embedding = get_text_embedding(eval_set,embedder,map_target_answers)
n_test = size(eval_set,1);

text_embedding = cell(n_test,1);
parfor i=1:n_test
    test_target = eval_set{i}{1};
    test_answers = lower(map_target_answers(test_target));    
    text_embedding{i} = embedder.sentences_embedding(test_answers);
end
end