function [tres,tvr] = get_total_memusage()
nodes = matlabpool('size');
res = zeros(nodes+1,1);
vr = zeros(nodes+1,1);
parfor i=1:nodes
    [res(i),vr(i)] = getmemusage;
end
[res(nodes+1),vr(nodes+1)] = getmemusage;
if nargout == 0
    fprintf('VM (%.2fGb,%.2fGb)\n',sum(res)/1e6,sum(vr)/1e6);
else
    tres = sum(res);
    tvr = sum(vr);
end