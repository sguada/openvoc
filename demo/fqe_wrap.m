function map_query_freebase=fqe_wrap(im_name,query,recompute)
if nargin < 1
    im_name = 'crops/crop_3.png';
end
if nargin < 2
    query = 'Pasta box';
end

base_dir = '/home/sguada/Projects/openvoc/fqe';
test_file = fullfile(base_dir,'test.sh');
fid = fopen(test_file,'w');
command_str = sprintf('python %s/freebase-extend-descriptions.py --src %s-src.json --dst %s-dst.json',...
    base_dir,im_name,im_name);
savejson(im_name,query,sprintf('%s/%s-src.json',base_dir,im_name))
[status,result] = system(command_str);
if status == 0
    jsondata = loadjson(result);
    target = regexprep(fieldnames(jsondata),'_0x2E_','.');
    answer = struct2cell(jsondata);
else
    display(result)
    error('fqe-expansion')
end

map_query_freebase = containers.Map(target,answer);
