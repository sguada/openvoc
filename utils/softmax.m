function mu = softmax(eta)
exp_eta = exp(eta);
mu = bsxfun(@rdivide,exp_eta,sum(exp_eta));
