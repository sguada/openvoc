function pairs=form_pairs(words)
% Given a array of cell of words forms all the consecutive pairs
assert(iscell(words))
pairs = cell(size(words,1),1);
for i=1:size(words,1)
    pairs{i} =  cellfun(@(word1,word2) [word1 ' ' word2],...
        words{i}(1:end-1),words{i}(2:end),'uniform',false);
end