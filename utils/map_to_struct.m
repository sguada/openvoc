function res=map_to_struct(map_crops_giss)
keys = map_crops_giss.keys;
for i=1:length(keys)
    st = map_crops_giss(keys{i});
    st.key = keys{i};
    res(i) = st;
end