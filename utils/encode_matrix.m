function encode = encode_matrix(X,perm)
aux = zeros(size(perm));
encode = zeros(size(X,1),size(perm,1));
for i=1:size(X,1)
    aux(:) = X(i,perm);
    [~,max_k] = max(aux,[],2);
    encode(i,:) = max_k;
end