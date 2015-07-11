function filter=exist_files(list_files)
filter = false(1,length(list_files));
for i=1:length(list_files)
    filter(i) = exist(list_files{i},'file');
end
end