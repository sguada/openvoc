function map_query_freebase=fqe_wrap(im_name,query)
if nargin < 1
    im_name = 'crops/crop_3.png';
end
if nargin < 2
    query = 'Pasta box';
end

current_dir = pwd;
base_dir = '/home/sguada/Projects/openvoc/fqe';
savejson(im_name,query,sprintf('%s/%s-src.json',base_dir,im_name));
command_str = ...
	sprintf('python freebase-extend-descriptions.py --src %s-src.json --dst %s-dst.json',...
    im_name,im_name);
cd(base_dir)
[status,result] = system(command_str);
cd(current_dir)
if status == 0
    jsondata = loadjson(sprintf('%s/%s-dst.json',base_dir,im_name));
    target = regexprep(fieldnames(jsondata),'_0x2E_','.');
    answer = struct2cell(jsondata);
else
    display(result)
    error('fqe-expansion')
end
map_query_freebase = Default_Map('',target,answer);
