function res=cell2matcell(tuples)
size_tuples = cellfun(@(x) size(x),tuples,'uniform',false);
if size(tuples,1) == 1,
    % Row cell
    max_size_tuple = max(unique(cell2mat(size_tuples'),'rows'),[],1);
    res = cell(max_size_tuple(1),size(tuples,2));
    for i=1:max_size_tuple(1)
        res(i,:) = cellfun(@(x) content_at(x,i),tuples,'uniform',false);
    end
end
if size(tuples,2) == 1,
    % Column cell
    max_size_tuple = max(unique(cell2mat(size_tuples),'rows'),[],1);
    res = cell(size(tuples,1),max_size_tuple(2));
    for j=1:max_size_tuple(2)
        res(:,j) = cellfun(@(x) content_at(x,j),tuples,'uniform',false);
    end
end
end

function res=content_at(tuple,pos)
if length(tuple) < pos
    res = {};
else
    res = tuple{pos};
end
end

