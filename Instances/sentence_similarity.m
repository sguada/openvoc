function sim=sentence_similarity(sent1,sent2,type)
if nargin < 3 
    type = 'mean';
end
    
if isempty(sent1) || isempty(sent2)
    sim = 0;
    return
end
words1 = tokenize(sent1,true,false);
words2 = tokenize(sent2,true,false);

index = Index_Map([words1,words2]);

ind1 = cell2mat(index.values(words1));
ind2 = cell2mat(index.values(words2));

sp_ind1 = sparse(1,ind1,1,1,double(index.Count));
sp_ind2 = sparse(1,ind2,1,1,double(index.Count));
sim.jaccard = length(intersect(ind1,ind2))/length(union(ind1,ind2));
sim.cosine = (sp_ind1*sp_ind2')/norm(sp_ind1)/norm(sp_ind2);
sim.dice = 2*length(intersect(ind1,ind2))/(length(ind1)+length(ind2));
sim.edit = max(0,1-strdist(sent1,sent2,1,0)/mean([length(sent1),length(sent2)]));
sim.mean = mean([sim.jaccard,sim.cosine,sim.dice,sim.edit]);
switch type
    case {'jac','jaccard'}
        sim = sim.jaccard;
    case {'cos','cosine'}
        sim = sim.cosine;
    case {'dice'}
        sim = sim.dice;
    case {'edit'}
        sim = sim.edit;
    case {'mean'}
        sim = sim.mean;
end
