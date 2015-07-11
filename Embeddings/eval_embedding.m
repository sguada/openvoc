function results=eval_embedding(query, class_probs, embedding)

if ~exist('embedding','var') || isempty(embedding)
    % embedding = 'Raw_Embedding';
    embedding = 'Synset_Embedding';
end

all_embeddings = load(['Embeddings/' embedding '_all_embeddings.mat']);
all_embeddings = all_embeddings.all_embeddings;
types = fieldnames(all_embeddings);
type = types{1};

embedder = Text_Embedding.instance(embedding);
text_embedding = embedder.sentences_embedding({query});

results = eval_embedding_kernel(text_embedding, all_embeddings.(type), class_probs);


function kernel = eval_embedding_kernel(text_embedding, all_embeddings, class_probs)

% kernel = slmetric_pw(text_embedding',all_embeddings'*class_probs','nrmcorr')
kernel = slmetric_pw(text_embedding',all_embeddings','nrmcorr')*class_probs';

