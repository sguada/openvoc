function [bsf_loc,bsf] = k_nn(codebook,query,recompute,k)
persistent pivots
persistent distances
persistent codepivots

if nargin < 3
    recompute = false;
end
if nargin < 4
    k= 1;
end

npivots = 10;
if isempty(pivots) || recompute
    pivots = randi(size(codebook,2),1,npivots);
    codepivots = codebook(:,pivots);
    distances = slmetric_pw(codebook,codepivots,'eucdist');
end

dist_topivots = slmetric_pw(query,codepivots,'eucdist');
[bsf,ind] = min(dist_topivots,[],2);
bsf_loc = pivots(ind);
counter = 0;
for j=1:size(query,2)
    aux_dist_topivots = abs(bsxfun(@minus,distances,dist_topivots(j,:)));
    
    [aux,order] = sort(max(aux_dist_topivots,[],2),'ascend');

    for loc=1:size(aux,1)
        if aux(loc) < bsf(j)
            dist = eucdist_ea(query(:,j),codebook(:,order(loc)),bsf(j));
            counter = counter + 1;
            if dist < bsf(j)
                bsf(j) = dist;
                bsf_loc(j) = order(loc);
            end
        else
            break
        end
    end
end
fprintf('Counter: %d\n',counter);
