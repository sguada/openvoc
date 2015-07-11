function perms = create_perm(number,size_k,max_n)
% Creates
perms = zeros(number,size_k);
for i=1:number
    perms(i,:) = randperm(max_n,size_k);
end