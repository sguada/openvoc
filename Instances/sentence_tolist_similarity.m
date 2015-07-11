function sim=sentence_tolist_similarity(sent1,list,varargin)
sim = zeros(length(list),1);
for i=1:length(list)
    if isempty(list{i})
        continue;
    end
    sim(i) = sentence_similarity(sent1,list{i},varargin{:});
end