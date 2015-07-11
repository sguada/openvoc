function fix_json(file)
aux = read_cell(file);
aux = regexprep(aux,'"\.\..+\/(\w+)_(\d+).JPEG"','"$1_$2\.JPEG"');
print_cell(aux,file);
