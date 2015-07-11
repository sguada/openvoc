function eval_Sim353_embeddings(test_distances)
if nargin < 1
    test_distances = false;
end
self = Word_Embedding.instance('senna_wordreps.mat');
res = read_similarity();

sim_We = zeros(length(res.word1),1);
for i=1:length(res.word1)
    sim_We(i) = self.words_similarity(res.word1{i},res.word2{i});    
end
disp(['Correlations using ' self.distance])
corr([res.sim sim_We],'type','spearman')

if test_distances
    distances = {'eucdist','sqdist','dotprod','corrdist','cityblk','maxdiff',...
        'mindiff','hamming','intersectdis','chisq','kldiv','jeffrey'};
    sim_We_all = zeros(length(res.word1),length(distances));
    for d = 1:length(distances)
        distances{d}
        self.distance = distances{d};
        for i=1:length(res.word1)
            sim_We_all(i,d) = self.words_similarity(res.word1{i},res.word2{i}); 
        end
    end
    disp('Correlations using all prototypes min as agg')
    aux = corr([res.sim sim_We_all],'type','spearman');
    aux(1,:)
end