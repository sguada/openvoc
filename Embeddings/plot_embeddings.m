function plot_embeddings(embeddings,labels)
if nargin < 2
    labels = 1:size(embeddings,1);
end
aux = fast_tsne(embeddings);

plot(aux(:,1),aux(:,2),'.');
text(aux(:,1),aux(:,2),labels);