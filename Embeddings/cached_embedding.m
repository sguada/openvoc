function embedding=cached_embedding(embedder,method,name,sentences,recompute)
if ~exist('recompute','var')
    recompute = false;
end
    filename = ['temp/' class(embedder) '_' name '.mat'];
    if exist(filename,'file') && ~recompute
        load(filename,'embedding');
    else
        embedding = embedder.(method)(sentences);
        save(filename,'embedding');
    end
end