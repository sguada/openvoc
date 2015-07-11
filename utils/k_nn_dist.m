function [bsf_loc,bsf] = k_nn_dist(codebook,query,k)
if nargin < 3
    k= 1;
end
[bsf_loc,bsf] = yael_nn(codebook,query,k);
% dist = slmetric_pw(codebook,query,'sqdist');
% [dist,order] = sort(dist,'ascend');
% bsf_loc = order(1:k,:);
% bsf = dist(1:k,:);
