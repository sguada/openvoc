function res=extract_field_giss(map_crops_giss,crops_names,field)
res = cell(numel(crops_names),1);
for i=1:length(crops_names)
    if map_crops_giss.isKey(crops_names{i})
        crop_giss = map_crops_giss(crops_names{i});
        res{i} = crop_giss.(field);
        if isempty(res{i})
            res{i} = '';
        end
    end
end