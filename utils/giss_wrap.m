function map_images_giss=giss_wrap(crops_names,crops_dir, overwrite)
if nargin < 1
    crops_names{1} = 'openvoc/crops/crop_3.png';
end
if nargin < 2
    crops_dir = 'crops';
end

if nargin < 3
    overwrite = 1;
end

web_dir = 'http://www.icsi.berkeley.edu/~sguada/openvoc/';
base_dir = '/home/sguada/Projects/openvoc/giss';
test_file = fullfile(base_dir,'test.sh');
fid = fopen(test_file,'w');
command_str = sprintf('%s/gis-scrape.py --useragents %s/useragents.txt',...
    base_dir,base_dir);
targets = {};
answers = {};
for i=1:length(crops_names)
    web_name = fullfile(web_dir,crops_dir,crops_names{i});
    cached_giss = fullfile('temp',[crops_names{i} '_gis.mat']);
    if exist(cached_giss,'file') && ~overwrite
        load(cached_giss,'target','answer');
    else
        [status,result] = system(sprintf('%s %s',command_str,web_name));
        if status == 0
            jsondata = loadjson(result);
            target = regexprep(fieldnames(jsondata),'_0x2E_','.');
            answer = struct2cell(jsondata);
            save(cached_giss,'target','answer');
        else
            display(result)
            error('gis-scrape')
        end
    end
    targets = cat(1,targets,target);
    answers = cat(1,answers,answer);
    %command_str = sprintf('%s %s ',command_str,web_name);
end
% fclose(fid);
% [status,result]=system(command_str);
% if status~=0
%     display(result)
%     error('gis-scrape')
% end

map_images_giss = containers.Map(targets,answers);
